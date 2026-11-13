#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Grafana.
#
# Exports GF_* variables from /data/options.json, keeps Grafana's data on the
# HA /data volume, then runs upstream /run.sh as the upstream user (472).
# Provisioning files in /config/provisioning (the app's config directory) are
# picked up when that directory exists.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
UID_GID="472:0"

log() { echo "[grafana-addon] $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

export_if_set() {
    _v="$(get "$1")"
    [ -n "${_v}" ] || return 0
    export "$2=${_v}"
    case "$2" in
        *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set $2 (hidden)" ;;
        *) log "set $2=${_v}" ;;
    esac
}

export_if_set admin_user GF_SECURITY_ADMIN_USER
export_if_set admin_password GF_SECURITY_ADMIN_PASSWORD
export_if_set root_url GF_SERVER_ROOT_URL
export_if_set plugins GF_INSTALL_PLUGINS
export_if_set log_level GF_LOG_LEVEL

export GF_PATHS_DATA=/data/grafana
export GF_PATHS_PLUGINS=/data/grafana/plugins
if [ -d /config/provisioning ]; then
    export GF_PATHS_PROVISIONING=/config/provisioning
    log "using provisioning files from /config/provisioning"
fi

# Any other variable, value quoted by jq so it is safe to eval.
EXTRA="$(jq -r '.env_vars[]? | select(.name | test("^[A-Za-z_][A-Za-z0-9_]*$")) | "export \(.name)=\(.value // "" | @sh)"' "${OPTIONS}" 2>/dev/null || true)"
if [ -n "${EXTRA}" ]; then
    eval "${EXTRA}"
    log "set $(printf '%s\n' "${EXTRA}" | wc -l | tr -d ' ') extra variable(s)"
fi

mkdir -p "${GF_PATHS_DATA}"
chown -R "${UID_GID}" "${GF_PATHS_DATA}"

log "Starting Grafana ${GRAFANA_VERSION:-unknown}"
exec su-exec "${UID_GID}" /run.sh
