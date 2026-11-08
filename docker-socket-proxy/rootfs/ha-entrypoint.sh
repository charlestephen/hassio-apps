#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Tecnativa/docker-socket-proxy.
#
# Reads /data/options.json, exports the matching 0/1 Docker API toggles (plus
# LOG_LEVEL / SOCKET_PATH / DISABLE_IPV6), then execs the upstream image
# entrypoint so HAProxy is started the same way as the stock container.
#   Ref: https://github.com/Tecnativa/docker-socket-proxy
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
PROXY_VERSION="${PROXY_VERSION:-unknown}"

log() { echo "[docker-socket-proxy] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

is_true() {
    [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null || echo false)" = "true" ]
}

# Tecnativa HAProxy rules use env(... -m bool); export 1 or 0.
export_bool01() {
    if is_true "$1"; then
        export "$2=1"
        log "set $2=1"
    else
        export "$2=0"
        log "set $2=0"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

# --- Non-API settings ----------------------------------------------------------
_log_level="$(get 'log_level')"
if [ -n "${_log_level}" ]; then
    export LOG_LEVEL="${_log_level}"
    log "set LOG_LEVEL=${_log_level}"
fi

_socket_path="$(get 'socket_path')"
if [ -n "${_socket_path}" ]; then
    export SOCKET_PATH="${_socket_path}"
    log "set SOCKET_PATH=${_socket_path}"
fi

export_bool01 'disable_ipv6' 'DISABLE_IPV6'

# --- API sections (match Tecnativa env names) ----------------------------------
export_bool01 'events' 'EVENTS'
export_bool01 'ping' 'PING'
export_bool01 'version' 'VERSION'

export_bool01 'containers' 'CONTAINERS'
export_bool01 'images' 'IMAGES'
export_bool01 'info' 'INFO'
export_bool01 'networks' 'NETWORKS'
export_bool01 'volumes' 'VOLUMES'

export_bool01 'post' 'POST'
export_bool01 'auth' 'AUTH'
export_bool01 'secrets' 'SECRETS'

export_bool01 'allow_restarts' 'ALLOW_RESTARTS'
export_bool01 'allow_start' 'ALLOW_START'
export_bool01 'allow_stop' 'ALLOW_STOP'
export_bool01 'allow_pause' 'ALLOW_PAUSE'
export_bool01 'allow_unpause' 'ALLOW_UNPAUSE'

export_bool01 'build' 'BUILD'
export_bool01 'commit' 'COMMIT'
export_bool01 'configs' 'CONFIGS'
export_bool01 'distribution' 'DISTRIBUTION'
export_bool01 'exec' 'EXEC'
export_bool01 'grpc' 'GRPC'
export_bool01 'nodes' 'NODES'
export_bool01 'plugins' 'PLUGINS'
export_bool01 'services' 'SERVICES'
export_bool01 'session' 'SESSION'
export_bool01 'swarm' 'SWARM'
export_bool01 'system' 'SYSTEM'
export_bool01 'tasks' 'TASKS'

if [ ! -S "${SOCKET_PATH:-/var/run/docker.sock}" ]; then
    log "WARNING: Docker socket not found at ${SOCKET_PATH:-/var/run/docker.sock}."
    log "Turn Protection mode OFF on this add-on's Info page so docker_api can mount it."
fi

log "Starting Tecnativa docker-socket-proxy v${PROXY_VERSION} ..."
# Upstream ENTRYPOINT/CMD: docker-entrypoint.sh haproxy -f /tmp/haproxy.cfg
exec docker-entrypoint.sh haproxy -f /tmp/haproxy.cfg
