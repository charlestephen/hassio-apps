#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Prepare env + seed/merge config-UI exclusions into /data/exclusions.json
# ==============================================================================
set -euo pipefail

OPTIONS=/data/options.json
ENVFILE=/var/run/unifi-blocklist-chunker.env
EXCL=/data/exclusions.json
mkdir -p /data
: > "${ENVFILE}"

URLS="$(jq -r '(.blocklist_urls // []) | map(select(type=="string" and length>0)) | join(",")' "${OPTIONS}")"
if [[ -z "${URLS}" ]]; then
  bashio::log.fatal "blocklist_urls is required (paste at least one upstream list URL)"
  bashio::exit.nok
fi

{
  echo "BLOCKLIST_URLS=${URLS}"
  echo "CHUNK_SIZE=$(jq -r '.chunk_size // 100000' "${OPTIONS}")"
  echo "REFRESH_INTERVAL=$(jq -r '.refresh_interval // "6h"' "${OPTIONS}")"
  echo "PORT=8080"
  echo "EXCLUSIONS_FILE=${EXCL}"
} >> "${ENVFILE}"

BASE_URL="$(jq -r '.base_url // empty' "${OPTIONS}")"
if [[ -n "${BASE_URL}" ]]; then
  echo "BASE_URL=${BASE_URL}" >> "${ENVFILE}"
fi

ADMIN_TOKEN="$(jq -r '.admin_token // empty' "${OPTIONS}")"
if [[ -n "${ADMIN_TOKEN}" ]]; then
  echo "ADMIN_TOKEN=${ADMIN_TOKEN}" >> "${ENVFILE}"
fi

# Merge options.exclusions into the persisted file (add-only). Entries added
# later via /manage survive restarts and are not wiped by this step.
if [[ ! -f "${EXCL}" ]]; then
  printf '%s\n' '{"dns":[],"ips":[]}' > "${EXCL}"
fi
jq -n --slurpfile cur "${EXCL}" --argjson seed "$(jq -c '.exclusions // []' "${OPTIONS}")" '
  def is_ip:
    test("^[0-9a-fA-F:.]+(/[0-9]+)?$") and (contains(":") or test("^[0-9.]+(/[0-9]+)?$"));
  ($cur[0] // {dns:[], ips:[]}) as $c
  | reduce ($seed[]? // empty) as $raw ({dns:($c.dns//[]), ips:($c.ips//[])};
      ($raw|tostring|ascii_downcase|gsub("^\\s+|\\s+$";"")) as $e
      | if $e == "" then .
        elif ($e|is_ip) then .ips = ((.ips + [$e]) | unique | sort)
        else .dns = ((.dns + [$e]) | unique | sort)
        end)
' > /tmp/exclusions.merged.json
mv /tmp/exclusions.merged.json "${EXCL}"

bashio::log.info "UniFi Blocklist Chunker configured ($(wc -l < "${ENVFILE}") env lines; exclusions -> ${EXCL})"
