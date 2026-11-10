#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant wrapper for Ultimate CA Manager (neyslim/ultimate-ca-manager).
#
# Persists PKI under /ssl/ucm. Upstream Docker VOLUMEs at /opt/ucm/data and
# /etc/ucm cannot be replaced with symlinks — bind-mount /ssl/ucm over them
# (preferred). If bind is denied, seed the volumes from /ssl and keep syncing.
# Runs as root (CA holding keys). /data/ucm → /ssl/ucm for addon backups.
# ==============================================================================
set -euo pipefail

OPTIONS="/data/options.json"
VERSION="${UCM_VERSION:-unknown}"
SSL_ROOT="/ssl/ucm"
DATA_LINK="/data/ucm"
VOL_DATA="/opt/ucm/data"
VOL_ETC="/etc/ucm"
DIAG="/data/ucm-addon.log"

log() {
    local msg="[ultimate-ca-manager-addon] $*"
    echo "$msg"
    # Durable copy — HA log UI often misses a fast-exit stdout buffer.
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $msg" >> "${DIAG}" 2>/dev/null || true
}

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

# PostgreSQL: an explicit database_url always wins. In "auto" mode the backend is
# decided once and remembered in /data/.database_backend, because upstream creates
# a ucm.db file even when it runs on PostgreSQL. On the first start of this
# version a ucm.db can only belong to an install from before PostgreSQL support,
# which keeps SQLite since the data is not migrated; a new install uses the
# PostgreSQL app when its admin password is set.
configure_database() {
    local choice host port db user pw admin_user admin_pw tries out marker backend
    marker="/data/.database_backend"
    if [ -n "$(get database_url)" ]; then
        export_if_set 'database_url' 'DATABASE_URL'
        return 0
    fi
    choice="$(get database)"
    choice="${choice:-auto}"
    admin_user="$(get postgres_admin_user)"
    admin_pw="$(get postgres_admin_password)"
    case "${choice}" in
        sqlite)
            echo sqlite > "${marker}"
            log "database: SQLite (selected)"
            return 0
            ;;
        auto)
            if [ -s "${marker}" ]; then
                backend="$(cat "${marker}")"
            elif [ -e "${VOL_DATA}/ucm.db" ]; then
                backend=sqlite
                echo sqlite > "${marker}"
                log "database: keeping the existing SQLite database; set Database to postgres to switch (data is not migrated)"
            elif [ -n "${admin_pw}" ]; then
                backend=postgres
                echo postgres > "${marker}"
            else
                log "database: SQLite. Set the PostgreSQL admin password to use the PostgreSQL app instead."
                return 0
            fi
            if [ "${backend}" = "sqlite" ]; then
                log "database: SQLite"
                return 0
            fi
            ;;
        postgres)
            if [ -z "${admin_pw}" ] && [ ! -s /data/.postgres_password ] && [ -z "$(get postgres_password)" ]; then
                log "ERROR: Database is set to postgres but the PostgreSQL admin password is empty."
                exit 1
            fi
            echo postgres > "${marker}"
            ;;
    esac

    host="$(get postgres_host)"
    [ -n "${host}" ] || host="$(hostname | sed 's/-ultimate-ca-manager$/-postgres/')"
    port="$(get postgres_port)"; port="${port:-5432}"
    db="$(get postgres_db)"; db="${db:-ucm}"
    user="$(get postgres_user)"; user="${user:-ucm}"
    pw="$(get postgres_password)"
    if [ -z "${pw}" ]; then
        if [ ! -s /data/.postgres_password ]; then
            (umask 077 && head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n' > /data/.postgres_password)
        fi
        pw="$(cat /data/.postgres_password)"
    fi

    log "database: PostgreSQL at ${host}:${port}"
    if [ -n "${admin_pw}" ]; then
    tries=0
    until out="$(PGPASSWORD="${admin_pw}" psql -X -q -h "${host}" -p "${port}" -U "${admin_user}" -d postgres -c 'SELECT 1' 2>&1)"; do
        case "${out}" in
            *"authentication failed"*)
                log "ERROR: PostgreSQL refused the admin user '${admin_user}'. Check the admin password."
                exit 1
                ;;
        esac
        tries=$((tries + 1))
        if [ "${tries}" -ge 60 ]; then
            log "ERROR: cannot reach PostgreSQL at ${host}:${port}."
            exit 1
        fi
        sleep 2
    done
    PGPASSWORD="${admin_pw}" psql -X -q -v ON_ERROR_STOP=1 -h "${host}" -p "${port}" -U "${admin_user}" \
        -d postgres -v u="${user}" -v p="${pw}" -v d="${db}" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('ALTER ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'d', :'u')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'d') \gexec
SELECT format('ALTER DATABASE %I OWNER TO %I', :'d', :'u') \gexec
SQL
    PGPASSWORD="${admin_pw}" psql -X -q -v ON_ERROR_STOP=1 -h "${host}" -p "${port}" -U "${admin_user}" \
        -d "${db}" -v u="${user}" <<'SQL'
SELECT format('GRANT ALL ON SCHEMA public TO %I', :'u') \gexec
SQL
    fi
    export DATABASE_URL
    DATABASE_URL="postgresql://$(jq -rn --arg v "${user}" '$v|@uri'):$(jq -rn --arg v "${pw}" '$v|@uri')@${host}:${port}/${db}"
    log "set DATABASE_URL (hidden); database '${db}' is ready"
}

dir_has_entries() {
    local d="$1"
    [[ -d "$d" ]] || return 1
    local f
    # Avoid find|head + pipefail/SIGPIPE under set -e.
    for f in "$d"/* "$d"/.[!.]* "$d"/..?*; do
        [[ -e "$f" ]] || continue
        return 0
    done
    return 1
}

sync_tree() {
    local src="$1" dest="$2"
    mkdir -p "$src" "$dest"
    if dir_has_entries "$src"; then
        cp -a "${src}/." "${dest}/"
    fi
}

# Prefer bind-mount so live writes hit /ssl. On failure, seed the volume and
# return 1 so the caller can start a background sync.
bind_ssl_over_volume() {
    local src="$1" dest="$2"
    mkdir -p "$src" "$dest"
    if ! dir_has_entries "$src" && dir_has_entries "$dest"; then
        log "migrating existing ${dest} -> ${src}"
        cp -a "${dest}/." "${src}/" || true
    fi
    if mount --bind "$src" "$dest" 2>>"${DIAG}"; then
        log "bind-mounted ${src} over ${dest}"
        return 0
    fi
    log "WARN: bind-mount ${src} over ${dest} failed; seeding volume from /ssl"
    sync_tree "$src" "$dest"
    return 1
}

export_if_set() {
    local _v
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*SECRET*|*KEY*|*TOKEN*|*PIN*|DATABASE_URL) log "set $2 (hidden)";;
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

mkdir -p /data
: >> "${DIAG}" 2>/dev/null || DIAG="/dev/null"
log "boot v${VERSION} uid=$(id -u) argv=$*"

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting UCM with image defaults"
fi

# --- PKI layout ---------------------------------------------------------------
mkdir -p "${SSL_ROOT}/data" "${SSL_ROOT}/etc"
chmod 700 "${SSL_ROOT}" "${SSL_ROOT}/data" "${SSL_ROOT}/etc" 2>/dev/null || true

if [ -e "${DATA_LINK}" ] && [ ! -L "${DATA_LINK}" ]; then
    log "WARNING: ${DATA_LINK} exists and is not a symlink; leaving it alone"
else
    ln -sfn "${SSL_ROOT}" "${DATA_LINK}"
    log "addon-backup symlink ${DATA_LINK} -> ${SSL_ROOT}"
fi

NEED_SYNC=0
if ! bind_ssl_over_volume "${SSL_ROOT}/data" "${VOL_DATA}"; then
    NEED_SYNC=1
fi
if ! bind_ssl_over_volume "${SSL_ROOT}/etc" "${VOL_ETC}"; then
    NEED_SYNC=1
fi

# Best-effort ownership; /ssl on HAOS often rejects chown — never abort.
chown -R 1000:1000 "${SSL_ROOT}" 2>/dev/null || true
chown -R 1000:1000 "${VOL_DATA}" "${VOL_ETC}" 2>/dev/null || true
log "PKI: ssl=${SSL_ROOT} vol_data=${VOL_DATA} vol_etc=${VOL_ETC} need_sync=${NEED_SYNC}"

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

CERT_SRC="$(get 'https_cert_file')"
KEY_SRC="$(get 'https_key_file')"
CERT_DST="${VOL_DATA}/https_cert.pem"
KEY_DST="${VOL_DATA}/https_key.pem"
if [ -n "${CERT_SRC}" ] || [ -n "${KEY_SRC}" ]; then
    if [ -z "${CERT_SRC}" ] || [ -z "${KEY_SRC}" ]; then
        log "ERROR: set both https_cert_file and https_key_file (under /ssl/...)"
        exit 1
    fi
    case "${CERT_SRC}" in
        /ssl/*) ;;
        *) log "ERROR: https_cert_file must be under /ssl/ (got ${CERT_SRC})"; exit 1 ;;
    esac
    case "${KEY_SRC}" in
        /ssl/*) ;;
        *) log "ERROR: https_key_file must be under /ssl/ (got ${KEY_SRC})"; exit 1 ;;
    esac
    if [ ! -f "${CERT_SRC}" ] || [ ! -f "${KEY_SRC}" ]; then
        log "ERROR: cert/key not found: ${CERT_SRC} / ${KEY_SRC}"
        exit 1
    fi
    cp -f "${CERT_SRC}" "${CERT_DST}"
    cp -f "${KEY_SRC}" "${KEY_DST}"
    chown 1000:1000 "${CERT_DST}" "${KEY_DST}" 2>/dev/null || true
    chmod 644 "${CERT_DST}" 2>/dev/null || true
    chmod 600 "${KEY_DST}" 2>/dev/null || true
    log "installed UI TLS from ${CERT_SRC} + ${KEY_SRC}"
fi

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

SECRET="$(get 'secret_key')"
SECRET_FILE="${SSL_ROOT}/etc/secret_key"
if [ -z "${SECRET}" ]; then
    if [ ! -s "${SECRET_FILE}" ]; then
        umask 077
        openssl rand -hex 32 > "${SECRET_FILE}"
        chown 1000:1000 "${SECRET_FILE}" 2>/dev/null || true
        chmod 600 "${SECRET_FILE}" 2>/dev/null || true
        log "generated UCM_SECRET_KEY (persisted to ${SECRET_FILE})"
    fi
    SECRET="$(tr -d '\n' < "${SECRET_FILE}")"
fi
# Also mirror into volume etc when not bind-mounted
if [ ! -s "${VOL_ETC}/secret_key" ]; then
    cp -f "${SECRET_FILE}" "${VOL_ETC}/secret_key" 2>/dev/null || true
fi
export UCM_SECRET_KEY="${SECRET}"
log "set UCM_SECRET_KEY (hidden)"

KEK="$(get 'key_encryption_key')"
KEK_FILE="${SSL_ROOT}/etc/key_encryption_key"
if [ -z "${KEK}" ]; then
    if [ ! -s "${KEK_FILE}" ]; then
        umask 077
        python3 -c 'import base64,os; print(base64.urlsafe_b64encode(os.urandom(32)).decode(), end="")' \
            > "${KEK_FILE}"
        chown 1000:1000 "${KEK_FILE}" 2>/dev/null || true
        chmod 600 "${KEK_FILE}" 2>/dev/null || true
        log "generated KEY_ENCRYPTION_KEY (persisted to ${KEK_FILE})"
    fi
    KEK="$(tr -d '\n' < "${KEK_FILE}")"
fi
if [ ! -s "${VOL_ETC}/key_encryption_key" ]; then
    cp -f "${KEK_FILE}" "${VOL_ETC}/key_encryption_key" 2>/dev/null || true
fi
export KEY_ENCRYPTION_KEY="${KEK}"
log "set KEY_ENCRYPTION_KEY (hidden)"

configure_database
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

if [ "${NEED_SYNC}" = "1" ]; then
    log "starting background sync vol -> /ssl every 30s"
    (
        while true; do
            sleep 30
            sync_tree "${VOL_DATA}" "${SSL_ROOT}/data" 2>/dev/null || true
            sync_tree "${VOL_ETC}" "${SSL_ROOT}/etc" 2>/dev/null || true
        done
    ) &
    SYNC_PID=$!
    trap 'log "stopping; final sync"; kill "${SYNC_PID}" 2>/dev/null || true; sync_tree "${VOL_DATA}" "${SSL_ROOT}/data" 2>/dev/null || true; sync_tree "${VOL_ETC}" "${SSL_ROOT}/etc" 2>/dev/null || true' EXIT
fi

# Upstream image CMD is gunicorn; Supervisor often starts addons with an empty
# command, so "$@" is blank and entrypoint.sh's `exec "$@"` exits immediately.
if [ "$#" -eq 0 ]; then
    set -- sh -c 'cd /opt/ucm/backend && gunicorn -c gunicorn_config.py wsgi:app'
    log "using upstream default CMD (gunicorn)"
fi

log "Starting Ultimate CA Manager v${VERSION} as root: $*"
# Do not exec — keep this shell so EXIT trap can flush /ssl when bind failed.
/entrypoint.sh "$@"
rc=$?
log "upstream entrypoint exited rc=${rc}"
exit "${rc}"
