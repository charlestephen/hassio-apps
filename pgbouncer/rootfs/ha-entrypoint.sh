#!/bin/sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for PgBouncer.
#
# Finds the PostgreSQL app, creates a least-privilege role and lookup function
# there so PgBouncer can check any login against the server's own password
# hashes, writes pgbouncer.ini from the app options, and runs PgBouncer.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
CONF_DIR="/etc/pgbouncer"
AUTH_USER="pgbouncer_auth"
AUTH_PW_FILE="/data/.auth_password"

log() { echo "[pgbouncer-app] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}")" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    log "ERROR: ${OPTIONS} is missing"
    exit 1
fi

# The PostgreSQL app has the same repository prefix as this app's own hostname.
PG_HOST="$(get postgres_host)"
if [ -z "${PG_HOST}" ]; then
    PG_HOST="$(hostname | sed 's/-pgbouncer$/-postgres/')"
fi
PG_PORT="$(get postgres_port)"
ADMIN_USER="$(get postgres_admin_user)"
ADMIN_PW="$(get postgres_admin_password)"

if [ -z "${ADMIN_PW}" ]; then
    log "ERROR: Set the PostgreSQL admin password. It is used once per start to"
    log "ERROR: create the '${AUTH_USER}' role that PgBouncer checks logins with."
    exit 1
fi

# Password of the authentication role, generated once and kept in /data.
if [ ! -s "${AUTH_PW_FILE}" ]; then
    (umask 077 && head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 32 > "${AUTH_PW_FILE}")
fi
AUTH_PW="$(cat "${AUTH_PW_FILE}")"

psql_admin() {
    PGPASSWORD="${ADMIN_PW}" psql -X -q -v ON_ERROR_STOP=1 \
        -h "${PG_HOST}" -p "${PG_PORT}" -U "${ADMIN_USER}" -d postgres "$@"
}

log "Connecting to PostgreSQL at ${PG_HOST}:${PG_PORT} ..."
tries=0
until out="$(psql_admin -c 'SELECT 1' 2>&1)"; do
    case "${out}" in
        *"authentication failed"*)
            log "ERROR: PostgreSQL refused the admin user '${ADMIN_USER}'. Check the admin password."
            exit 1
            ;;
    esac
    tries=$((tries + 1))
    if [ "${tries}" -ge 60 ]; then
        log "ERROR: cannot reach PostgreSQL at ${PG_HOST}:${PG_PORT} as ${ADMIN_USER}."
        log "ERROR: Check the host, the admin user and the admin password."
        exit 1
    fi
    sleep 2
done

psql_admin -v p="${AUTH_PW}" <<'SQL'
SELECT format('CREATE ROLE pgbouncer_auth LOGIN PASSWORD %L', :'p')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pgbouncer_auth') \gexec
SELECT format('ALTER ROLE pgbouncer_auth LOGIN PASSWORD %L', :'p')
WHERE EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pgbouncer_auth') \gexec
CREATE OR REPLACE FUNCTION public.pgbouncer_get_auth(p_usename text)
RETURNS TABLE (usename name, passwd text)
LANGUAGE sql SECURITY DEFINER SET search_path = pg_catalog AS
$$ SELECT usename, passwd FROM pg_catalog.pg_shadow WHERE usename = p_usename $$;
REVOKE ALL ON FUNCTION public.pgbouncer_get_auth(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.pgbouncer_get_auth(text) TO pgbouncer_auth;
SQL
log "Authentication role '${AUTH_USER}' is ready."

POOL_MODE="$(get pool_mode)"

# --- databases ----------------------------------------------------------------
{
    echo "[databases]"
    if [ "$(jq '(.databases // []) | length' "${OPTIONS}")" = "0" ]; then
        echo "* = host=${PG_HOST} port=${PG_PORT}"
    else
        jq -r --arg h "${PG_HOST}" --arg p "${PG_PORT}" '
          .databases[]
          | .name + " = host=" + $h + " port=" + $p + " dbname=" + .name
            + (if .pool_mode then " pool_mode=" + .pool_mode else "" end)' "${OPTIONS}"
    fi
} > "${CONF_DIR}/pgbouncer.ini"

# --- settings -----------------------------------------------------------------
LOG_CONN=0
if is_true log_connections; then LOG_CONN=1; fi
ADMIN_CONSOLE_PW="$(get admin_password)"

{
    echo
    echo "[pgbouncer]"
    echo "listen_addr = *"
    echo "listen_port = 6432"
    echo "unix_socket_dir ="
    echo "auth_type = scram-sha-256"
    echo "auth_file = ${CONF_DIR}/userlist.txt"
    echo "auth_user = ${AUTH_USER}"
    echo "auth_dbname = postgres"
    echo "auth_query = SELECT usename, passwd FROM public.pgbouncer_get_auth(\$1)"
    echo "pool_mode = ${POOL_MODE}"
    echo "max_client_conn = $(get max_client_conn)"
    echo "default_pool_size = $(get default_pool_size)"
    echo "server_tls_sslmode = prefer"
    echo "log_connections = ${LOG_CONN}"
    echo "log_disconnections = ${LOG_CONN}"
    if [ -n "${ADMIN_CONSOLE_PW}" ]; then
        echo "admin_users = pgbouncer"
    fi
    jq -r '(.extra_settings // [])[] | select(. != "")' "${OPTIONS}" | while IFS= read -r line; do
        case "${line}" in
            [a-z_]*=*|[a-z_]*' '=*) echo "${line}" ;;
            *) log "Ignoring extra setting that is not 'name = value'." >&2 ;;
        esac
    done
} >> "${CONF_DIR}/pgbouncer.ini"

# --- user list ----------------------------------------------------------------
{
    printf '"%s" "%s"\n' "${AUTH_USER}" "${AUTH_PW}"
    if [ -n "${ADMIN_CONSOLE_PW}" ]; then
        printf '"pgbouncer" "%s"\n' "${ADMIN_CONSOLE_PW}"
    fi
} > "${CONF_DIR}/userlist.txt"

chown pgbouncer:pgbouncer "${CONF_DIR}/pgbouncer.ini" "${CONF_DIR}/userlist.txt"
chmod 600 "${CONF_DIR}/userlist.txt"

log "Starting PgBouncer ${PGBOUNCER_VERSION:-unknown} on port 6432 (pool mode: ${POOL_MODE})"
exec su-exec pgbouncer pgbouncer "${CONF_DIR}/pgbouncer.ini"
