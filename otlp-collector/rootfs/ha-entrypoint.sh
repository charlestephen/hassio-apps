#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for OpenTelemetry Collector Contrib.
#
# Default: collect Docker stats + optional HA Prometheus scrape, receive OTLP
# (traces/metrics/logs), export all signals to otlp_endpoint (or per-signal
# overrides). Paste config_yaml to replace the generated config entirely.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
CONFIG="/data/collector.yaml"
VERSION="${OTELCOL_VERSION:-unknown}"

log() { echo "[otlp-collector-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

# True when a tcp:// endpoint accepts connections. The proxy app may still be
# starting, so retry for up to 20 seconds in total.
docker_reachable() {
    case "$1" in
        tcp://*:*) ;;
        *) return 1 ;;
    esac
    _hostport="${1#tcp://}"
    _deadline=$(($(date +%s) + 20))
    while :; do
        if timeout 3 nc -w 2 "${_hostport%%:*}" "${_hostport##*:}" </dev/null >/dev/null 2>&1; then
            return 0
        fi
        [ "$(date +%s)" -ge "${_deadline}" ] && return 1
        sleep 2
    done
}

mkdir -p /data

CUSTOM="$(get config_yaml)"
if [ -n "${CUSTOM}" ]; then
    printf '%s\n' "${CUSTOM}" > "${CONFIG}"
    log "wrote ${CONFIG} from config_yaml (full override)"
    log "Starting OpenTelemetry Collector Contrib v${VERSION} ..."
    exec /usr/bin/otelcol-contrib --config "${CONFIG}"
fi

LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-info}"
OTLP_EP="$(get otlp_endpoint)"
TRACES_EP="$(get otlp_traces_endpoint)"
METRICS_EP="$(get otlp_metrics_endpoint)"
LOGS_EP="$(get otlp_logs_endpoint)"
PRW_EP="$(get prometheus_remote_write_endpoint)"
SCRAPE="$(get prometheus_scrape_targets)"
HA_TOKEN="$(get ha_prometheus_token)"
HA_PORT="$(get ha_port)"; HA_PORT="${HA_PORT:-80}"
HOSTNAME="$(hostname 2>/dev/null || echo homeassistant)"

# Per-signal endpoints fall back to the shared otlp_endpoint.
[ -z "${TRACES_EP}" ] && TRACES_EP="${OTLP_EP}"
[ -z "${METRICS_EP}" ] && METRICS_EP="${OTLP_EP}"
[ -z "${LOGS_EP}" ] && LOGS_EP="${OTLP_EP}"

# --- receivers ----------------------------------------------------------------
RECEIVERS="  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
"
METRICS_RECV="otlp"
LOGS_RECV="otlp"

if is_true enable_docker_stats; then
    DOCKER_EP="$(get docker_host)"
    if docker_reachable "${DOCKER_EP}"; then
        RECEIVERS="${RECEIVERS}
  docker_stats:
    endpoint: ${DOCKER_EP}
    collection_interval: 30s
    timeout: 20s
"
        METRICS_RECV="${METRICS_RECV}, docker_stats"
        log "docker_stats enabled via ${DOCKER_EP}"
    else
        log "WARNING: enable_docker_stats is on but '${DOCKER_EP}' is not reachable. Start the Docker Socket Proxy app with its 'containers' option on, or set docker_host. Continuing without container stats."
    fi
fi

# Optional host metrics when /hostfs is mounted (custom Supervisor maps).
if [ -d /hostfs/proc ]; then
    RECEIVERS="${RECEIVERS}
  hostmetrics:
    collection_interval: 30s
    root_path: /hostfs
    scrapers:
      cpu:
        metrics:
          system.cpu.utilization:
            enabled: true
      memory: {}
      load: {}
      disk: {}
      filesystem: {}
      network: {}
      paging: {}
      processes: {}
"
    METRICS_RECV="${METRICS_RECV}, hostmetrics"
    log "hostmetrics enabled (/hostfs present)"
fi

# Optional docker json-file logs when the containers dir is mounted.
if [ -d /var/lib/docker/containers ]; then
    RECEIVERS="${RECEIVERS}
  filelog/docker:
    include:
      - /var/lib/docker/containers/*/*-json.log
    start_at: end
    include_file_path: true
    operators:
      - type: container
        id: container-parser
"
    LOGS_RECV="${LOGS_RECV}, filelog/docker"
    log "filelog/docker enabled"
fi

# Optional host journal when mounted.
if [ -d /var/log/journal ] || [ -d /run/log/journal ]; then
    JOURNAL_DIR="/var/log/journal"
    [ -d /run/log/journal ] && [ ! -d /var/log/journal ] && JOURNAL_DIR="/run/log/journal"
    RECEIVERS="${RECEIVERS}
  journald:
    directory: ${JOURNAL_DIR}
    start_at: end
"
    LOGS_RECV="${LOGS_RECV}, journald"
    log "journald enabled (${JOURNAL_DIR})"
fi

# Build prometheus scrape_configs (HA + extras).
SCRAPE_CONFIGS=""
if is_true scrape_homeassistant; then
    AUTH_BLOCK=""
    if [ -n "${HA_TOKEN}" ]; then
        # Quote for YAML; strip characters that would break a double-quoted scalar.
        HA_TOKEN_YML=$(printf '%s' "${HA_TOKEN}" | sed 's/\\/\\\\/g; s/"/\\"/g')
        AUTH_BLOCK="
          authorization:
            type: Bearer
            credentials: \"${HA_TOKEN_YML}\""
    fi
    SCRAPE_CONFIGS="${SCRAPE_CONFIGS}
        - job_name: homeassistant
          scrape_interval: 30s
          metrics_path: /api/prometheus${AUTH_BLOCK}
          static_configs:
            - targets:
                - homeassistant:${HA_PORT}
              labels:
                instance: ${HOSTNAME}
"
    if [ -n "${HA_TOKEN}" ]; then
        log "scraping homeassistant:${HA_PORT}/api/prometheus (Bearer token set)"
    else
        log "scraping homeassistant:${HA_PORT}/api/prometheus (no token — set ha_prometheus_token if scrapes 401)"
    fi
fi

if [ -n "${SCRAPE}" ]; then
    TARGETS=""
    OLDIFS=$IFS
    IFS=','
    # shellcheck disable=SC2086
    set -- ${SCRAPE}
    IFS=$OLDIFS
    for t in "$@"; do
        t=$(echo "$t" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$t" ] && continue
        case "$t" in
            http://*|https://*) ep=${t#*://} ;;
            *) ep=$t ;;
        esac
        if [ -n "${TARGETS}" ]; then
            TARGETS="${TARGETS}
                - ${ep}"
        else
            TARGETS="
                - ${ep}"
        fi
    done
    if [ -n "${TARGETS}" ]; then
        SCRAPE_CONFIGS="${SCRAPE_CONFIGS}
        - job_name: ha-scrape
          scrape_interval: 30s
          static_configs:
            - targets:${TARGETS}
"
        log "extra prometheus scrape targets: ${SCRAPE}"
    fi
fi

if [ -n "${SCRAPE_CONFIGS}" ]; then
    RECEIVERS="${RECEIVERS}
  prometheus:
    config:
      scrape_configs:${SCRAPE_CONFIGS}
"
    METRICS_RECV="${METRICS_RECV}, prometheus"
fi

# --- exporters ----------------------------------------------------------------
EXPORTERS=""
TRACE_EXP=""
METRIC_EXP=""
LOG_EXP=""

if [ -n "${TRACES_EP}" ]; then
    EXPORTERS="${EXPORTERS}
  otlphttp/traces:
    endpoint: ${TRACES_EP}
    tls:
      insecure: true
"
    TRACE_EXP="otlphttp/traces"
    log "traces -> ${TRACES_EP}"
fi

if [ -n "${METRICS_EP}" ]; then
    EXPORTERS="${EXPORTERS}
  otlphttp/metrics:
    endpoint: ${METRICS_EP}
    tls:
      insecure: true
"
    METRIC_EXP="otlphttp/metrics"
    log "metrics (OTLP) -> ${METRICS_EP}"
fi

if [ -n "${PRW_EP}" ]; then
    EXPORTERS="${EXPORTERS}
  prometheusremotewrite:
    endpoint: ${PRW_EP}
    tls:
      insecure: true
    resource_to_telemetry_conversion:
      enabled: true
"
    if [ -n "${METRIC_EXP}" ]; then
        METRIC_EXP="${METRIC_EXP}, prometheusremotewrite"
    else
        METRIC_EXP="prometheusremotewrite"
    fi
    log "metrics (remote_write) -> ${PRW_EP}"
fi

if [ -n "${LOGS_EP}" ]; then
    EXPORTERS="${EXPORTERS}
  otlphttp/logs:
    endpoint: ${LOGS_EP}
    tls:
      insecure: true
"
    LOG_EXP="otlphttp/logs"
    log "logs -> ${LOGS_EP}"
fi

if [ -z "${TRACE_EXP}${METRIC_EXP}${LOG_EXP}" ]; then
    EXPORTERS="${EXPORTERS}
  debug:
    verbosity: basic
"
    TRACE_EXP="debug"
    METRIC_EXP="debug"
    LOG_EXP="debug"
    log "WARNING: no export endpoint set; using debug exporter only — set otlp_endpoint"
fi

cat > "${CONFIG}" <<EOF
# Generated by the Home Assistant OTLP Collector app.
# Set config_yaml in options to replace this file entirely.
extensions:
  health_check:
    endpoint: 0.0.0.0:13133

receivers:
${RECEIVERS}
processors:
  memory_limiter:
    check_interval: 5s
    limit_mib: 400
    spike_limit_mib: 100
  resource:
    attributes:
      - key: service.namespace
        value: homeassistant
        action: upsert
      - key: host.name
        value: ${HOSTNAME}
        action: upsert
      - key: deployment.environment
        value: homeassistant
        action: upsert
  batch:
    send_batch_size: 1024
    timeout: 5s

exporters:
${EXPORTERS}
service:
  extensions: [health_check]
  telemetry:
    logs:
      level: ${LOG_LEVEL}
    metrics:
      readers:
        - pull:
            exporter:
              prometheus:
                host: "0.0.0.0"
                port: 8888
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [${TRACE_EXP}]
    metrics:
      receivers: [${METRICS_RECV}]
      processors: [memory_limiter, resource, batch]
      exporters: [${METRIC_EXP}]
    logs:
      receivers: [${LOGS_RECV}]
      processors: [memory_limiter, resource, batch]
      exporters: [${LOG_EXP}]
EOF

log "wrote generated ${CONFIG}"
log "Starting OpenTelemetry Collector Contrib v${VERSION} ..."
exec /usr/bin/otelcol-contrib --config "${CONFIG}"
