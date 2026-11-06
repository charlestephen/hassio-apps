#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for Ozark Connect Network Optimizer.
#
# Maps HA /data into upstream /app/{data,ssh-keys,logs}, exports compose-parity
# environment variables from /data/options.json, then execs upstream
# /entrypoint.sh (permission fix + gosu app → NetworkOptimizer.Web.dll).
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${NETWORK_OPTIMIZER_VERSION:-unknown}"

log() { echo "[network-optimizer-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*SECRET*|*KEY*) log "set $2 (hidden)";;
            *)                         log "set $2=${_v}";;
        esac
    fi
}

export_on_off() {
    if is_true "$1"; then
        export "$2=true"; log "set $2=true"
    else
        export "$2=false"; log "set $2=false"
    fi
}

# Persist under HA's /data volume (Supervisor map).
mkdir -p /data/data /data/ssh-keys /data/logs
# Optional: seed ssh keys from /ssl if the operator dropped them there.
if [ -d /ssl ] && [ -z "$(ls -A /data/ssh-keys 2>/dev/null || true)" ]; then
    # Do not auto-copy private keys; leave empty for the UI / volume.
    :
fi
for name in data ssh-keys logs; do
    target="/app/${name}"
    source="/data/${name}"
    if [ -L "${target}" ]; then
        ln -sfn "${source}" "${target}"
    elif [ -d "${target}" ]; then
        # Preserve any image seed files into the volume once, then replace.
        if [ -z "$(ls -A "${source}" 2>/dev/null || true)" ] && [ -n "$(ls -A "${target}" 2>/dev/null || true)" ]; then
            cp -a "${target}/." "${source}/" 2>/dev/null || true
        fi
        rm -rf "${target}"
        ln -sfn "${source}" "${target}"
    else
        ln -sfn "${source}" "${target}"
    fi
done

# Upstream entrypoint runs `chown -R app:app /app/data …`, but GNU chown -R
# defaults to -P (do not traverse symlink dirs). Our /app/{data,ssh-keys,logs}
# are symlinks into HA's /data volume, so that chown never reaches the real
# dirs — they stay root-owned and the app user fails on /app/data/keys.
APP_UID="$(id -u app 2>/dev/null || true)"
APP_GID="$(id -g app 2>/dev/null || true)"
if [ -n "${APP_UID}" ] && [ -n "${APP_GID}" ]; then
    chown -R "${APP_UID}:${APP_GID}" /data/data /data/ssh-keys /data/logs
    log "chown /data/{data,ssh-keys,logs} → ${APP_UID}:${APP_GID} (app)"
else
    log "WARNING: user 'app' missing; leaving /data volume ownership unchanged"
fi

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting with image defaults"
fi

export_if_set 'tz' 'TZ'
export_if_set 'app_password' 'APP_PASSWORD'
export_on_off 'bind_localhost_only' 'BIND_LOCALHOST_ONLY'

export_if_set 'host_ip' 'HOST_IP'
export_if_set 'host_name' 'HOST_NAME'
export_if_set 'reverse_proxied_host_name' 'REVERSE_PROXIED_HOST_NAME'
export_if_set 'reverse_proxied_port' 'REVERSE_PROXIED_PORT'
export_if_set 'trusted_proxies' 'TRUSTED_PROXIES'
export_if_set 'trusted_proxy_hops' 'TRUSTED_PROXY_HOPS'
export_on_off 'trust_cf_connecting_ip' 'TRUST_CF_CONNECTING_IP'

export_if_set 'openspeedtest_port' 'OPENSPEEDTEST_PORT'
export_if_set 'openspeedtest_host' 'OPENSPEEDTEST_HOST'
export_on_off 'openspeedtest_https' 'OPENSPEEDTEST_HTTPS'
export_if_set 'openspeedtest_https_port' 'OPENSPEEDTEST_HTTPS_PORT'

if is_true 'iperf3_server_enabled'; then
    export Iperf3Server__Enabled=true
    log "set Iperf3Server__Enabled=true"
else
    export Iperf3Server__Enabled=false
    log "set Iperf3Server__Enabled=false"
fi

export_if_set 'log_level' 'Logging__LogLevel__Default'
export_if_set 'app_log_level' 'Logging__LogLevel__NetworkOptimizer'
export_if_set 'demo_mode_mappings' 'DEMO_MODE_MAPPINGS'

# Advanced: KEY=VALUE lines (comments and blanks ignored).
EXTRA="$(get extra_env)"
if [ -n "${EXTRA}" ]; then
    printf '%s\n' "${EXTRA}" > /tmp/network-optimizer-extra.env
    while IFS= read -r line || [ -n "${line}" ]; do
        case "${line}" in
            ''|\#*) continue ;;
            *=*)
                key="${line%%=*}"
                val="${line#*=}"
                export "${key}=${val}"
                case "${key}" in
                    *PASSWORD*|*SECRET*|*KEY*) log "set ${key} (hidden, extra_env)";;
                    *) log "set ${key}=${val} (extra_env)";;
                esac
                ;;
        esac
    done < /tmp/network-optimizer-extra.env
    rm -f /tmp/network-optimizer-extra.env
fi

# Soft guidance when nothing declares a public host — the LOOHP add-on bug.
if [ -z "${REVERSE_PROXIED_HOST_NAME:-}" ] && [ -z "${HOST_NAME:-}" ] && [ -z "${HOST_IP:-}" ]; then
    log "NOTE: set reverse_proxied_host_name (HTTPS URL) or host_name/host_ip so canonical URLs, CORS, and speed-test result posts follow the URL you assign"
fi

log "Starting Network Optimizer v${VERSION} ..."
exec /entrypoint.sh
