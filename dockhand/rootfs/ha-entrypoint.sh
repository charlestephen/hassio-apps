#!/bin/sh
# shellcheck shell=sh
# Home Assistant wrapper for Dockhand (fnsys/dockhand).
# Maps /data/options.json to Dockhand's variables, creates the PostgreSQL
# database when admin credentials are given, then runs the upstream entrypoint.
set -eu

OPTIONS=/data/options.json
log() { echo "[dockhand-app] $*"; }
warn() { echo "[dockhand-app] WARNING: $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}")" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    echo "[dockhand-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

DB_HOST="$(get db_host)"
DB_PORT="$(get db_port)"
DB_NAME="$(get db_name)"
DB_USER="$(get db_user)"
DB_PASSWORD="$(get db_password)"
if [ -z "${DB_PASSWORD}" ]; then
    echo "[dockhand-app] ERROR: set the database password" >&2
    exit 1
fi

create_database() {
    admin_pw=; admin_user=; tries=0; out=
    admin_pw="$(get db_admin_password)"
    if [ -z "${admin_pw}" ]; then
        log "no PostgreSQL admin password set; using the existing database and login"
        return 0
    fi
    admin_user="$(get db_admin_user)"
    admin_user="${admin_user:-postgres}"
    until out="$(PGPASSWORD="${admin_pw}" psql -X -q -h "${DB_HOST}" -p "${DB_PORT}" -U "${admin_user}" -d postgres -c 'SELECT 1' 2>&1)"; do
        case "${out}" in
            *"authentication failed"*)
                log "ERROR: PostgreSQL refused '${admin_user}'. Check the admin password." >&2
                exit 1
                ;;
        esac
        tries=$((tries + 1))
        if [ "${tries}" -ge 60 ]; then
            log "ERROR: cannot reach PostgreSQL at ${DB_HOST}:${DB_PORT} as ${admin_user}." >&2
            exit 1
        fi
        sleep 2
    done
    PGPASSWORD="${admin_pw}" psql -X -q -v ON_ERROR_STOP=1 -h "${DB_HOST}" -p "${DB_PORT}" -U "${admin_user}" \
        -d postgres -v u="${DB_USER}" -v p="${DB_PASSWORD}" -v d="${DB_NAME}" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('ALTER ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'d', :'u')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'d') \gexec
SELECT format('ALTER DATABASE %I OWNER TO %I', :'d', :'u') \gexec
SQL
    PGPASSWORD="${admin_pw}" psql -X -q -v ON_ERROR_STOP=1 -h "${DB_HOST}" -p "${DB_PORT}" -U "${admin_user}" \
        -d "${DB_NAME}" -v u="${DB_USER}" <<'SQL'
SELECT format('GRANT ALL ON SCHEMA public TO %I', :'u') \gexec
SQL
    log "database '${DB_NAME}' is ready for '${DB_USER}'"
}

create_database

uri() { jq -rn --arg v "$1" '$v | @uri'; }
DATABASE_URL="postgres://$(uri "${DB_USER}"):$(uri "${DB_PASSWORD}")@${DB_HOST}:${DB_PORT}/$(uri "${DB_NAME}")"
PUID="$(get puid)"
PGID="$(get pgid)"
export DATABASE_URL PUID PGID
export DATA_DIR=/data

export_if_set() { # option variable
    value="$(get "$1")"
    if [ -n "${value}" ]; then
        export "$2=${value}"
        case "$2" in
            *KEY*|*PASSWORD*|*SECRET*) log "set $2 (hidden)" ;;
            *) log "set $2=${value}" ;;
        esac
    fi
}
export_if_set origin ORIGIN
export_if_set encryption_key ENCRYPTION_KEY
if is_true export_metrics; then export EXPORT_METRICS=true; fi
if is_true disable_local_login; then export DISABLE_LOCAL_LOGIN=true; fi

# ---- Extra environment variables ----------------------------------------------
while IFS= read -r line; do
    [ -n "${line}" ] || continue
    key="${line%%=*}"
    value="${line#*=}"
    case "${key}" in
        ''|*[!A-Za-z0-9_]*|[0-9]*) warn "skipping an env_vars entry with an invalid name"; continue ;;
    esac
    export "${key}=${value}"
    case "${key}" in
        *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set ${key} from env_vars (hidden)" ;;
        *) log "set ${key} from env_vars" ;;
    esac
done <<EOF
$(jq -r '(.env_vars // [])[] | select((.name // "") != "") | .name + "=" + (.value // "")' "${OPTIONS}")
EOF

log "starting Dockhand ${DOCKHAND_VERSION:-}"
# Forward SIGTERM and exit 0 once it stops: the Supervisor reports an app that
# exits 143 on stop as an error.
/usr/local/bin/docker-entrypoint.sh "$@" &
child=$!
stopping=0
trap 'stopping=1; kill -TERM "${child}" 2>/dev/null' TERM INT
code=0
wait "${child}" || code=$?
if [ "${stopping}" = 1 ]; then
    wait "${child}" 2>/dev/null || true
    exit 0
fi
exit "${code}"
