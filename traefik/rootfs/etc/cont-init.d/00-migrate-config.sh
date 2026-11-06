#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# Migrate Traefik YAML left under the old app /config mount into
# /homeassistant/traefik (HA config dir), then remove the legacy tree.
set -e

# If Supervisor still has a leftover addon_configs/<…>_traefik folder, pull it
# into /config first (requires app_config + all_addon_configs maps).
# shellcheck source=/dev/null
. /usr/local/share/hassio-apps/migrate-legacy-app-config.sh
migrate_legacy_app_config "traefik"

SRC="/config/traefik"
DEST="/homeassistant/traefik"
MARKER="/homeassistant/.migrated-traefik-from-config"

if [[ ! -d "${SRC}" ]]; then
  exit 0
fi

# Anything under /config/traefik counts as legacy content.
if [[ -z "$(find "${SRC}" -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]]; then
  rmdir "${SRC}" 2>/dev/null || true
  exit 0
fi

mkdir -p "${DEST}"

if [[ -f "${MARKER}" ]]; then
  bashio::log.info "Traefik already migrated once; removing leftover ${SRC}"
  rm -rf "${SRC}"
  exit 0
fi

dest_has="$(find "${DEST}" -mindepth 1 -maxdepth 1 ! -name '.*' 2>/dev/null | head -1 || true)"
if [[ -n "${dest_has}" ]]; then
  bashio::log.info "${DEST} already has data; merging missing files from ${SRC}"
  # -n: do not overwrite files already present under /homeassistant/traefik.
  cp -an "${SRC}/." "${DEST}/" || bashio::exit.nok "Failed merging ${SRC} → ${DEST}"
else
  bashio::log.info "Copying ${SRC} → ${DEST}"
  cp -a "${SRC}/." "${DEST}/" || bashio::exit.nok "Failed copying ${SRC} → ${DEST}"
fi

date -u +"%Y-%m-%dT%H:%M:%SZ from=${SRC}" > "${MARKER}"
bashio::log.info "Removing legacy ${SRC}"
rm -rf "${SRC}"
