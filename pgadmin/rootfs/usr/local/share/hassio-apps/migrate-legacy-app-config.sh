#!/command/with-contenv sh
# shellcheck shell=sh
# One-shot: legacy addon_configs/<…>_<slug>/ → /config, then remove legacy dir.
# Needs map: app_config → /config, all_addon_configs → /addon_configs
# Repo copy: common/; vendored per-app at /usr/local/share/hassio-apps/

_migrate_dir_has_entries() {
    _d="$1"
    [ -d "${_d}" ] || return 1
    for _f in "${_d}"/*; do
        [ -e "${_f}" ] || [ -L "${_f}" ] || return 1
        return 0
    done
    return 1
}

_migrate_rm_tree() {
    _t="$1"
    [ -e "${_t}" ] || [ -L "${_t}" ] || return 0
    rm -rf "${_t}" 2>/dev/null || true
    if [ -d "${_t}" ]; then
        for _f in "${_t}"/* "${_t}"/.[!.]* "${_t}"/..?*; do
            [ -e "${_f}" ] || [ -L "${_f}" ] || continue
            rm -rf "${_f}" 2>/dev/null || true
        done
        rmdir "${_t}" 2>/dev/null || true
    fi
    return 0
}

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
        echo "[migrate-legacy-app-config] removing leftover ${_src}"
        _migrate_rm_tree "${_src}"
        return 0
    fi

    mkdir -p "${_dest}"

    _src_real="$(cd "${_src}" 2>/dev/null && pwd -P)" || _src_real=""
    _dest_real="$(cd "${_dest}" 2>/dev/null && pwd -P)" || _dest_real=""
    if [ -n "${_src_real}" ] && [ "${_src_real}" = "${_dest_real}" ]; then
        echo "[migrate-legacy-app-config] ${_src} and ${_dest} are the same path; marking done"
        date -u +"%Y-%m-%dT%H:%M:%SZ same-path" > "${_marker}"
        return 0
    fi

    if _migrate_dir_has_entries "${_dest}"; then
        echo "[migrate-legacy-app-config] ${_dest} already has data; removing legacy ${_src}"
        _migrate_rm_tree "${_src}"
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
    _migrate_rm_tree "${_src}"
    return 0
}
