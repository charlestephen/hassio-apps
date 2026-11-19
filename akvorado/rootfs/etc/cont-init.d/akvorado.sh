#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Render /etc/akvorado/{akvorado,console}.yaml from the app options. Runs once
# before the orchestrator/inlet/outlet/console services start.
# ==============================================================================

mkdir -p /etc/akvorado /data /data/geoip

declare KAFKA_HOST KAFKA_PORT CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_PASSWORD REDIS_HOST REDIS_PORT
declare SNMP_COMMUNITY SNMP_V3_USER SNMP_V3_AUTH_PROTOCOL SNMP_V3_AUTH_PASSPHRASE SNMP_V3_PRIV_PROTOCOL SNMP_V3_PRIV_PASSPHRASE
declare DEFAULT_SAMPLING_RATE OWN_HOST WAN_INTERFACE_NAME GEOIP_ACCOUNT_ID GEOIP_LICENSE_KEY
# ClickHouse runs in its own container, so it must reach the orchestrator's
# HTTP dictionary source (protocols/ASNs) via this container's own network
# name -- "localhost" only works for processes inside this same container.
OWN_HOST="$(hostname)"
KAFKA_HOST="$(bashio::config 'kafka_host')"
KAFKA_PORT="$(bashio::config 'kafka_port')"
CLICKHOUSE_HOST="$(bashio::config 'clickhouse_host')"
CLICKHOUSE_PORT="$(bashio::config 'clickhouse_port')"
CLICKHOUSE_PASSWORD="$(bashio::config 'clickhouse_password')"
REDIS_HOST="$(bashio::config 'redis_host')"
REDIS_PORT="$(bashio::config 'redis_port')"
SNMP_COMMUNITY="$(bashio::config 'snmp_community')"
SNMP_V3_USER="$(bashio::config 'snmp_v3_user')"
SNMP_V3_AUTH_PROTOCOL="$(bashio::config 'snmp_v3_auth_protocol')"
SNMP_V3_AUTH_PASSPHRASE="$(bashio::config 'snmp_v3_auth_passphrase')"
SNMP_V3_PRIV_PROTOCOL="$(bashio::config 'snmp_v3_priv_protocol')"
SNMP_V3_PRIV_PASSPHRASE="$(bashio::config 'snmp_v3_priv_passphrase')"
DEFAULT_SAMPLING_RATE="$(bashio::config 'default_sampling_rate')"
WAN_INTERFACE_NAME="$(bashio::config 'wan_interface_name')"
GEOIP_ACCOUNT_ID="$(bashio::config 'geoip_account_id')"
GEOIP_LICENSE_KEY="$(bashio::config 'geoip_license_key')"
export KAFKA_HOST KAFKA_PORT CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_PASSWORD REDIS_HOST REDIS_PORT OWN_HOST

# Double-quoted YAML string: escape backslash and double-quote only.
yaml_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# Akvorado picks SNMPv3 over v1/v2c when "user-name" is present (upstream's
# own rule) -- so v3 wins here whenever a username is configured.
snmp_credentials() {
    if [ -n "${SNMP_V3_USER}" ]; then
        printf '            user-name: "%s"\n' "$(yaml_escape "${SNMP_V3_USER}")"
        printf '            authentication-protocol: "%s"\n' "$(yaml_escape "${SNMP_V3_AUTH_PROTOCOL}")"
        printf '            authentication-passphrase: "%s"\n' "$(yaml_escape "${SNMP_V3_AUTH_PASSPHRASE}")"
        printf '            privacy-protocol: "%s"\n' "$(yaml_escape "${SNMP_V3_PRIV_PROTOCOL}")"
        printf '            privacy-passphrase: "%s"\n' "$(yaml_escape "${SNMP_V3_PRIV_PASSPHRASE}")"
    else
        printf '            communities: "%s"\n' "$(yaml_escape "${SNMP_COMMUNITY:-public}")"
    fi
}
if [ -n "${SNMP_V3_USER}" ]; then
    bashio::log.info "SNMP: using SNMPv3 (user=${SNMP_V3_USER})"
else
    bashio::log.info "SNMP: using SNMPv1/v2c (community=***)"
fi

# Both default-sampling-rate and interface-classifiers live under the same
# outlet.core key, so they're rendered together -- a second "core:" mapping
# in the same YAML document would silently discard the first one.
# 0 sampling rate and an empty WAN interface name both mean "not set".
outlet_core() {
    if [ "${DEFAULT_SAMPLING_RATE:-0}" -le 0 ] && [ -z "${WAN_INTERFACE_NAME}" ]; then
        return
    fi
    printf '  core:\n'
    if [ "${DEFAULT_SAMPLING_RATE:-0}" -gt 0 ]; then
        printf '    default-sampling-rate: %s\n' "${DEFAULT_SAMPLING_RATE}"
        bashio::log.info "Outlet: default sampling rate set to 1:${DEFAULT_SAMPLING_RATE}"
    fi
    if [ -n "${WAN_INTERFACE_NAME}" ]; then
        printf '    interface-classifiers:\n'
        printf '      - Interface.Name == "%s" && ClassifyExternal()\n' "$(yaml_escape "${WAN_INTERFACE_NAME}")"
        printf '      - ClassifyInternal()\n'
        bashio::log.info "Outlet: classifying interface \"${WAN_INTERFACE_NAME}\" as the external boundary"
    fi
}

# geoipupdate's own config file; the geoipupdate service no-ops without it.
if [ -n "${GEOIP_ACCOUNT_ID}" ] && [ -n "${GEOIP_LICENSE_KEY}" ]; then
    mkdir -p /etc/geoipupdate
    {
        printf 'AccountID %s\n' "${GEOIP_ACCOUNT_ID}"
        printf 'LicenseKey %s\n' "${GEOIP_LICENSE_KEY}"
        printf 'EditionIDs GeoLite2-ASN GeoLite2-City\n'
        printf 'DatabaseDirectory /data/geoip\n'
    } > /etc/geoipupdate/GeoIP.conf
    chmod 600 /etc/geoipupdate/GeoIP.conf
    bashio::log.info "GeoIP: MaxMind credentials set, databases will be fetched/refreshed in the background"
else
    rm -f /etc/geoipupdate/GeoIP.conf
    bashio::log.info "GeoIP: no MaxMind account configured, SrcCountry/DstCountry/SrcAS/DstAS stay empty"
fi

envsubst < /etc/templates/console.yaml > /etc/akvorado/console.yaml

# Portable line-for-line substitution (no reliance on a specific sed dialect
# -- the container's sed is busybox, not GNU or BSD).
: > /etc/akvorado/akvorado.yaml
while IFS= read -r line || [ -n "${line}" ]; do
    case "${line}" in
        "##SNMP_CREDENTIALS##") snmp_credentials >> /etc/akvorado/akvorado.yaml ;;
        "##OUTLET_CORE##") outlet_core >> /etc/akvorado/akvorado.yaml ;;
        *) printf '%s\n' "${line}" >> /etc/akvorado/akvorado.yaml ;;
    esac
done < <(envsubst < /etc/templates/akvorado.yaml)

bashio::log.info "Rendered Akvorado configuration (kafka=${KAFKA_HOST}:${KAFKA_PORT}, clickhouse=${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}, redis=${REDIS_HOST}:${REDIS_PORT})"
