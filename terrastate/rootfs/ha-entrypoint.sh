#!/bin/sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Terrastate (Terraform HTTP state backend).
#
# Maps HA options to the upstream binary's own TERRASTATE_* environment
# variables (confirmed by running the actual upstream image: the image's own
# baked-in TERRASTATE_STORAGE default is not read by the binary -- only
# TERRASTATE_SERVER_STORAGE is), keeps state on the HA /data volume, then
# execs upstream's own entrypoint/binary.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"

log() { echo "[terrastate-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

USERNAME="$(get access_username)"
PASSWORD="$(get access_password)"
if [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
    log "WARNING: access_username/access_password are not both set -- the Terraform state backend will accept unauthenticated requests from anything that can reach port 8080"
else
    export TERRASTATE_ACCESS_USERNAME="${USERNAME}"
    export TERRASTATE_ACCESS_PASSWORD="${PASSWORD}"
    log "basic auth enabled for user ${USERNAME}"
fi

SECRET="$(get encryption_secret)"
if [ -n "${SECRET}" ]; then
    export TERRASTATE_ENCRYPTION_SECRET="${SECRET}"
    log "state encryption at rest: enabled"
else
    log "state encryption at rest: disabled (set encryption_secret to enable)"
fi

STORAGE="$(get storage_path)"; STORAGE="${STORAGE:-/data/storage}"
export TERRASTATE_SERVER_STORAGE="${STORAGE}"
mkdir -p "${STORAGE}"

HOST="$(get server_host)"
[ -n "${HOST}" ] && export TERRASTATE_SERVER_HOST="${HOST}"

TOKEN="$(get metrics_token)"
[ -n "${TOKEN}" ] && export TERRASTATE_METRICS_TOKEN="${TOKEN}"

LOG_LEVEL="$(get log_level)"
export TERRASTATE_LOG_LEVEL="${LOG_LEVEL:-info}"

log "storage=${STORAGE}"
log "Starting Terrastate ${TERRASTATE_VERSION:-unknown} ..."
exec /usr/bin/terrastate server
