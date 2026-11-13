#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for VictoriaTraces.
#
# Builds the command line from /data/options.json and execs the upstream binary
# (root, as in the upstream image). Data lives in /data/victoria-traces.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"

log() { echo "[victoria-traces-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-INFO}"
RETENTION="$(get retention_period)"; RETENTION="${RETENTION:-7d}"
EXTRA="$(get extra_args)"

mkdir -p /data/victoria-traces

set -- -storageDataPath=/data/victoria-traces -retentionPeriod="${RETENTION}" \
    -httpListenAddr=:10428 -loggerLevel="${LOG_LEVEL}"
if [ -n "${EXTRA}" ]; then
    # Extra flags are split on whitespace.
    # shellcheck disable=SC2086
    set -- "$@" ${EXTRA}
fi

log "Starting VictoriaTraces ${VICTORIA_TRACES_VERSION:-unknown} (retention=${RETENTION})"
exec /victoria-traces-prod "$@"
