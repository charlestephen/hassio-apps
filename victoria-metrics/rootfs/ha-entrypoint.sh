#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for VictoriaMetrics.
#
# Builds the command line from /data/options.json and execs the upstream binary
# (root, as in the upstream image). Data lives in /data/victoria-metrics.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"

log() { echo "[victoria-metrics-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-INFO}"
RETENTION="$(get retention_period)"; RETENTION="${RETENTION:-1y}"
EXTRA="$(get extra_args)"

mkdir -p /data/victoria-metrics

set -- -storageDataPath=/data/victoria-metrics -retentionPeriod="${RETENTION}" \
    -httpListenAddr=:8428 -loggerLevel="${LOG_LEVEL}"
if [ -f /config/scrape.yml ]; then
    set -- "$@" -promscrape.config=/config/scrape.yml
    log "scraping with /config/scrape.yml"
fi
if [ -n "${EXTRA}" ]; then
    # Extra flags are split on whitespace.
    # shellcheck disable=SC2086
    set -- "$@" ${EXTRA}
fi

log "Starting VictoriaMetrics ${VICTORIA_METRICS_VERSION:-unknown} (retention=${RETENTION})"
exec /victoria-metrics-prod "$@"
