#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for OpenObserve.
#
# Exports ZO_* variables from /data/options.json, keeps data on the HA /data
# volume, then execs the upstream binary (root, as in the upstream image).
# ==============================================================================
set -eu

OPTIONS="/data/options.json"

log() { echo "[openobserve-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

EMAIL="$(get root_email)"
PASSWORD="$(get root_password)"
if [ -z "${EMAIL}" ] || [ -z "${PASSWORD}" ]; then
    log "ERROR: set Root email and Root password in the app configuration"
    exit 1
fi
export ZO_ROOT_USER_EMAIL="${EMAIL}"
export ZO_ROOT_USER_PASSWORD="${PASSWORD}"
log "set ZO_ROOT_USER_EMAIL=${EMAIL}"

export ZO_DATA_DIR=/data/openobserve
export ZO_TELEMETRY=false
DAYS="$(get retention_days)"
export ZO_COMPACT_DATA_RETENTION_DAYS="${DAYS:-30}"
log "retention=${ZO_COMPACT_DATA_RETENTION_DAYS} days"

WEB_URL="$(get web_url)"
if [ -n "${WEB_URL}" ]; then
    export ZO_WEB_URL="${WEB_URL}"
    log "set ZO_WEB_URL=${WEB_URL}"
fi

# Any other variable, value quoted by jq so it is safe to eval.
EXTRA="$(jq -r '.env_vars[]? | select(.name | test("^[A-Za-z_][A-Za-z0-9_]*$")) | "export \(.name)=\(.value // "" | @sh)"' "${OPTIONS}" 2>/dev/null || true)"
if [ -n "${EXTRA}" ]; then
    eval "${EXTRA}"
    log "set $(printf '%s\n' "${EXTRA}" | wc -l | tr -d ' ') extra variable(s)"
fi

mkdir -p "${ZO_DATA_DIR}"

log "Starting OpenObserve ${OPENOBSERVE_VERSION:-unknown}"
exec /usr/bin/openobserve
