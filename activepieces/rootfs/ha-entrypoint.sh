#!/bin/sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Activepieces.
#
# Exports AP_* variables from /data/options.json, persists local state under
# /data, then execs upstream's own entrypoint unchanged (tini -- its own
# docker-entrypoint.sh, which picks WORKER_AND_APP mode by default).
#   Docs: https://activepieces.com/docs/install/configuration/environment-variables
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${ACTIVEPIECES_VERSION:-unknown}"

log() { echo "[activepieces-addon] $*" >&2; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

mkdir -p /data

FRONTEND_URL="$(get frontend_url)"; FRONTEND_URL="${FRONTEND_URL%/}"
if [ -z "${FRONTEND_URL}" ]; then
    log "ERROR: Frontend URL is required. Set it to the public URL browsers"
    log "ERROR: open Activepieces at (e.g. https://pieces.example.com) --"
    log "ERROR: webhooks, OAuth redirects, and emailed links all use it."
    exit 1
fi
export AP_FRONTEND_URL="${FRONTEND_URL}"
log "set AP_FRONTEND_URL=${AP_FRONTEND_URL}"

# Auto-generate and persist these two (32-char hex) the same way the
# Authentik/Pocket ID apps in this repository do, so they survive restarts.
gen_secret() {
    _file="$1"
    if [ ! -s "${_file}" ]; then
        # No trailing newline -- openssl rand -hex 16 > file would leave one,
        # making the stored secret 33 bytes instead of the required 32
        # (confirmed live: activepieces rejected it as "missing or invalid").
        printf '%s' "$(openssl rand -hex 16)" > "${_file}"
        chmod 600 "${_file}"
        log "generated a secret at ${_file}"
    fi
    cat "${_file}"
}

KEY="$(get encryption_key)"
if [ -z "${KEY}" ]; then
    KEY="$(gen_secret /data/.encryption_key)"
fi
export AP_ENCRYPTION_KEY="${KEY}"

SECRET="$(get jwt_secret)"
if [ -z "${SECRET}" ]; then
    SECRET="$(gen_secret /data/.jwt_secret)"
fi
export AP_JWT_SECRET="${SECRET}"

if is_true telemetry_enabled; then
    export AP_TELEMETRY_ENABLED=true
else
    export AP_TELEMETRY_ENABLED=false
fi
log "set AP_TELEMETRY_ENABLED=${AP_TELEMETRY_ENABLED}"

EXEC_MODE="$(get execution_mode)"
export AP_EXECUTION_MODE="${EXEC_MODE:-UNSANDBOXED}"
log "set AP_EXECUTION_MODE=${AP_EXECUTION_MODE}"

# --- Database -------------------------------------------------------------
DB_TYPE="$(get db_type)"
if [ "${DB_TYPE}" = "postgres" ]; then
    export AP_DB_TYPE=POSTGRES
    _db_host="$(get db_host)"; export AP_POSTGRES_HOST="${_db_host}"
    _db_port="$(get db_port)"; export AP_POSTGRES_PORT="${_db_port}"
    _db_name="$(get db_name)"; export AP_POSTGRES_DATABASE="${_db_name}"
    _db_user="$(get db_user)"; export AP_POSTGRES_USERNAME="${_db_user}"
    _db_pass="$(get db_password)"; export AP_POSTGRES_PASSWORD="${_db_pass}"
    log "database: PostgreSQL at ${AP_POSTGRES_HOST}:${AP_POSTGRES_PORT}/${AP_POSTGRES_DATABASE}"
else
    export AP_DB_TYPE=PGLITE
    export AP_CONFIG_PATH=/data/.activepieces
    mkdir -p "${AP_CONFIG_PATH}"
    log "database: embedded PGLite under ${AP_CONFIG_PATH}"
fi

# --- Queue / Redis ---------------------------------------------------------
REDIS_TYPE="$(get redis_type)"
if [ "${REDIS_TYPE}" = "standalone" ]; then
    export AP_REDIS_TYPE=STANDALONE
    _redis_host="$(get redis_host)"; export AP_REDIS_HOST="${_redis_host}"
    _redis_port="$(get redis_port)"; export AP_REDIS_PORT="${_redis_port}"
    REDIS_PASS="$(get redis_password)"
    [ -n "${REDIS_PASS}" ] && export AP_REDIS_PASSWORD="${REDIS_PASS}"
    log "queue: Redis at ${AP_REDIS_HOST}:${AP_REDIS_PORT}"
else
    export AP_REDIS_TYPE=MEMORY
    log "queue: in-memory"
fi

# Upstream's own compose persists this cache directory; keep it on /data too.
mkdir -p /data/cache
rm -rf /usr/src/app/cache
ln -sfn /data/cache /usr/src/app/cache

# --- Arbitrary env injection -------------------------------------------------
eval "$(
    jq -r '
      (.env_vars // [])[]
      | select((.name // "") | test("^[A-Za-z_][A-Za-z0-9_]*$"))
      | "export " + .name + "=" + (.value // "" | @sh)
    ' "${OPTIONS}" 2>/dev/null || true
)"

log "Starting Activepieces v${VERSION} ..."
cd /usr/src/app
exec tini -- ./docker-entrypoint.sh
