#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Gluetun (qdm12/gluetun → qmcgaw/gluetun image).
#
# Exports matching Gluetun environment variables from /data/options.json, then
# execs upstream /gluetun-entrypoint. Empty options are omitted so Gluetun
# keeps its own defaults.
#   Wiki: https://github.com/qdm12/gluetun-wiki
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${GLUETUN_VERSION:-unknown}"

log() { echo "[gluetun-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*KEY*|*PRIVATE*) log "set $2 (hidden)";;
            *)                          log "set $2=${_v}";;
        esac
    fi
}

export_on_off() {
    if is_true "$1"; then
        export "$2=on"; log "set $2=on"
    else
        export "$2=off"; log "set $2=off"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting Gluetun with image defaults"
fi

mkdir -p /data/gluetun
export STORAGE_FILEPATH="/data/gluetun/servers.json"
export PUBLICIP_FILE="/data/gluetun/ip"
log "set STORAGE_FILEPATH=${STORAGE_FILEPATH}"

export_if_set 'tz' 'TZ'
export_if_set 'vpn_service_provider' 'VPN_SERVICE_PROVIDER'
export_if_set 'vpn_type' 'VPN_TYPE'
export_if_set 'vpn_endpoint_port' 'VPN_ENDPOINT_PORT'
export_if_set 'server_countries' 'SERVER_COUNTRIES'
export_if_set 'server_regions' 'SERVER_REGIONS'
export_if_set 'server_cities' 'SERVER_CITIES'
export_if_set 'server_hostnames' 'SERVER_HOSTNAMES'

export_if_set 'openvpn_user' 'OPENVPN_USER'
export_if_set 'openvpn_password' 'OPENVPN_PASSWORD'
export_if_set 'openvpn_protocol' 'OPENVPN_PROTOCOL'

export_if_set 'wireguard_private_key' 'WIREGUARD_PRIVATE_KEY'
export_if_set 'wireguard_addresses' 'WIREGUARD_ADDRESSES'
export_if_set 'wireguard_public_key' 'WIREGUARD_PUBLIC_KEY'
export_if_set 'wireguard_preshared_key' 'WIREGUARD_PRESHARED_KEY'
export_if_set 'wireguard_endpoint_ip' 'WIREGUARD_ENDPOINT_IP'
export_if_set 'wireguard_endpoint_port' 'WIREGUARD_ENDPOINT_PORT'

export_on_off 'vpn_port_forwarding' 'VPN_PORT_FORWARDING'
export_if_set 'firewall_vpn_input_ports' 'FIREWALL_VPN_INPUT_PORTS'

export_on_off 'dot' 'DOT'
export_if_set 'dot_providers' 'DOT_PROVIDERS'

export_on_off 'httpproxy' 'HTTPPROXY'
export_if_set 'httpproxy_user' 'HTTPPROXY_USER'
export_if_set 'httpproxy_password' 'HTTPPROXY_PASSWORD'

export_on_off 'shadowsocks' 'SHADOWSOCKS'
export_if_set 'shadowsocks_password' 'SHADOWSOCKS_PASSWORD'

export_if_set 'log_level' 'LOG_LEVEL'
export_if_set 'updater_period' 'UPDATER_PERIOD'

# Advanced: KEY=VALUE lines (comments and blanks ignored).
EXTRA="$(get extra_env)"
if [ -n "${EXTRA}" ]; then
    printf '%s\n' "${EXTRA}" > /tmp/gluetun-extra.env
    while IFS= read -r line || [ -n "${line}" ]; do
        case "${line}" in
            ''|\#*) continue ;;
            *=*)
                key="${line%%=*}"
                val="${line#*=}"
                export "${key}=${val}"
                case "${key}" in
                    *PASSWORD*|*KEY*|*PRIVATE*) log "set ${key} (hidden, extra_env)";;
                    *) log "set ${key}=${val} (extra_env)";;
                esac
                ;;
        esac
    done < /tmp/gluetun-extra.env
    rm -f /tmp/gluetun-extra.env
fi

# Control server binds all interfaces so HA can reach it on the published port.
export HTTP_CONTROL_SERVER_ADDRESS=":8000"
log "set HTTP_CONTROL_SERVER_ADDRESS=:8000"

log "Starting Gluetun v${VERSION} ..."
exec /gluetun-entrypoint
