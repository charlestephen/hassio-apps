#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# Migrate leftover /config/traefik → /homeassistant/traefik, then remove legacy tree.
set -e

# shellcheck source=/dev/null
. /usr/local/share/hassio-apps/migrate-legacy-app-config.sh
migrate_legacy_app_config "traefik"

SRC="/config/traefik"
DEST="/homeassistant/traefik"
MARKER="/homeassistant/.migrated-traefik-from-config"

dir_has_entries() {
  local d="$1" f
  [[ -d "${d}" ]] || return 1
  for f in "${d}"/*; do
    [[ -e "${f}" || -L "${f}" ]] || return 1
    return 0
  done
  return 1
}

rm_tree() {
  local t="$1" f
  [[ -e "${t}" || -L "${t}" ]] || return 0
  rm -rf "${t}" 2>/dev/null || true
  if [[ -d "${t}" ]]; then
    for f in "${t}"/* "${t}"/.[!.]* "${t}"/..?*; do
      [[ -e "${f}" || -L "${f}" ]] || continue
      rm -rf "${f}" 2>/dev/null || true
    done
    rmdir "${t}" 2>/dev/null || true
  fi
  return 0
}

if [[ ! -d "${SRC}" ]]; then
  exit 0
fi

if ! dir_has_entries "${SRC}"; then
  rmdir "${SRC}" 2>/dev/null || true
  exit 0
fi

mkdir -p "${DEST}"

if [[ -f "${MARKER}" ]]; then
  bashio::log.info "Traefik already migrated once; removing leftover ${SRC}"
  rm_tree "${SRC}"
  exit 0
fi

src_real="$(cd "${SRC}" 2>/dev/null && pwd -P)" || src_real=""
dest_real="$(cd "${DEST}" 2>/dev/null && pwd -P)" || dest_real=""
if [[ -n "${src_real}" && "${src_real}" == "${dest_real}" ]]; then
  bashio::log.info "${SRC} and ${DEST} are the same path; marking migrated"
  date -u +"%Y-%m-%dT%H:%M:%SZ same-path" > "${MARKER}"
  exit 0
fi

if dir_has_entries "${DEST}"; then
  bashio::log.info "${DEST} already has data; removing leftover ${SRC}"
  date -u +"%Y-%m-%dT%H:%M:%SZ dest-kept from=${SRC}" > "${MARKER}"
  rm_tree "${SRC}"
  exit 0
fi

bashio::log.info "Copying ${SRC} → ${DEST}"
cp -a "${SRC}/." "${DEST}/" || bashio::exit.nok "Failed copying ${SRC} → ${DEST}"

date -u +"%Y-%m-%dT%H:%M:%SZ from=${SRC}" > "${MARKER}"
bashio::log.info "Removing legacy ${SRC}"
rm_tree "${SRC}"
