#!/bin/sh
# shellcheck shell=sh
# Home Assistant wrapper for UnPoller (unpoller/unpoller).
# Maps /data/options.json to UP_* variables, then runs the upstream binary.
set -eu

OPTIONS=/data/options.json
log() { echo "[unpoller-app] $*"; }
warn() { echo "[unpoller-app] WARNING: $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}")" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    echo "[unpoller-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

export_if_set() { # option variable
    value="$(get "$1")"
    if [ -n "${value}" ]; then
        export "$2=${value}"
        case "$2" in
            *PASS*|*KEY*|*SECRET*) log "set $2 (hidden)" ;;
            *) log "set $2=${value}" ;;
        esac
    fi
}
export_bool() { # option variable
    if is_true "$1"; then export "$2=true"; else export "$2=false"; fi
}

URL="$(get controller_url)"
if [ -z "${URL}" ]; then
    echo "[unpoller-app] ERROR: set the controller URL" >&2
    exit 1
fi
if [ -z "$(get controller_api_key)" ] && { [ -z "$(get controller_user)" ] || [ -z "$(get controller_password)" ]; }; then
    echo "[unpoller-app] ERROR: set a controller API key, or a user and password" >&2
    exit 1
fi

export_if_set controller_url UP_UNIFI_DEFAULT_URL
export_if_set controller_api_key UP_UNIFI_DEFAULT_API_KEY
if [ -z "$(get controller_api_key)" ]; then
    export_if_set controller_user UP_UNIFI_DEFAULT_USER
    export_if_set controller_password UP_UNIFI_DEFAULT_PASS
fi
export_bool verify_ssl UP_UNIFI_DEFAULT_VERIFY_SSL
export_bool save_sites UP_UNIFI_DEFAULT_SAVE_SITES
export_bool save_dpi UP_UNIFI_DEFAULT_SAVE_DPI
export_bool save_ids UP_UNIFI_DEFAULT_SAVE_IDS
export_bool save_events UP_UNIFI_DEFAULT_SAVE_EVENTS
export_bool save_alarms UP_UNIFI_DEFAULT_SAVE_ALARMS
export_bool save_anomalies UP_UNIFI_DEFAULT_SAVE_ANOMALIES

i=0
OLD_IFS="${IFS}"
IFS=','
for site in $(get sites); do
    site="$(printf '%s' "${site}" | sed 's/^ *//; s/ *$//')"
    [ -n "${site}" ] || continue
    export "UP_UNIFI_DEFAULT_SITE_${i}=${site}"
    i=$((i + 1))
done
IFS="${OLD_IFS}"
if [ "${i}" -eq 0 ]; then export UP_UNIFI_DEFAULT_SITE_0=all; fi

if is_true prometheus_enabled; then
    export UP_PROMETHEUS_DISABLE=false UP_PROMETHEUS_HTTP_LISTEN=0.0.0.0:9130
    export_if_set prometheus_namespace UP_PROMETHEUS_NAMESPACE
else
    export UP_PROMETHEUS_DISABLE=true
fi

if [ -n "$(get influxdb_url)" ]; then
    export UP_INFLUXDB_DISABLE=false
    export_if_set influxdb_url UP_INFLUXDB_URL
    export_if_set influxdb_user UP_INFLUXDB_USER
    export_if_set influxdb_password UP_INFLUXDB_PASS
    export_if_set influxdb_db UP_INFLUXDB_DB
else
    export UP_INFLUXDB_DISABLE=true
fi

if [ -n "$(get loki_url)" ]; then
    export UP_LOKI_DISABLE=false
    export_if_set loki_url UP_LOKI_URL
    export_if_set loki_user UP_LOKI_USER
    export_if_set loki_password UP_LOKI_PASS
    export_if_set loki_tenant_id UP_LOKI_TENANT_ID
else
    export UP_LOKI_DISABLE=true
fi

export_bool debug UP_POLLER_DEBUG

# ---- Extra environment variables ----------------------------------------------
while IFS= read -r line; do
    [ -n "${line}" ] || continue
    key="${line%%=*}"
    value="${line#*=}"
    case "${key}" in
        ''|*[!A-Za-z0-9_]*|[0-9]*) warn "skipping an env_vars entry with an invalid name"; continue ;;
    esac
    export "${key}=${value}"
    case "${key}" in
        *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set ${key} from env_vars (hidden)" ;;
        *) log "set ${key} from env_vars" ;;
    esac
done <<EOF
$(jq -r '(.env_vars // [])[] | select((.name // "") != "") | .name + "=" + (.value // "")' "${OPTIONS}")
EOF

log "starting UnPoller ${UNPOLLER_VERSION:-}"
# Forward SIGTERM and exit 0 once it stops: the Supervisor reports an app that
# exits 143 on stop as an error.
/usr/bin/unpoller "$@" &
child=$!
stopping=0
trap 'stopping=1; kill -TERM "${child}" 2>/dev/null' TERM INT
code=0
wait "${child}" || code=$?
if [ "${stopping}" = 1 ]; then
    wait "${child}" 2>/dev/null || true
    exit 0
fi
exit "${code}"
