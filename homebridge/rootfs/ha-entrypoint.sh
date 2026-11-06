#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant wrapper for Homebridge (homebridge/homebridge Docker image).
#
# HA state lives at /data/homebridge (Supervisor /data). Upstream hard-codes
# /homebridge and declares it as a Docker VOLUME, so we bind-mount our dir over
# that path (SYS_ADMIN) instead of rm/symlink. Then exec upstream /init.
#   Upstream: https://github.com/homebridge/docker-homebridge
# ==============================================================================
set -euo pipefail

OPTIONS="/data/options.json"
VERSION="${HOMEBRIDGE_DOCKER_VERSION:-unknown}"
STORE="/data/homebridge"
UPSTREAM="/homebridge"

log() { echo "[homebridge-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

dir_has_entries() {
    local d="$1" f
    [[ -d "$d" ]] || return 1
    for f in "$d"/* "$d"/.[!.]* "$d"/..?*; do
        [[ -e "$f" ]] || continue
        return 0
    done
    return 1
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

mkdir -p "${STORE}"

# One-time: pull anything left on the anonymous VOLUME into our store.
if ! dir_has_entries "${STORE}" && dir_has_entries "${UPSTREAM}"; then
    log "migrating ${UPSTREAM} -> ${STORE}"
    cp -a "${UPSTREAM}/." "${STORE}/" || true
fi

if mountpoint -q "${UPSTREAM}" 2>/dev/null; then
    log "${UPSTREAM} already mounted"
elif mount --bind "${STORE}" "${UPSTREAM}"; then
    log "bind-mounted ${STORE} over ${UPSTREAM}"
else
    log "ERROR: bind-mount ${STORE} -> ${UPSTREAM} failed (need SYS_ADMIN; turn Protection mode off)"
    exit 1
fi

_v="$(get tz)"
if [ -n "${_v}" ]; then
    export TZ="${_v}"
    log "set TZ=${TZ}"
fi

if is_true enable_avahi; then
    export ENABLE_AVAHI=1
else
    export ENABLE_AVAHI=0
fi
log "set ENABLE_AVAHI=${ENABLE_AVAHI}"

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

log "Starting Homebridge Docker ${VERSION}; store=${STORE} ..."
exec /init
