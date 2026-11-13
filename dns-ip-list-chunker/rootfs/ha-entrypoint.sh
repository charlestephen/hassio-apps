#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for dns-ip-list-chunker.
# Map /data/options.json → env + list files, then exec the upstream binary.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
EXCL="/data/exclusions.json"
LISTS="/data/lists.yaml"
VERSION="${DNS_IP_LIST_CHUNKER_VERSION:-unknown}"

log() { echo "[dns-ip-list-chunker-addon] $*"; }

if [ ! -f "${OPTIONS}" ]; then
  log "ERROR: ${OPTIONS} missing"
  exit 1
fi

mkdir -p /data

URLS="$(jq -r '(.blocklist_urls // []) | map(select(type=="string" and length>0)) | join(",")' "${OPTIONS}")"
CUSTOM_N="$(jq -r '[.custom_blocklists // [] | .[] | select((.name // "") != "" and ((.entries // "") | length) > 0)] | length' "${OPTIONS}")"
if [ -z "${URLS}" ] && [ "${CUSTOM_N}" -eq 0 ]; then
  log "ERROR: Provide blocklist_urls and/or at least one custom_blocklists entry with entries"
  exit 1
fi

if [ -n "${URLS}" ]; then
  export BLOCKLIST_URLS="${URLS}"
  log "set BLOCKLIST_URLS (hidden length=${#URLS})"
fi

export CHUNK_SIZE
CHUNK_SIZE="$(jq -r '.chunk_size // 100000' "${OPTIONS}")"
export REFRESH_INTERVAL
REFRESH_INTERVAL="$(jq -r '.refresh_interval // "6h"' "${OPTIONS}")"
export PORT=8080
export EXCLUSIONS_FILE="${EXCL}"
export LISTS_FILE="${LISTS}"
log "set CHUNK_SIZE=${CHUNK_SIZE} REFRESH_INTERVAL=${REFRESH_INTERVAL} PORT=${PORT}"

BASE_URL="$(jq -r '.base_url // empty' "${OPTIONS}")"
if [ -n "${BASE_URL}" ]; then
  export BASE_URL
  log "set BASE_URL=${BASE_URL}"
fi

ADMIN_TOKEN="$(jq -r '.admin_token // empty' "${OPTIONS}")"
if [ -n "${ADMIN_TOKEN}" ]; then
  export ADMIN_TOKEN
  log "set ADMIN_TOKEN (hidden)"
fi

EXCL_URLS="$(jq -r '(.exclusions_urls // []) | map(select(type=="string" and length>0)) | join(",")' "${OPTIONS}")"
if [ -n "${EXCL_URLS}" ]; then
  export EXCLUSIONS_URLS="${EXCL_URLS}"
  log "set EXCLUSIONS_URLS"
fi

if jq -e '.allowlist_also_excludes == true' "${OPTIONS}" >/dev/null; then
  export ALLOWLIST_ALSO_EXCLUDES=true
else
  export ALLOWLIST_ALSO_EXCLUDES=false
fi
log "set ALLOWLIST_ALSO_EXCLUDES=${ALLOWLIST_ALSO_EXCLUDES}"

# Emit LISTS_FILE as JSON (upstream accepts YAML or JSON).
jq '{
  custom_blocklists: [(.custom_blocklists // [])[] | select((.name // "") != "" and ((.entries // "") | length) > 0) | {name, category: (.category // ""), entries}],
  exclusion_lists: [(.exclusion_lists // [])[] | select((.name // "") != "" and (((.entries // "") | length) > 0 or ((.url // "") | length) > 0)) | {name, category: (.category // ""), entries: (.entries // ""), url: (.url // ""), output_allowlist: (.output_allowlist == true)}]
}' "${OPTIONS}" > "${LISTS}"

if [ ! -f "${EXCL}" ]; then
  printf '%s\n' '{"dns":[],"ips":[]}' > "${EXCL}"
fi

log "Starting dns-ip-list-chunker v${VERSION} on :${PORT} ..."
exec /usr/bin/dns-ip-list-chunker
