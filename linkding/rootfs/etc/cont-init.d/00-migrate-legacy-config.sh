#!/command/with-contenv sh
# Copy legacy addon_configs/<…>_linkding into /config, then remove that host dir.
set -e
# shellcheck source=/dev/null
. /usr/local/share/hassio-apps/migrate-legacy-app-config.sh
migrate_legacy_app_config "linkding"
