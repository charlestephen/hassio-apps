#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for RatioReign.
#
# Persists config + torrent state under HA's /data volume, seeds a starter
# config.yaml when missing, then hands off to upstream's ratioreign binary.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
CONFIG="/data/config.yaml"
VERSION="${RATIOREIGN_VERSION:-unknown}"

log() { echo "[ratioreign-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

mkdir -p /data/torrents/archived /data/profiles /app/config

# Prefer a full YAML paste from options when provided.
CUSTOM="$(get config_yaml)"
if [ -n "${CUSTOM}" ]; then
    printf '%s\n' "${CUSTOM}" > "${CONFIG}"
    log "wrote ${CONFIG} from config_yaml option"
elif [ ! -f "${CONFIG}" ]; then
    LISTEN="$(get listen_addr)"; LISTEN="${LISTEN:-:7070}"
    MIN_R="$(get min_upload_rate_kbs)"; MIN_R="${MIN_R:-30}"
    MAX_R="$(get max_upload_rate_kbs)"; MAX_R="${MAX_R:-160}"
    SEEDS="$(get simultaneous_seed)"; SEEDS="${SEEDS:-20}"
    PROFILE="$(get client_profile)"; PROFILE="${PROFILE:-qbittorrent-4.6.3}"
    KEEP="$(get keep_torrent_with_zero_leechers)"; KEEP="${KEEP:-true}"
    TARGET="$(get upload_ratio_target)"; TARGET="${TARGET:--1}"
    cat > "${CONFIG}" <<EOF
# Generated once by the Home Assistant app. Edit via the Web UI or replace
# this file; set config_yaml in the app options to force-overwrite on start.
listenAddr: "${LISTEN}"
minUploadRateKBs: ${MIN_R}
maxUploadRateKBs: ${MAX_R}
simultaneousSeed: ${SEEDS}
clientProfile: ${PROFILE}
keepTorrentWithZeroLeechers: ${KEEP}
uploadRatioTarget: ${TARGET}
torrentsDir: /data/torrents
archiveDir: /data/torrents/archived
profilesDir: /app/profiles
statePath: /data/state.json
rss: []
qbittorrent:
  enabled: false
  url: http://homeassistant:8080
  username: admin
  password: CHANGE_ME
  pollInterval: 30s
EOF
    log "seeded starter ${CONFIG}"
else
    log "keeping existing ${CONFIG}"
fi

# Upstream image user is uid 1000 (ratioreign).
chown -R 1000:1000 /data /app/config 2>/dev/null || true
ln -sfn "${CONFIG}" /app/config/config.yaml

log "Starting RatioReign v${VERSION} ..."
exec su-exec 1000:1000 ratioreign -config /app/config/config.yaml
