#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -euo pipefail

OPTIONS=/data/options.json
ENVFILE=/var/run/dns-ip-list-chunker.env
EXCL=/data/exclusions.json
LISTS=/data/lists.yaml
mkdir -p /data
: > "${ENVFILE}"

URLS="$(jq -r '(.blocklist_urls // []) | map(select(type=="string" and length>0)) | join(",")' "${OPTIONS}")"
CUSTOM_N="$(jq -r '[.custom_blocklists // [] | .[] | select((.name // "") != "" and ((.entries // "") | length) > 0)] | length' "${OPTIONS}")"
if [[ -z "${URLS}" && "${CUSTOM_N}" -eq 0 ]]; then
  bashio::log.fatal "Provide blocklist_urls and/or at least one custom_blocklists entry with entries"
  bashio::exit.nok
fi

{
  if [[ -n "${URLS}" ]]; then
    echo "BLOCKLIST_URLS=${URLS}"
  fi
  echo "CHUNK_SIZE=$(jq -r '.chunk_size // 100000' "${OPTIONS}")"
  echo "REFRESH_INTERVAL=$(jq -r '.refresh_interval // "6h"' "${OPTIONS}")"
  echo "PORT=8080"
  echo "EXCLUSIONS_FILE=${EXCL}"
  echo "LISTS_FILE=${LISTS}"
} >> "${ENVFILE}"

BASE_URL="$(jq -r '.base_url // empty' "${OPTIONS}")"
if [[ -n "${BASE_URL}" ]]; then
  echo "BASE_URL=${BASE_URL}" >> "${ENVFILE}"
fi

ADMIN_TOKEN="$(jq -r '.admin_token // empty' "${OPTIONS}")"
if [[ -n "${ADMIN_TOKEN}" ]]; then
  echo "ADMIN_TOKEN=${ADMIN_TOKEN}" >> "${ENVFILE}"
fi

EXCL_URLS="$(jq -r '(.exclusions_urls // []) | map(select(type=="string" and length>0)) | join(",")' "${OPTIONS}")"
if [[ -n "${EXCL_URLS}" ]]; then
  echo "EXCLUSIONS_URLS=${EXCL_URLS}" >> "${ENVFILE}"
fi

if jq -e '.allowlist_also_excludes == true' "${OPTIONS}" >/dev/null; then
  echo "ALLOWLIST_ALSO_EXCLUDES=true" >> "${ENVFILE}"
else
  echo "ALLOWLIST_ALSO_EXCLUDES=false" >> "${ENVFILE}"
fi

# Emit LISTS_FILE as JSON (upstream accepts YAML or JSON).
jq '{
  custom_blocklists: [(.custom_blocklists // [])[] | select((.name // "") != "" and ((.entries // "") | length) > 0) | {name, category: (.category // ""), entries}],
  exclusion_lists: [(.exclusion_lists // [])[] | select((.name // "") != "" and ((.entries // "") | length) > 0) | {name, category: (.category // ""), entries, output_allowlist: (.output_allowlist == true)}]
}' "${OPTIONS}" > "${LISTS}"

if [[ ! -f "${EXCL}" ]]; then
  printf '%s\n' '{"dns":[],"ips":[]}' > "${EXCL}"
fi

bashio::log.info "DNS/IP List Chunker configured ($(wc -l < "${ENVFILE}") env lines; lists -> ${LISTS})"
