#!/command/with-contenv sh
# shellcheck shell=sh
# One-shot: copy Supervisor legacy addon_configs/<…>_<slug>/ into /config,
# then remove that legacy directory so it does not leave zombie files.
#
# Requires map:
#   - type: app_config (rw) → /config
#   - type: all_addon_configs (rw) → /addon_configs
#
# Vendored into each app image at:
#   /usr/local/share/hassio-apps/migrate-legacy-app-config.sh
# (repo copy lives in common/; docker build context is per-app.)
#
# Usage (from cont-init / entrypoint):
#   . /usr/local/share/hassio-apps/migrate-legacy-app-config.sh
#   migrate_legacy_app_config "linkding"
#   migrate_legacy_app_config "acme-sh"
#
migrate_legacy_app_config() {
    _slug="$1"
    _dest="${2:-/config}"
    _legacy_root="${3:-/addon_configs}"
    _marker="${_dest}/.migrated-from-addon-configs"

    if [ -z "${_slug}" ]; then
        echo "[migrate-legacy-app-config] ERROR: slug required"
        return 1
    fi

    if [ ! -d "${_legacy_root}" ]; then
        return 0
    fi

    _src=""
    for _cand in "${_legacy_root}/"*_"${_slug}" "${_legacy_root}/${_slug}"; do
        if [ -d "${_cand}" ]; then
            _src="${_cand}"
            break
        fi
    done

    if [ -z "${_src}" ]; then
        return 0
    fi

    if [ -f "${_marker}" ]; then
        # Already migrated once; still drop leftover legacy if present.
        echo "[migrate-legacy-app-config] removing leftover ${_src}"
        rm -rf "${_src}"
        return 0
    fi

    _dest_has=""
    if [ -d "${_dest}" ]; then
        _dest_has="$(find "${_dest}" -mindepth 1 -maxdepth 1 ! -name '.*' 2>/dev/null | head -1)"
    fi

    mkdir -p "${_dest}"

    if [ -n "${_dest_has}" ]; then
        echo "[migrate-legacy-app-config] ${_dest} already has data; removing legacy ${_src}"
        rm -rf "${_src}"
        date -u +"%Y-%m-%dT%H:%M:%SZ dest-kept" > "${_marker}"
        return 0
    fi

    echo "[migrate-legacy-app-config] copying ${_src} → ${_dest}"
    if ! cp -a "${_src}/." "${_dest}/"; then
        echo "[migrate-legacy-app-config] ERROR: copy failed; leaving legacy in place"
        return 1
    fi

    date -u +"%Y-%m-%dT%H:%M:%SZ from=${_src}" > "${_marker}"
    echo "[migrate-legacy-app-config] removing legacy ${_src}"
    rm -rf "${_src}"
    return 0
}
