#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Render /etc/akvorado/{akvorado,console}.yaml from the app options. Runs once
# before the orchestrator/inlet/outlet/console services start.
# ==============================================================================

mkdir -p /etc/akvorado /data

declare KAFKA_HOST KAFKA_PORT CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_PASSWORD REDIS_HOST REDIS_PORT
declare SNMP_COMMUNITY SNMP_V3_USER SNMP_V3_AUTH_PROTOCOL SNMP_V3_AUTH_PASSPHRASE SNMP_V3_PRIV_PROTOCOL SNMP_V3_PRIV_PASSPHRASE
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
export KAFKA_HOST KAFKA_PORT CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_PASSWORD REDIS_HOST REDIS_PORT

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

envsubst < /etc/templates/console.yaml > /etc/akvorado/console.yaml

# Portable line-for-line substitution (no reliance on a specific sed dialect
# -- the container's sed is busybox, not GNU or BSD).
: > /etc/akvorado/akvorado.yaml
while IFS= read -r line || [ -n "${line}" ]; do
    if [ "${line}" = "##SNMP_CREDENTIALS##" ]; then
        snmp_credentials >> /etc/akvorado/akvorado.yaml
    else
        printf '%s\n' "${line}" >> /etc/akvorado/akvorado.yaml
    fi
done < <(envsubst < /etc/templates/akvorado.yaml)

bashio::log.info "Rendered Akvorado configuration (kafka=${KAFKA_HOST}:${KAFKA_PORT}, clickhouse=${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}, redis=${REDIS_HOST}:${REDIS_PORT})"
