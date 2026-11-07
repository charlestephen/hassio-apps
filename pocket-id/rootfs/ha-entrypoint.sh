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
# Trailing slash breaks issuer comparison and OIDC discovery for some clients.
APP_URL_VAL="$(get 'app_url')"
if [ -n "${APP_URL_VAL}" ]; then
    APP_URL_VAL="${APP_URL_VAL%/}"
    export APP_URL="${APP_URL_VAL}"
    log "set APP_URL=${APP_URL}"
fi

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
export_if_set 'db_connection_string' 'DB_CONNECTION_STRING'

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
