#!/usr/bin/with-contenv bashio
# ==============================================================================
# Generate the active Alloy config before the service starts.
#
# Precedence (highest first):
#   1. /config/config.alloy   — a file dropped in the app config directory
#   2. alloy_config option    — a full config pasted on the Configuration page
#   3. built-in default       — ship all container logs to Loki
# ==============================================================================
set -e

readonly CONFIG_DIR="/etc/alloy"
readonly ACTIVE="${CONFIG_DIR}/config.alloy"
readonly USER_FILE="/config/config.alloy"

mkdir -p "${CONFIG_DIR}"

# 1. File override -------------------------------------------------------------
if bashio::fs.file_exists "${USER_FILE}"; then
    bashio::log.info "Using Alloy config from ${USER_FILE} (file override)"
    cp "${USER_FILE}" "${ACTIVE}"
    exit 0
fi

# 2. Inline config from the app options ------------------------------------
if bashio::config.has_value 'alloy_config'; then
    bashio::log.info "Using inline Alloy config from app options"
    bashio::config 'alloy_config' > "${ACTIVE}"
    exit 0
fi

# 3. Built-in default: tail every container's logs and forward to Loki ---------
LOKI_URL="$(bashio::config 'loki_url')"
LOG_LEVEL="$(bashio::config 'log_level')"
# "$HOSTNAME" in the default config resolves to the Home Assistant host name.
HOSTNAME="$(bashio::info.hostname 2>/dev/null || echo "${HOSTNAME:-homeassistant}")"
export LOKI_URL LOG_LEVEL HOSTNAME

bashio::log.info "No custom config supplied; generating default Docker → Loki config"
bashio::log.info "  loki_url = ${LOKI_URL}"
bashio::log.info "  host     = ${HOSTNAME}"
bashio::log.info "  level    = ${LOG_LEVEL}"

cat > "${ACTIVE}" <<EOF
discovery.docker "local" {
  host = "unix:///var/run/docker.sock"
}

discovery.relabel "docker_containers" {
  targets = discovery.docker.local.targets

  rule {
    source_labels = ["__meta_docker_container_name"]
    regex         = "/(.*)"
    target_label  = "container"
  }
}

loki.source.docker "app_logs" {
  host    = "unix:///var/run/docker.sock"
  targets = discovery.relabel.docker_containers.output
  labels = {
    app  = "docker",
    host = "${HOSTNAME}",
  }
  forward_to = [loki.write.grafana_loki.receiver]
}

loki.write "grafana_loki" {
  endpoint {
    url = "${LOKI_URL}"
  }
}

logging {
  level  = "${LOG_LEVEL}"
  format = "json"
}
EOF
