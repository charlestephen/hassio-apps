#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant wrapper for Ultimate CA Manager (neyslim/ultimate-ca-manager).
#
# Persists PKI under /ssl/ucm (data + /etc/ucm master.key), symlinks that tree
# into /data/ucm for addon backups, maps options → env, then execs upstream
# /entrypoint.sh as user ucm (UID 1000).
#   Docs: https://github.com/NeySlim/ultimate-ca-manager/blob/main/docs/installation/docker.md
#   Security: https://github.com/NeySlim/ultimate-ca-manager/blob/main/docs/SECURITY.md
# ==============================================================================
set -euo pipefail

OPTIONS="/data/options.json"
VERSION="${UCM_VERSION:-unknown}"
SSL_ROOT="/ssl/ucm"
DATA_LINK="/data/ucm"

log() { echo "[ultimate-ca-manager-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

export_if_set() {
    local _v
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*SECRET*|*KEY*|*TOKEN*|*PIN*) log "set $2 (hidden)";;
            *)                                      log "set $2=${_v}";;
        esac
    fi
}

export_bool() {
    if is_true "$1"; then
        export "$2=true"
        log "set $2=true"
    else
        export "$2=false"
        log "set $2=false"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting UCM with image defaults"
fi

# --- PKI layout ---------------------------------------------------------------
# Canonical store under /ssl (locked-down HA cert area). Symlink into /data so
# addon backups see the same tree. Container paths match upstream volumes.
mkdir -p "${SSL_ROOT}/data" "${SSL_ROOT}/etc"
chmod 700 "${SSL_ROOT}" "${SSL_ROOT}/data" "${SSL_ROOT}/etc"

if [ -e "${DATA_LINK}" ] && [ ! -L "${DATA_LINK}" ]; then
    log "WARNING: ${DATA_LINK} exists and is not a symlink; leaving it alone"
else
    ln -sfn "${SSL_ROOT}" "${DATA_LINK}"
    log "addon-backup symlink ${DATA_LINK} -> ${SSL_ROOT}"
fi

# /opt/ucm/data → /ssl/ucm/data
if [ -L /opt/ucm/data ]; then
    :
elif [ -d /opt/ucm/data ]; then
    if [ -n "$(find /opt/ucm/data -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]; then
        cp -a /opt/ucm/data/. "${SSL_ROOT}/data/" 2>/dev/null || true
    fi
    rm -rf /opt/ucm/data
    ln -s "${SSL_ROOT}/data" /opt/ucm/data
else
    ln -s "${SSL_ROOT}/data" /opt/ucm/data
fi

# /etc/ucm → /ssl/ucm/etc  (master.key lives here — never drop this volume)
if [ -L /etc/ucm ]; then
    :
elif [ -d /etc/ucm ]; then
    if [ -n "$(find /etc/ucm -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]; then
        cp -a /etc/ucm/. "${SSL_ROOT}/etc/" 2>/dev/null || true
    fi
    rm -rf /etc/ucm
    ln -s "${SSL_ROOT}/etc" /etc/ucm
else
    ln -s "${SSL_ROOT}/etc" /etc/ucm
fi

chown -R 1000:1000 "${SSL_ROOT}"
log "PKI at ${SSL_ROOT}/data + ${SSL_ROOT}/etc (-> /opt/ucm/data, /etc/ucm)"

# --- Core options -------------------------------------------------------------
FQDN="$(get 'ucm_fqdn')"
if [ -z "${FQDN}" ]; then
    FQDN="ucm.local"
fi
export UCM_FQDN="${FQDN}"
log "set UCM_FQDN=${UCM_FQDN}"

HTTPS_PORT="$(get 'https_port')"
export UCM_HTTPS_PORT="${HTTPS_PORT:-8443}"
HTTP_PORT="$(get 'http_port')"
export UCM_HTTP_PORT="${HTTP_PORT:-8080}"
log "set UCM_HTTPS_PORT=${UCM_HTTPS_PORT} UCM_HTTP_PORT=${UCM_HTTP_PORT}"

export_bool 'debug' 'UCM_DEBUG'
export_if_set 'log_level' 'UCM_LOG_LEVEL'

MAX_BYTES="$(get 'log_max_bytes')"
if [ -n "${MAX_BYTES}" ]; then
    export UCM_LOG_MAX_BYTES="${MAX_BYTES}"
    log "set UCM_LOG_MAX_BYTES=${UCM_LOG_MAX_BYTES}"
fi
BACKUPS="$(get 'log_backups')"
if [ -n "${BACKUPS}" ]; then
    export UCM_LOG_BACKUPS="${BACKUPS}"
    log "set UCM_LOG_BACKUPS=${UCM_LOG_BACKUPS}"
fi

# Session secret — persist under /ssl/ucm/etc when not supplied.
SECRET="$(get 'secret_key')"
SECRET_FILE="${SSL_ROOT}/etc/secret_key"
if [ -z "${SECRET}" ]; then
    if [ ! -s "${SECRET_FILE}" ]; then
        umask 077
        openssl rand -hex 32 > "${SECRET_FILE}"
        chown 1000:1000 "${SECRET_FILE}"
        chmod 600 "${SECRET_FILE}"
        log "generated UCM_SECRET_KEY (persisted to ${SECRET_FILE})"
    fi
    SECRET="$(tr -d '\n' < "${SECRET_FILE}")"
fi
export UCM_SECRET_KEY="${SECRET}"
log "set UCM_SECRET_KEY (hidden)"

# Private-key encryption at rest — Fernet master key. Blank option → generate
# once and persist. Losing this file makes encrypted keys unrecoverable.
KEK="$(get 'key_encryption_key')"
KEK_FILE="${SSL_ROOT}/etc/key_encryption_key"
if [ -z "${KEK}" ]; then
    if [ ! -s "${KEK_FILE}" ]; then
        umask 077
        # Fernet key: 32 url-safe base64-encoded bytes (same as Fernet.generate_key).
        python3 -c 'import base64,os; print(base64.urlsafe_b64encode(os.urandom(32)).decode(), end="")' \
            > "${KEK_FILE}"
        chown 1000:1000 "${KEK_FILE}"
        chmod 600 "${KEK_FILE}"
        log "generated KEY_ENCRYPTION_KEY (persisted to ${KEK_FILE})"
    fi
    KEK="$(tr -d '\n' < "${KEK_FILE}")"
fi
export KEY_ENCRYPTION_KEY="${KEK}"
log "set KEY_ENCRYPTION_KEY (hidden)"

export_if_set 'database_url' 'DATABASE_URL'
export_bool 'backup_enabled' 'UCM_BACKUP_ENABLED'
RETENTION="$(get 'backup_retention_days')"
if [ -n "${RETENTION}" ]; then
    export UCM_BACKUP_RETENTION_DAYS="${RETENTION}"
    log "set UCM_BACKUP_RETENTION_DAYS=${UCM_BACKUP_RETENTION_DAYS}"
fi

if is_true 'behind_proxy'; then
    export UCM_BEHIND_PROXY=1
    log "set UCM_BEHIND_PROXY=1"
fi
export_if_set 'trusted_proxies' 'UCM_TRUSTED_PROXIES'
export_if_set 'admin_allowed_networks' 'UCM_ADMIN_ALLOWED_NETWORKS'
if is_true 'admin_allowlist_disable'; then
    export UCM_ADMIN_ALLOWLIST_DISABLE=1
    log "set UCM_ADMIN_ALLOWLIST_DISABLE=1"
fi
export_if_set 'cors_extra_origins' 'CORS_EXTRA_ORIGINS'

DNS_PORT="$(get 'dns_update_port')"
if [ -n "${DNS_PORT}" ] && [ "${DNS_PORT}" != "0" ]; then
    export UCM_DNS_UPDATE_PORT="${DNS_PORT}"
    log "set UCM_DNS_UPDATE_PORT=${UCM_DNS_UPDATE_PORT}"
fi
export_if_set 'dns_update_host' 'UCM_DNS_UPDATE_HOST'

if is_true 'disable_canonical_redirect'; then
    export UCM_DISABLE_CANONICAL_REDIRECT=1
    log "set UCM_DISABLE_CANONICAL_REDIRECT=1"
fi

if is_true 'hsm_auto_init'; then
    export HSM_AUTO_INIT=true
else
    export HSM_AUTO_INIT=false
fi
log "set HSM_AUTO_INIT=${HSM_AUTO_INIT}"

# --- Arbitrary env injection --------------------------------------------------
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
            *PASSWORD*|*SECRET*|*KEY*|*TOKEN*|*PIN*) log "set ${name} (hidden)";;
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

log "Starting Ultimate CA Manager v${VERSION} ..."
# Drop to upstream ucm user (UID 1000); entrypoint + gunicorn must not stay root.
if command -v runuser >/dev/null 2>&1; then
    exec runuser -u ucm -- /entrypoint.sh "$@"
fi
if command -v setpriv >/dev/null 2>&1; then
    exec setpriv --reuid=1000 --regid=1000 --init-groups /entrypoint.sh "$@"
fi
log "WARNING: runuser/setpriv missing; starting as root"
exec /entrypoint.sh "$@"
