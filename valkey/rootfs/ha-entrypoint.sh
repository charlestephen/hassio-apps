#!/usr/bin/env sh
# Home Assistant wrapper for Valkey (valkey-io/valkey).
# Maps app options to valkey-server CLI flags, then execs upstream's own binary.
set -eu

OPTIONS=/data/options.json
mkdir -p /data

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }

set -- valkey-server --daemonize no --dir /data --bind 0.0.0.0 \
    --maxmemory "$(get maxmemory)" \
    --maxmemory-policy "$(get maxmemory_policy)" \
    --loglevel "$(get log_level)"

PASSWORD="$(get password)"
if [ -n "${PASSWORD}" ]; then
    set -- "$@" --requirepass "${PASSWORD}"
    echo "[valkey-app] requirepass set"
else
    echo "[valkey-app] WARNING: no password set; Valkey is reachable by anyone on the network"
fi

echo "[valkey-app] starting Valkey ${VALKEY_VERSION:-unknown}"
exec "$@"
