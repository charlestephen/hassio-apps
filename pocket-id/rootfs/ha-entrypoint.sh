#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Pocket ID (pocket-id/pocket-id).
#
# Exports matching Pocket ID environment variables from /data/options.json,
# points /app/data at the HA /data volume, then execs upstream
# /app/docker/entrypoint.sh (PUID/PGID + su-exec) with /app/pocket-id.
#   Docs: https://pocket-id.org/docs/configuration/environment-variables
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${POCKET_ID_VERSION:-unknown}"

log() { echo "[pocket-id-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set $2 (hidden)";;
            *)                                log "set $2=${_v}";;
        esac
    fi
}

export_true() {
    if is_true "$1"; then
        export "$2=true"
        log "set $2=true"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting Pocket ID with image defaults"
fi

# Persist upstream /app/data on the Supervisor /data volume.
mkdir -p /data
if [ -L /app/data ]; then
    :
elif [ -d /app/data ]; then
    if [ -n "$(find /app/data -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]; then
        cp -a /app/data/. /data/ 2>/dev/null || true
    fi
    rm -rf /app/data
    ln -s /data /app/data
else
    ln -s /data /app/data
fi
log "persisting Pocket ID data at /data (-> /app/data)"

# --- Essentials ---------------------------------------------------------------
# Empty APP_URL makes Pocket ID advertise issuer http://localhost:1411 — OIDC
# clients and passkeys then look "frozen". Require a real public base URL.
# Trailing slash breaks issuer comparison and OIDC discovery for some clients.
APP_URL_VAL="$(get 'app_url')"
APP_URL_VAL="${APP_URL_VAL%/}"
if [ -z "${APP_URL_VAL}" ]; then
    log "ERROR: App URL is required. Set it to the public URL browsers use"
    log "ERROR: (e.g. https://id.example.com) with no path and no trailing slash."
    log "ERROR: Leaving it empty defaults issuer to http://localhost:1411 and"
    log "ERROR: breaks OIDC / passkeys when the app is reached by any other host."
    exit 1
fi
case "${APP_URL_VAL}" in
    http://*|https://*) ;;
    *)
        log "ERROR: App URL must start with http:// or https:// (got: ${APP_URL_VAL})"
        exit 1
        ;;
esac
export APP_URL="${APP_URL_VAL}"
log "set APP_URL=${APP_URL}"
case "${APP_URL}" in
    http://localhost*|http://127.0.0.1*|https://localhost*|https://127.0.0.1*)
        log "WARNING: App URL is loopback — fine for local bring-up; passkeys and"
        log "WARNING: remote OIDC clients need the real public hostname instead."
        ;;
esac

KEY="$(get 'encryption_key')"
if [ -z "${KEY}" ]; then
    KEYFILE="/data/.encryption_key"
    if [ ! -s "${KEYFILE}" ]; then
        # No trailing newline — Pocket ID uses the file bytes as the key.
        printf '%s' "$(openssl rand -base64 32)" > "${KEYFILE}"
        chmod 600 "${KEYFILE}"
        log "generated ENCRYPTION_KEY (persisted to ${KEYFILE})"
    fi
    export ENCRYPTION_KEY_FILE="${KEYFILE}"
    log "set ENCRYPTION_KEY_FILE=${KEYFILE}"
else
    export ENCRYPTION_KEY="${KEY}"
    log "set ENCRYPTION_KEY (hidden)"
fi

export_if_set 'trust_proxy' 'TRUST_PROXY'
export_if_set 'trusted_platform' 'TRUSTED_PLATFORM'
INTERNAL_APP_URL_VAL="$(get 'internal_app_url')"
if [ -n "${INTERNAL_APP_URL_VAL}" ]; then
    INTERNAL_APP_URL_VAL="${INTERNAL_APP_URL_VAL%/}"
    export INTERNAL_APP_URL="${INTERNAL_APP_URL_VAL}"
    log "set INTERNAL_APP_URL=${INTERNAL_APP_URL}"
fi
export_if_set 'maxmind_license_key' 'MAXMIND_LICENSE_KEY'

PUID_VAL="$(get 'puid')"; export PUID="${PUID_VAL:-0}"
PGID_VAL="$(get 'pgid')"; export PGID="${PGID_VAL:-0}"
log "run as PUID=${PUID} PGID=${PGID}"

PORT_VAL="$(get 'port')"
if [ -n "${PORT_VAL}" ]; then
    export PORT="${PORT_VAL}"
    log "set PORT=${PORT}"
fi

export_if_set 'log_level' 'LOG_LEVEL'
export_true 'analytics_disabled' 'ANALYTICS_DISABLED'
export_true 'version_check_disabled' 'VERSION_CHECK_DISABLED'

# --- Database ------------------------------------------------------------------
# Default: PostgreSQL, auto-wired to db_host/db_port/db_name/db_user/db_password
# and auto-created there when db_admin_password is set (same pattern as the
# Authentik app's own PostgreSQL wiring). Setting db_connection_string directly
# overrides this entirely -- a SQLite file path or a hand-built connection
# string both just pass straight through, same as before this change.
DB_CONN_STRING="$(get 'db_connection_string')"
if [ -n "${DB_CONN_STRING}" ]; then
    export DB_CONNECTION_STRING="${DB_CONN_STRING}"
    log "set DB_CONNECTION_STRING (explicit override)"
else
    DB_HOST="$(get 'db_host')"; DB_HOST="${DB_HOST:-dd815a57-postgres}"
    DB_PORT="$(get 'db_port')"; DB_PORT="${DB_PORT:-5432}"
    DB_NAME="$(get 'db_name')"; DB_NAME="${DB_NAME:-pocketid}"
    DB_USER="$(get 'db_user')"; DB_USER="${DB_USER:-pocketid}"
    DB_PASSWORD="$(get 'db_password')"
    if [ -z "${DB_PASSWORD}" ]; then
        log "ERROR: Database password is required to use PostgreSQL. Set it,"
        log "ERROR: or set Database connection string directly for SQLite instead"
        log "ERROR: (e.g. data/pocket-id.db) or a custom connection string."
        exit 1
    fi

    DB_ADMIN_USER="$(get 'db_admin_user')"; DB_ADMIN_USER="${DB_ADMIN_USER:-postgres}"
    DB_ADMIN_PASSWORD="$(get 'db_admin_password')"
    if [ -n "${DB_ADMIN_PASSWORD}" ]; then
        log "creating/ensuring role and database on ${DB_HOST}:${DB_PORT} ..."
        i=0
        until PGPASSWORD="${DB_ADMIN_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_ADMIN_USER}" -d postgres -v ON_ERROR_STOP=1 -tAc 'SELECT 1' >/dev/null 2>&1; do
            i=$((i + 1))
            if [ "${i}" -ge 60 ]; then
                log "ERROR: could not reach PostgreSQL with the admin credentials"
                exit 1
            fi
            sleep 2
        done
        # No DO $$ ... $$ blocks: psql's :'var'/:"var" substitution does not
        # interpolate inside dollar-quoted bodies (confirmed live -- it sent
        # the literal text ":'dbuser'" to the server and errored). \gexec and
        # top-level substitution both work fine, so stick to those only.
        PGPASSWORD="${DB_ADMIN_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_ADMIN_USER}" -d postgres -v ON_ERROR_STOP=1 \
            -v dbuser="${DB_USER}" -v dbpass="${DB_PASSWORD}" -v dbname="${DB_NAME}" <<'SQL'
SELECT 'CREATE ROLE ' || quote_ident(:'dbuser') || ' LOGIN PASSWORD ' || quote_literal(:'dbpass')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'dbuser')\gexec
ALTER ROLE :"dbuser" LOGIN PASSWORD :'dbpass';
SELECT 'CREATE DATABASE ' || quote_ident(:'dbname') || ' OWNER ' || quote_ident(:'dbuser')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'dbname')\gexec
SQL
        # PostgreSQL 15+ only lets the database owner create tables in "public",
        # so fix ownership/grants even for an already-existing database.
        # -c mode does not apply :"var"/:'var' substitution the way script/
        # stdin mode does (confirmed live -- same syntax error as the DO $$
        # case above), so this stays in heredoc form too.
        PGPASSWORD="${DB_ADMIN_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_ADMIN_USER}" -d postgres -v ON_ERROR_STOP=1 \
            -v dbuser="${DB_USER}" -v dbname="${DB_NAME}" <<'SQL'
ALTER DATABASE :"dbname" OWNER TO :"dbuser";
SQL
        PGPASSWORD="${DB_ADMIN_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_ADMIN_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 \
            -v dbuser="${DB_USER}" <<'SQL'
GRANT ALL ON SCHEMA public TO :"dbuser";
SQL
        log "database ${DB_NAME} ready"
    fi

    DB_USER_ENC="$(jq -rn --arg v "${DB_USER}" '$v|@uri')"
    DB_PASS_ENC="$(jq -rn --arg v "${DB_PASSWORD}" '$v|@uri')"
    export DB_CONNECTION_STRING="postgres://${DB_USER_ENC}:${DB_PASS_ENC}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
    log "set DB_CONNECTION_STRING -> postgres://${DB_USER_ENC}:***@${DB_HOST}:${DB_PORT}/${DB_NAME}"
fi

# --- SMTP (app-config; only honored when UI_CONFIG_DISABLED=true) -------------
# Do not export SMTP_* (including the form default smtp_tls=none) unless SMTP is
# actually configured — empty/"default" env values still count as set upstream.
SMTP_HOST="$(get 'smtp_host')"
SMTP_PORT="$(get 'smtp_port')"
SMTP_FROM="$(get 'smtp_from')"
SMTP_USER="$(get 'smtp_user')"
SMTP_PASSWORD="$(get 'smtp_password')"
SMTP_TLS="$(get 'smtp_tls')"
SMTP_ANY=0
[ -n "${SMTP_HOST}${SMTP_PORT}${SMTP_FROM}${SMTP_USER}${SMTP_PASSWORD}" ] && SMTP_ANY=1

if is_true 'ui_config_disabled' || [ "${SMTP_ANY}" = "1" ]; then
    export UI_CONFIG_DISABLED=true
    if [ "${SMTP_ANY}" = "1" ] && ! is_true 'ui_config_disabled'; then
        log "SMTP options set — enabling UI_CONFIG_DISABLED so Pocket ID reads SMTP from env"
    else
        log "set UI_CONFIG_DISABLED=true"
    fi
fi

if [ "${SMTP_ANY}" = "1" ]; then
    if [ -n "${SMTP_HOST}" ]; then
        export SMTP_HOST
        log "set SMTP_HOST=${SMTP_HOST}"
    fi
    if [ -n "${SMTP_PORT}" ]; then
        export SMTP_PORT
        log "set SMTP_PORT=${SMTP_PORT}"
    fi
    if [ -n "${SMTP_FROM}" ]; then
        export SMTP_FROM
        log "set SMTP_FROM=${SMTP_FROM}"
    fi
    if [ -n "${SMTP_USER}" ]; then
        export SMTP_USER
        log "set SMTP_USER=${SMTP_USER}"
    fi
    if [ -n "${SMTP_PASSWORD}" ]; then
        export SMTP_PASSWORD
        log "set SMTP_PASSWORD (hidden)"
    fi
    export SMTP_TLS="${SMTP_TLS:-none}"
    log "set SMTP_TLS=${SMTP_TLS}"
    if is_true 'smtp_skip_cert_verify'; then
        export SMTP_SKIP_CERT_VERIFY=true
        log "set SMTP_SKIP_CERT_VERIFY=true"
    else
        export SMTP_SKIP_CERT_VERIFY=false
        log "set SMTP_SKIP_CERT_VERIFY=false"
    fi
fi

# --- Arbitrary env injection (LDAP, OTEL, more EMAIL_*, …) --------------------
jq -c '(.env_vars // [])[]?' "${OPTIONS}" 2>/dev/null | while IFS= read -r row; do
    [ -n "${row}" ] || continue
    name="$(printf '%s' "${row}" | jq -r '.name // empty')"
    secret="$(printf '%s' "${row}" | jq -r '.secret // false')"
    case "${name}" in
        ''|*[!A-Za-z0-9_]*) log "skip invalid env name"; continue ;;
    esac
    case "${name}" in
        [0-9]*) log "skip invalid env name: ${name}"; continue ;;
    esac
    if [ "${secret}" = "true" ]; then
        log "set ${name} (hidden)"
    else
        case "${name}" in
            *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set ${name} (hidden)";;
            *)
                value="$(printf '%s' "${row}" | jq -r '.value // empty')"
                log "set ${name}=${value}"
                ;;
        esac
    fi
done

eval "$(
    jq -r '
      (.env_vars // [])[]
      | select((.name // "") | test("^[A-Za-z_][A-Za-z0-9_]*$"))
      | "export " + .name + "=" + (.value // "" | @sh)
    ' "${OPTIONS}" 2>/dev/null || true
)"

log "Starting Pocket ID v${VERSION} ..."
# Upstream entrypoint runs `addgroup -g "$PGID"` which fails with
# "gid '0' in use" when PGID is 0. Skip that path and exec as root.
if [ "${PUID}" = "0" ] && [ "${PGID}" = "0" ]; then
    exec /app/pocket-id
fi
exec /app/docker/entrypoint.sh /app/pocket-id
