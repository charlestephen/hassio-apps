#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Grafana Tempo.
#
# Writes a monolithic (-target=all) config from /data/options.json and execs the
# upstream binary as the upstream user. A /config/tempo.yaml (the app's config
# directory) replaces the generated config.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
OVERRIDE="/config/tempo.yaml"
CONFIG="/tmp/tempo.yaml"
UID_GID="10001:10001"

log() { echo "[tempo-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

mkdir -p /data/tempo
chown -R "${UID_GID}" /data/tempo

if [ -f "${OVERRIDE}" ]; then
    CONFIG="${OVERRIDE}"
    log "using ${OVERRIDE}; options are ignored"
else
    LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-info}"
    RETENTION="$(get retention_period)"; RETENTION="${RETENTION:-336h}"
    cat > "${CONFIG}" <<EOF
stream_over_http_enabled: true

server:
  http_listen_port: 3200
  log_level: ${LOG_LEVEL}

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

backend_worker:
  compaction:
    block_retention: ${RETENTION}

live_store:
  shutdown_marker_dir: /data/tempo/live-store/shutdown-marker
  wal:
    path: /data/tempo/live-store/traces

backend_scheduler:
  local_work_path: /data/tempo/scheduler

storage:
  trace:
    backend: local
    wal:
      path: /data/tempo/wal
    local:
      path: /data/tempo/blocks

usage_report:
  reporting_enabled: false
EOF
    log "wrote ${CONFIG} (log_level=${LOG_LEVEL}, retention=${RETENTION})"
fi

log "Starting Tempo ${TEMPO_VERSION:-unknown}"
exec su-exec "${UID_GID}" /usr/bin/tempo -config.file="${CONFIG}"
