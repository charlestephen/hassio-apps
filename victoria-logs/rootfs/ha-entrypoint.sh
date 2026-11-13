#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for VictoriaLogs.
#
# Builds the command line from /data/options.json and execs the upstream binary
# (root, as in the upstream image). Data lives in /data/victoria-logs.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"

log() { echo "[victoria-logs-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-INFO}"
RETENTION="$(get retention_period)"; RETENTION="${RETENTION:-30d}"
EXTRA="$(get extra_args)"

mkdir -p /data/victoria-logs

set -- -storageDataPath=/data/victoria-logs -retentionPeriod="${RETENTION}" \
    -httpListenAddr=:9428 -loggerLevel="${LOG_LEVEL}"
if [ -n "${EXTRA}" ]; then
    # Extra flags are split on whitespace.
    # shellcheck disable=SC2086
    set -- "$@" ${EXTRA}
fi

log "Starting VictoriaLogs ${VICTORIA_LOGS_VERSION:-unknown} (retention=${RETENTION})"
exec /victoria-logs-prod "$@"
