#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Grafana Mimir.
#
# Writes a monolithic config from /data/options.json and execs the upstream
# binary. A /config/mimir.yaml (the app's config directory) replaces the
# generated config. Mimir runs as root in the upstream image, so no user switch.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
OVERRIDE="/config/mimir.yaml"
CONFIG="/tmp/mimir.yaml"

log() { echo "[mimir-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

mkdir -p /data/mimir

if [ -f "${OVERRIDE}" ]; then
    CONFIG="${OVERRIDE}"
    log "using ${OVERRIDE}; options are ignored"
else
    LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-info}"
    RETENTION="$(get retention_period)"; RETENTION="${RETENTION:-0}"
    cat > "${CONFIG}" <<EOF
multitenancy_enabled: false

server:
  http_listen_port: 9009
  grpc_listen_port: 9095
  log_level: ${LOG_LEVEL}

blocks_storage:
  backend: filesystem
  bucket_store:
    sync_dir: /data/mimir/tsdb-sync
  filesystem:
    dir: /data/mimir/blocks
  tsdb:
    dir: /data/mimir/tsdb

compactor:
  data_dir: /data/mimir/compactor
  sharding_ring:
    kvstore:
      store: memberlist

distributor:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist

ingester:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist
    replication_factor: 1

store_gateway:
  sharding_ring:
    replication_factor: 1

ruler_storage:
  backend: filesystem
  filesystem:
    dir: /data/mimir/rules

limits:
  compactor_blocks_retention_period: ${RETENTION}

usage_stats:
  enabled: false
EOF
    log "wrote ${CONFIG} (log_level=${LOG_LEVEL}, retention=${RETENTION})"
fi

log "Starting Mimir ${MIMIR_VERSION:-unknown}"
exec /usr/bin/mimir -config.file="${CONFIG}"
