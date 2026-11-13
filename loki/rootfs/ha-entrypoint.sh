#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Grafana Loki.
#
# Writes a single-binary config from /data/options.json and execs the upstream
# binary as the upstream user. A /config/loki.yaml (the app's config directory)
# replaces the generated config.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
OVERRIDE="/config/loki.yaml"
CONFIG="/tmp/loki.yaml"
UID_GID="10001:10001"

log() { echo "[loki-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

mkdir -p /data/loki
chown -R "${UID_GID}" /data/loki

if [ -f "${OVERRIDE}" ]; then
    CONFIG="${OVERRIDE}"
    log "using ${OVERRIDE}; options are ignored"
else
    LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-info}"
    RETENTION="$(get retention_period)"; RETENTION="${RETENTION:-744h}"
    case "${RETENTION}" in 0|0s|0h) RETENTION_ON=false; RETENTION=0s ;; *) RETENTION_ON=true ;; esac
    cat > "${CONFIG}" <<EOF
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096
  log_level: ${LOG_LEVEL}

common:
  instance_addr: 127.0.0.1
  path_prefix: /data/loki
  storage:
    filesystem:
      chunks_directory: /data/loki/chunks
      rules_directory: /data/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

compactor:
  working_directory: /data/loki/compactor
  retention_enabled: ${RETENTION_ON}
  delete_request_store: filesystem

limits_config:
  retention_period: ${RETENTION}
  volume_enabled: true

analytics:
  reporting_enabled: false
EOF
    log "wrote ${CONFIG} (log_level=${LOG_LEVEL}, retention=${RETENTION})"
fi

log "Starting Loki ${LOKI_VERSION:-unknown}"
exec su-exec "${UID_GID}" /usr/bin/loki -config.file="${CONFIG}"
