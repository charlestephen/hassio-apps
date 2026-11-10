#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
# Move leftover Traefik files into /config (app_config), then remove the old trees.
set -e

# shellcheck source=/dev/null
. /usr/local/share/hassio-apps/migrate-legacy-app-config.sh
migrate_legacy_app_config "traefik" /config /app_configs
DEST="/config/dynamic"

for SRC in /homeassistant/traefik /config/traefik; do
  [[ -d "${SRC}" ]] || continue
  mkdir -p "${DEST}"
  if [[ -z "$(ls -A "${DEST}")" ]]; then
    bashio::log.info "Copying ${SRC} → ${DEST}"
    cp -a "${SRC}/." "${DEST}/" || bashio::exit.nok "Failed copying ${SRC} → ${DEST}"
  else
    bashio::log.info "${DEST} already has data; dropping ${SRC}"
  fi
  rm -rf "${SRC}"
done

if [[ -f "${DEST}/traefik.yaml" && ! -e /config/traefik.yaml ]]; then
  mv "${DEST}/traefik.yaml" /config/traefik.yaml
fi
