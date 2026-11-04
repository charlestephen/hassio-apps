#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Ozark Connect Network Optimizer Speed Test.
#
# Exports compose-parity env from /data/options.json, then execs upstream
# /docker-entrypoint.sh (config.js injection + nginx).
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${NETWORK_OPTIMIZER_SPEEDTEST_VERSION:-unknown}"

log() { echo "[network-optimizer-speedtest-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        log "set $2=${_v}"
    fi
}

export_on_off() {
    if is_true "$1"; then
        export "$2=true"; log "set $2=true"
    else
        export "$2=false"; log "set $2=false"
    fi
}

mkdir -p /data

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

export_if_set 'tz' 'TZ'
export_if_set 'host_ip' 'HOST_IP'
export_if_set 'host_name' 'HOST_NAME'
export_if_set 'reverse_proxied_host_name' 'REVERSE_PROXIED_HOST_NAME'
export_if_set 'reverse_proxied_port' 'REVERSE_PROXIED_PORT'
export_if_set 'trusted_proxies' 'TRUSTED_PROXIES'
export_if_set 'trusted_proxy_hops' 'TRUSTED_PROXY_HOPS'
export_on_off 'trust_cf_connecting_ip' 'TRUST_CF_CONNECTING_IP'

# Must match the host-published port (config ports: 3000/tcp → 3005).
OST_PORT="$(get openspeedtest_port)"; OST_PORT="${OST_PORT:-3005}"
export OPENSPEEDTEST_PORT="${OST_PORT}"
log "set OPENSPEEDTEST_PORT=${OPENSPEEDTEST_PORT}"

export_if_set 'openspeedtest_host' 'OPENSPEEDTEST_HOST'
export_on_off 'openspeedtest_https' 'OPENSPEEDTEST_HTTPS'
export_if_set 'openspeedtest_https_port' 'OPENSPEEDTEST_HTTPS_PORT'
export_if_set 'external_server_id' 'EXTERNAL_SERVER_ID'

EXTRA="$(get extra_env)"
if [ -n "${EXTRA}" ]; then
    printf '%s\n' "${EXTRA}" > /tmp/ost-extra.env
    while IFS= read -r line || [ -n "${line}" ]; do
        case "${line}" in
            ''|\#*) continue ;;
            *=*)
                key="${line%%=*}"
                val="${line#*=}"
                export "${key}=${val}"
                log "set ${key}=${val} (extra_env)"
                ;;
        esac
    done < /tmp/ost-extra.env
    rm -f /tmp/ost-extra.env
fi

if [ -z "${REVERSE_PROXIED_HOST_NAME:-}" ] && [ -z "${HOST_NAME:-}" ] && [ -z "${HOST_IP:-}" ]; then
    log "NOTE: set the same host / reverse_proxied_* values as Network Optimizer so results POST to the app instead of this container:8042"
fi

log "Starting Network Optimizer Speed Test v${VERSION} ..."
exec /docker-entrypoint.sh nginx -g 'daemon off;'
