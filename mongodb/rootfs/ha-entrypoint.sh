#!/bin/sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for MongoDB.
#
# Exports MONGO_INITDB_* from /data/options.json (only used by upstream's own
# entrypoint on a brand-new, empty /data/db -- it unsets them itself after),
# then execs upstream's own entrypoint + mongod unchanged.
# ==============================================================================
set -eu

# The data map's container path is /data/db (not the usual bare /data, to
# match upstream's own VOLUME /data/db declaration -- see config.yaml), so
# Supervisor writes options.json there too (confirmed against this
# repository's homebridge app, which does the same thing for the same
# reason: a custom data map path moves options.json with it).
OPTIONS="/data/db/options.json"
VERSION="${MONGODB_VERSION:-unknown}"

log() { echo "[mongodb-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

USERNAME="$(get root_username)"; export MONGO_INITDB_ROOT_USERNAME="${USERNAME:-root}"
PASSWORD="$(get root_password)"
if [ -z "${PASSWORD}" ]; then
    log "ERROR: Root password is required"
    exit 1
fi
export MONGO_INITDB_ROOT_PASSWORD="${PASSWORD}"
log "set MONGO_INITDB_ROOT_USERNAME=${MONGO_INITDB_ROOT_USERNAME}"

DATABASE="$(get database)"
if [ -n "${DATABASE}" ]; then
    export MONGO_INITDB_DATABASE="${DATABASE}"
    log "set MONGO_INITDB_DATABASE=${DATABASE}"
fi

log "Starting MongoDB ${VERSION} ..."
exec docker-entrypoint.sh mongod
