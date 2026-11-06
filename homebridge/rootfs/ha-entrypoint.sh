#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant wrapper for Homebridge (homebridge/homebridge Docker image).
#
# HA state: /data/homebridge (bind-mounted over upstream VOLUME /homebridge).
# TLS: optional cert/key under /ssl → written into UI config.json before /init.
# mDNS: host_network shares the host stack — leave ENABLE_AVAHI=0 and use
# host D-Bus (host_dbus) so HAP talks to the host Avahi instead of starting a
# second daemon ("another mdns processor on the same host").
#   Upstream: https://github.com/homebridge/docker-homebridge
# ==============================================================================
set -euo pipefail

OPTIONS="/data/options.json"
VERSION="${HOMEBRIDGE_DOCKER_VERSION:-unknown}"
STORE="/data/homebridge"
UPSTREAM="/homebridge"
CONFIG_JSON="${STORE}/config.json"

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

require_ssl_path() {
    local label="$1" path="$2"
    case "${path}" in
        /ssl/*) ;;
        *) log "ERROR: ${label} must be under /ssl/ (got ${path})"; exit 1 ;;
    esac
    if [ ! -f "${path}" ]; then
        log "ERROR: ${label} not found: ${path}"
        exit 1
    fi
}

# Ensure config.json has a config-ui platform block with ssl.key / ssl.cert.
apply_ui_ssl() {
    local key="$1" cert="$2"
    if [ ! -f "${CONFIG_JSON}" ]; then
        log "creating ${CONFIG_JSON} with UI HTTPS for first boot"
        cat > "${CONFIG_JSON}" <<EOF
{
  "bridge": {
    "name": "Homebridge",
    "username": "CC:22:3D:E3:CE:30",
    "port": 51826,
    "pin": "031-45-154"
  },
  "platforms": [
    {
      "platform": "config",
      "name": "Config",
      "port": 8581,
      "ssl": {
        "key": "${key}",
        "cert": "${cert}"
      }
    }
  ]
}
EOF
        return
    fi

    local tmp
    tmp="$(mktemp)"
    if ! jq \
        --arg key "${key}" \
        --arg cert "${cert}" '
      .platforms //= []
      | (if any(.platforms[]?; .platform == "config") then . else
          .platforms += [{platform:"config", name:"Config", port:8581}]
        end)
      | .platforms |= map(
          if .platform == "config" then
            .ssl = ((.ssl // {}) + {key:$key, cert:$cert})
            | del(.ssl.pfx, .ssl.passphrase)
          else . end
        )
    ' "${CONFIG_JSON}" > "${tmp}"; then
        rm -f "${tmp}"
        log "ERROR: failed to patch ${CONFIG_JSON} for SSL"
        exit 1
    fi
    mv "${tmp}" "${CONFIG_JSON}"
    log "set UI ssl.key + ssl.cert in ${CONFIG_JSON}"
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

mkdir -p "${STORE}"

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

# Default off: a second Avahi on host_network fights the host mDNS stack.
if is_true enable_avahi; then
    export ENABLE_AVAHI=1
    log "set ENABLE_AVAHI=1 (in-container Avahi — only if the host has no mDNS)"
else
    export ENABLE_AVAHI=0
    log "set ENABLE_AVAHI=0 (use host mDNS via host_dbus)"
fi

CERT="$(get https_cert_file)"
KEY="$(get https_key_file)"
if [ -n "${CERT}" ] || [ -n "${KEY}" ]; then
    if [ -z "${CERT}" ] || [ -z "${KEY}" ]; then
        log "ERROR: set both https_cert_file and https_key_file (under /ssl/...)"
        exit 1
    fi
    require_ssl_path https_cert_file "${CERT}"
    require_ssl_path https_key_file "${KEY}"
    apply_ui_ssl "${KEY}" "${CERT}"
    log "Config UI HTTPS enabled from ${CERT} + ${KEY}"
fi

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
