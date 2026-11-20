#!/bin/sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Checkmate.
#
# Exports the environment variables Checkmate's own app reads directly (no
# custom env handling in upstream's own entrypoint -- confirmed by reading
# it, it just execs whatever command follows), then execs that entrypoint
# unchanged with upstream's own CMD.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${CHECKMATE_VERSION:-unknown}"

log() { echo "[checkmate-addon] $*" >&2; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

mkdir -p /data

CLIENT_HOST="$(get client_host)"; CLIENT_HOST="${CLIENT_HOST%/}"
if [ -z "${CLIENT_HOST}" ]; then
    log "ERROR: Client host is required. Set it to the public URL browsers"
    log "ERROR: open Checkmate at (e.g. https://checkmate.example.com)."
    exit 1
fi
export CLIENT_HOST
log "set CLIENT_HOST=${CLIENT_HOST}"

# $1 = file, $2 = openssl rand args (format differs per variable -- confirmed
# live: ENCRYPTION_KEY rejected a hex value with "must be 32 bytes as padded
# standard base64 (openssl rand -base64 32)"; JWT_SECRET accepted hex fine).
gen_secret() {
    _file="$1"; shift
    if [ ! -s "${_file}" ]; then
        printf '%s' "$(openssl rand "$@")" > "${_file}"
        chmod 600 "${_file}"
        log "generated a secret at ${_file}"
    fi
    cat "${_file}"
}

SECRET="$(get jwt_secret)"
if [ -z "${SECRET}" ]; then
    SECRET="$(gen_secret /data/.jwt_secret -hex 32)"
fi
export JWT_SECRET="${SECRET}"

KEY="$(get encryption_key)"
if [ -z "${KEY}" ]; then
    KEY="$(gen_secret /data/.encryption_key -base64 32)"
fi
export ENCRYPTION_KEY="${KEY}"

QUEUE_MODE="$(get queue_mode)"
export QUEUE_MODE="${QUEUE_MODE:-primary}"
log "set QUEUE_MODE=${QUEUE_MODE}"

# --- Database (MongoDB) -----------------------------------------------------
DB_CONN="$(get db_connection_string)"
if [ -n "${DB_CONN}" ]; then
    export DB_CONNECTION_STRING="${DB_CONN}"
    log "set DB_CONNECTION_STRING (explicit override)"
else
    MONGO_HOST="$(get mongo_host)"; MONGO_HOST="${MONGO_HOST:-dd815a57-mongodb}"
    MONGO_PORT="$(get mongo_port)"; MONGO_PORT="${MONGO_PORT:-27017}"
    MONGO_USER="$(get mongo_user)"; MONGO_USER="${MONGO_USER:-root}"
    MONGO_PASSWORD="$(get mongo_password)"
    MONGO_DATABASE="$(get mongo_database)"; MONGO_DATABASE="${MONGO_DATABASE:-checkmate}"
    if [ -z "${MONGO_PASSWORD}" ]; then
        log "ERROR: Mongo password is required (the MongoDB app's root_password,"
        log "ERROR: or a dedicated user's password). Set Database connection"
        log "ERROR: string directly instead for a different/custom setup."
        exit 1
    fi
    MONGO_USER_ENC="$(jq -rn --arg v "${MONGO_USER}" '$v|@uri')"
    MONGO_PASS_ENC="$(jq -rn --arg v "${MONGO_PASSWORD}" '$v|@uri')"
    export DB_CONNECTION_STRING="mongodb://${MONGO_USER_ENC}:${MONGO_PASS_ENC}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}?authSource=admin"
    log "set DB_CONNECTION_STRING -> mongodb://${MONGO_USER_ENC}:***@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}"
fi

# --- Arbitrary env injection -------------------------------------------------
eval "$(
    jq -r '
      (.env_vars // [])[]
      | select((.name // "") | test("^[A-Za-z_][A-Za-z0-9_]*$"))
      | "export " + .name + "=" + (.value // "" | @sh)
    ' "${OPTIONS}" 2>/dev/null || true
)"

log "Starting Checkmate v${VERSION} ..."
cd /app/server
exec docker-entrypoint.sh node dist/index.js
