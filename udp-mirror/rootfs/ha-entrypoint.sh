#!/usr/bin/env sh
# Home Assistant wrapper for udp-mirror (czerwonk/udp-mirror).
# Builds -listen-address/-receivers flags from the app options, then execs
# upstream's own binary directly.
set -eu

OPTIONS=/data/options.json

LISTEN="$(jq -r '.listen_address // empty' "${OPTIONS}")"
RECEIVERS="$(jq -r '(.receivers // []) | join(",")' "${OPTIONS}")"

if [ -z "${RECEIVERS}" ]; then
    echo "[udp-mirror-app] ERROR: no receivers configured" >&2
    exit 1
fi

echo "[udp-mirror-app] listening on ${LISTEN:-:4560}, mirroring to ${RECEIVERS}"
exec /usr/local/bin/udp-mirror -listen-address "${LISTEN:-:4560}" -receivers "${RECEIVERS}"
