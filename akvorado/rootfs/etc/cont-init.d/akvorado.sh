#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Render /etc/akvorado/{akvorado,console}.yaml from the app options. Runs once
# before the orchestrator/inlet/outlet/console services start.
# ==============================================================================

mkdir -p /etc/akvorado /data

declare KAFKA_HOST KAFKA_PORT CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_PASSWORD REDIS_HOST REDIS_PORT SNMP_COMMUNITY
KAFKA_HOST="$(bashio::config 'kafka_host')"
KAFKA_PORT="$(bashio::config 'kafka_port')"
CLICKHOUSE_HOST="$(bashio::config 'clickhouse_host')"
CLICKHOUSE_PORT="$(bashio::config 'clickhouse_port')"
CLICKHOUSE_PASSWORD="$(bashio::config 'clickhouse_password')"
REDIS_HOST="$(bashio::config 'redis_host')"
REDIS_PORT="$(bashio::config 'redis_port')"
SNMP_COMMUNITY="$(bashio::config 'snmp_community')"
export KAFKA_HOST KAFKA_PORT CLICKHOUSE_HOST CLICKHOUSE_PORT CLICKHOUSE_PASSWORD REDIS_HOST REDIS_PORT SNMP_COMMUNITY

envsubst < /etc/templates/akvorado.yaml > /etc/akvorado/akvorado.yaml
envsubst < /etc/templates/console.yaml > /etc/akvorado/console.yaml

bashio::log.info "Rendered Akvorado configuration (kafka=${KAFKA_HOST}:${KAFKA_PORT}, clickhouse=${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}, redis=${REDIS_HOST}:${REDIS_PORT}, snmp_community=***)"
