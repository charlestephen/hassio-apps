#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for OpenTelemetry Collector Contrib.
#
# Builds /data/collector.yaml from options (or a pasted config_yaml), then execs
# the upstream binary: /usr/bin/otelcol-contrib --config <path>
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
CONFIG="/data/collector.yaml"
VERSION="${OTELCOL_VERSION:-unknown}"

log() { echo "[otlp-collector-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

mkdir -p /data

CUSTOM="$(get config_yaml)"
if [ -n "${CUSTOM}" ]; then
    printf '%s\n' "${CUSTOM}" > "${CONFIG}"
    log "wrote ${CONFIG} from config_yaml option"
else
    LOG_LEVEL="$(get log_level)"; LOG_LEVEL="${LOG_LEVEL:-info}"
    TRACES_EP="$(get otlp_traces_endpoint)"
    METRICS_EP="$(get otlp_metrics_endpoint)"
    LOGS_EP="$(get otlp_logs_endpoint)"
    PRW_EP="$(get prometheus_remote_write_endpoint)"
    SCRAPE="$(get prometheus_scrape_targets)"
    HOSTNAME="$(hostname 2>/dev/null || echo homeassistant)"

    # --- receivers ---
    RECEIVERS="  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
"
    METRICS_RECV="otlp"
    if is_true enable_docker_stats; then
        RECEIVERS="${RECEIVERS}
  docker_stats:
    endpoint: unix:///var/run/docker.sock
    collection_interval: 30s
"
        METRICS_RECV="${METRICS_RECV}, docker_stats"
        log "docker_stats receiver enabled (requires Protection mode off)"
    fi

    if [ -n "${SCRAPE}" ]; then
        # Comma-separated host:port or full URL paths → static scrape targets.
        # Example: homeassistant:8123,10.0.3.6:9090
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
                http://*|https://*)
                    # Strip scheme for prometheus receiver endpoint field
                    ep=${t#*://}
                    ;;
                *)
                    ep=$t
                    ;;
            esac
            if [ -n "${TARGETS}" ]; then
                TARGETS="${TARGETS},
        - ${ep}"
            else
                TARGETS="
        - ${ep}"
            fi
        done
        if [ -n "${TARGETS}" ]; then
            RECEIVERS="${RECEIVERS}
  prometheus:
    config:
      scrape_configs:
        - job_name: ha-scrape
          scrape_interval: 30s
          static_configs:
            - targets:${TARGETS}
"
            METRICS_RECV="${METRICS_RECV}, prometheus"
            log "prometheus scrape targets: ${SCRAPE}"
        fi
    fi

    # --- exporters ---
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

    # Debug exporter when nothing is configured so the collector still starts
    # and accepts OTLP (useful for bring-up / local inspection).
    if [ -z "${TRACE_EXP}${METRIC_EXP}${LOG_EXP}" ]; then
        EXPORTERS="${EXPORTERS}
  debug:
    verbosity: basic
"
        TRACE_EXP="debug"
        METRIC_EXP="debug"
        LOG_EXP="debug"
        log "WARNING: no export endpoints set; using debug exporter only"
    fi

    # Pipelines — only include signals that have exporters; always accept OTLP.
    PIPELINES="  pipelines:"
    PIPELINES="${PIPELINES}
    traces:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [${TRACE_EXP}]
    metrics:
      receivers: [${METRICS_RECV}]
      processors: [memory_limiter, resource, batch]
      exporters: [${METRIC_EXP}]
    logs:
      receivers: [otlp]
      processors: [memory_limiter, resource, batch]
      exporters: [${LOG_EXP}]
"

    cat > "${CONFIG}" <<EOF
# Generated by the Home Assistant OTLP Collector app.
# Paste config_yaml in options to override on every start.
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
      address: 0.0.0.0:8888
${PIPELINES}
EOF
    log "wrote generated ${CONFIG}"
fi

log "Starting OpenTelemetry Collector Contrib v${VERSION} ..."
exec /usr/bin/otelcol-contrib --config "${CONFIG}"
