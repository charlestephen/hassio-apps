#!/usr/bin/env sh
# Home Assistant wrapper for ClickHouse (clickhouse/clickhouse-server).
# Maps app options to the CLICKHOUSE_* environment variables upstream's own
# entrypoint already reads, points data storage at /data, then execs it.
set -eu

OPTIONS=/data/options.json
mkdir -p /data/clickhouse

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }

PASSWORD="$(get default_user_password)"
if [ -n "${PASSWORD}" ]; then
    export CLICKHOUSE_PASSWORD="${PASSWORD}"
    echo "[clickhouse-app] default user password set"
else
    echo "[clickhouse-app] WARNING: no default_user_password set; ClickHouse is reachable without auth"
fi

RATIO="$(get max_server_memory_usage_to_ram_ratio)"
LEVEL="$(get log_level)"

mkdir -p /etc/clickhouse-server/config.d
cat > /etc/clickhouse-server/config.d/addon.xml <<XML
<clickhouse>
    <path>/data/clickhouse/</path>
    <tmp_path>/data/clickhouse/tmp/</tmp_path>
    <user_files_path>/data/clickhouse/user_files/</user_files_path>
    <format_schema_path>/data/clickhouse/format_schemas/</format_schema_path>
    <access_control_path>/data/clickhouse/access/</access_control_path>
    <max_server_memory_usage_to_ram_ratio>${RATIO:-0.8}</max_server_memory_usage_to_ram_ratio>
    <logger>
        <level>${LEVEL:-information}</level>
        <console>true</console>
    </logger>
</clickhouse>
XML

echo "[clickhouse-app] starting ClickHouse ${CLICKHOUSE_VERSION:-unknown}"
exec /entrypoint.sh
