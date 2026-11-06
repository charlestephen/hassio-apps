#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Homebridge (homebridge/homebridge Docker image).
#
# Point /homebridge at the Supervisor /data volume, export a few options as
# env vars, then exec upstream /init (s6-overlay + Homebridge + Config UI).
#   Upstream: https://github.com/homebridge/docker-homebridge
#   Guide:    https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-Docker
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${HOMEBRIDGE_DOCKER_VERSION:-unknown}"

log() { echo "[homebridge-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

# Persist upstream /homebridge on the Supervisor /data volume.
mkdir -p /data
if [ -L /homebridge ]; then
    :
elif [ -d /homebridge ]; then
    if [ -n "$(find /homebridge -mindepth 1 -maxdepth 1 2>/dev/null | head -1)" ]; then
        cp -a /homebridge/. /data/ 2>/dev/null || true
    fi
    rm -rf /homebridge
    ln -s /data /homebridge
else
    ln -s /data /homebridge
fi
log "persisting Homebridge data at /data (-> /homebridge)"

export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        log "set $2=${_v}"
    fi
}

export_if_set 'tz' 'TZ'

if is_true enable_avahi; then
    export ENABLE_AVAHI=1
else
    export ENABLE_AVAHI=0
fi
log "set ENABLE_AVAHI=${ENABLE_AVAHI}"

# Extra env (advanced).
eval "$(
    jq -r '
      (.env_vars // [])[]
      | select((.name // "") | test("^[A-Za-z_][A-Za-z0-9_]*$"))
      | "export " + .name + "=" + (.value // "" | @sh)
    ' "${OPTIONS}" 2>/dev/null || true
)"
jq -c '(.env_vars // [])[]?' "${OPTIONS}" 2>/dev/null | while IFS= read -r row; do
    [ -n "${row}" ] || continue
    name="$(printf '%s' "${row}" | jq -r '.name // empty')"
    secret="$(printf '%s' "${row}" | jq -r '.secret // false')"
    case "${name}" in
        ''|*[!A-Za-z0-9_]*|[0-9]*) continue ;;
    esac
    if [ "${secret}" = "true" ]; then
        log "set ${name} (hidden)"
    else
        case "${name}" in
            *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set ${name} (hidden)";;
            *)
                value="$(printf '%s' "${row}" | jq -r '.value // empty')"
                log "set ${name}=${value}"
                ;;
        esac
    fi
done

log "Starting Homebridge Docker ${VERSION} (upstream /init) ..."
exec /init
