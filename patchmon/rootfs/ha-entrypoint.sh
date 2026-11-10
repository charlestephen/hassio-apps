#!/bin/sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for PatchMon.
#
# Creates the database on the PostgreSQL app when asked to, generates the
# secrets once, runs a local Valkey (Redis protocol) cache on loopback, and runs
# the upstream entrypoint with the environment PatchMon expects.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
SECRETS="/data/secrets"
APP_USER="patchmon"

log() { echo "[patchmon-app] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}")" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    log "ERROR: ${OPTIONS} is missing"
    exit 1
fi

SERVER_URL="$(get server_url)"
if [ -z "${SERVER_URL}" ]; then
    log "ERROR: Set the server URL to the address you open PatchMon at, for example"
    log "ERROR: http://homeassistant.local:3100. Browsers using any other address are rejected."
    exit 1
fi

PG_HOST="$(get postgres_host)"
if [ -z "${PG_HOST}" ]; then
    PG_HOST="$(hostname | sed 's/-patchmon$/-postgres/')"
fi
PG_PORT="$(get postgres_port)"
PG_DB="$(get postgres_db)"
PG_USER="$(get postgres_user)"
PG_PASSWORD="$(get postgres_password)"
if [ -z "${PG_PASSWORD}" ]; then
    log "ERROR: Set the database password for '${PG_USER}'."
    exit 1
fi

# --- database -----------------------------------------------------------------
ADMIN_USER="$(get postgres_admin_user)"
ADMIN_PW="$(get postgres_admin_password)"
if [ -n "${ADMIN_PW}" ]; then
    psql_admin() {
        PGPASSWORD="${ADMIN_PW}" psql -X -q -v ON_ERROR_STOP=1 \
            -h "${PG_HOST}" -p "${PG_PORT}" -U "${ADMIN_USER}" "$@"
    }
    log "Connecting to PostgreSQL at ${PG_HOST}:${PG_PORT} ..."
    tries=0
    until out="$(psql_admin -d postgres -c 'SELECT 1' 2>&1)"; do
        case "${out}" in
            *"authentication failed"*)
                log "ERROR: PostgreSQL refused the admin user '${ADMIN_USER}'. Check the admin password."
                exit 1
                ;;
        esac
        tries=$((tries + 1))
        if [ "${tries}" -ge 60 ]; then
            log "ERROR: cannot reach PostgreSQL at ${PG_HOST}:${PG_PORT}."
            exit 1
        fi
        sleep 2
    done
    psql_admin -d postgres -v u="${PG_USER}" -v p="${PG_PASSWORD}" -v d="${PG_DB}" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('ALTER ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'d', :'u')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'d') \gexec
SELECT format('ALTER DATABASE %I OWNER TO %I', :'d', :'u') \gexec
SQL
    psql_admin -d "${PG_DB}" -v u="${PG_USER}" <<'SQL'
SELECT format('GRANT ALL ON SCHEMA public TO %I', :'u') \gexec
SQL
    log "Database '${PG_DB}' is ready."
fi

# --- secrets ------------------------------------------------------------------
mkdir -p "${SECRETS}" /data/valkey /data/ssh
secret() { # name, bytes
    if [ ! -s "${SECRETS}/$1" ]; then
        (umask 077 && head -c "$2" /dev/urandom | od -An -tx1 | tr -d ' \n' > "${SECRETS}/$1")
    fi
    cat "${SECRETS}/$1"
}
JWT_SECRET="$(secret jwt 64)"
SESSION_SECRET="$(secret session 64)"
AI_ENCRYPTION_KEY="$(secret ai 64)"
REDIS_PASSWORD="$(secret redis 32)"
chown -R "${APP_USER}:${APP_USER}" /data/secrets /data/valkey /data/ssh
chmod 700 "${SECRETS}"

# --- environment --------------------------------------------------------------
CORS_ORIGIN="${SERVER_URL},http://localhost:3000"
export CORS_ORIGIN JWT_SECRET SESSION_SECRET AI_ENCRYPTION_KEY REDIS_PASSWORD
export POSTGRES_HOST="${PG_HOST}" POSTGRES_PASSWORD="${PG_PASSWORD}"
export POSTGRES_USER="${PG_USER}" POSTGRES_DB="${PG_DB}"
export DATABASE_URL="postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:${PG_PORT}/${PG_DB}"
export REDIS_HOST="127.0.0.1" REDIS_PORT="6379" REDIS_DB="0"
export PATCHMON_SSH_KNOWN_HOSTS="/data/ssh/known_hosts"
export LOG_LEVEL="$(get log_level)"
if is_true trust_proxy; then export TRUST_PROXY=true; fi
TZ_OPT="$(get timezone)"
if [ -n "${TZ_OPT}" ]; then export TZ="${TZ_OPT}"; fi

# Extra variables, for example the OIDC settings.
jq -r '(.env_vars // [])[] | select((.name // "") | test("^[A-Za-z_][A-Za-z0-9_]*$"))
       | "export " + .name + "=" + ((.value // "") | @sh)' "${OPTIONS}" > /tmp/extra_env.sh
# shellcheck source=/dev/null
. /tmp/extra_env.sh
rm -f /tmp/extra_env.sh

# --- cache and server ---------------------------------------------------------
su-exec "${APP_USER}" valkey-server --bind 127.0.0.1 --port 6379 \
    --requirepass "${REDIS_PASSWORD}" --dir /data/valkey --save "" \
    --appendonly no --daemonize no --loglevel warning &
CACHE_PID=$!

tries=0
until REDISCLI_AUTH="${REDIS_PASSWORD}" valkey-cli -h 127.0.0.1 ping >/dev/null 2>&1; do
    tries=$((tries + 1))
    if [ "${tries}" -ge 30 ]; then
        log "ERROR: the cache did not start."
        exit 1
    fi
    sleep 1
done

log "Starting PatchMon ${PATCHMON_VERSION:-unknown}; open ${SERVER_URL}"
cd /app
su-exec "${APP_USER}" ./entrypoint.sh &
SERVER_PID=$!

stop() {
    kill -TERM "${SERVER_PID}" "${CACHE_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
    wait "${CACHE_PID}" 2>/dev/null || true
    exit 0
}
trap stop TERM INT

# End the container as soon as either process stops.
while kill -0 "${SERVER_PID}" 2>/dev/null && kill -0 "${CACHE_PID}" 2>/dev/null; do
    sleep 2
done
log "A process stopped; shutting down."
kill -TERM "${SERVER_PID}" "${CACHE_PID}" 2>/dev/null || true
wait "${SERVER_PID}" 2>/dev/null; code=$?
exit "${code}"
