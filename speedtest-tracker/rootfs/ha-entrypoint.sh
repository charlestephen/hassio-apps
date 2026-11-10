#!/usr/bin/env bash
# Home Assistant wrapper for Speedtest Tracker (linuxserver/speedtest-tracker).
# Maps /data/options.json to the image's variables, creates the database when
# admin credentials are given, then runs the image's own init.
set -euo pipefail

OPTIONS=/data/options.json
log() { echo "[speedtest-tracker-app] $*"; }
warn() { echo "[speedtest-tracker-app] WARNING: $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }

if [ ! -f "${OPTIONS}" ]; then
    echo "[speedtest-tracker-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

DB_HOST="$(get db_host)"
DB_PORT="$(get db_port)"
DB_NAME="$(get db_name)"
DB_USER="$(get db_user)"
DB_PASSWORD="$(get db_password)"
if [ -z "${DB_PASSWORD}" ]; then
    echo "[speedtest-tracker-app] ERROR: set the database password" >&2
    exit 1
fi

create_database() {
    local admin_pw admin_user tries=0 out
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

export DB_CONNECTION=pgsql DB_HOST DB_PORT DB_PASSWORD
export DB_DATABASE="${DB_NAME}" DB_USERNAME="${DB_USER}"

APP_KEY_VALUE="$(get app_key)"
if [ -z "${APP_KEY_VALUE}" ]; then
    key_file=/config/.app_key
    if [ ! -s "${key_file}" ]; then
        (umask 077 && printf 'base64:%s' "$(head -c 32 /dev/urandom | base64 | tr -d '\n')" > "${key_file}")
        log "generated an app key in ${key_file}"
    fi
    APP_KEY_VALUE="$(cat "${key_file}")"
fi
export APP_KEY="${APP_KEY_VALUE}"

export_if_set() { # option variable
    local value
    value="$(get "$1")"
    if [ -n "${value}" ]; then
        export "$2=${value}"
        log "set $2=${value}"
    fi
}
export_if_set app_url APP_URL
export_if_set speedtest_schedule SPEEDTEST_SCHEDULE
export_if_set speedtest_servers SPEEDTEST_SERVERS
export_if_set app_timezone APP_TIMEZONE
export_if_set app_timezone TZ

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

log "starting Speedtest Tracker ${SPEEDTEST_TRACKER_VERSION:-}"
exec /init "$@"
