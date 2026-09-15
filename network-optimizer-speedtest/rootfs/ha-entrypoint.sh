#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# HA wrapper for the Ozark-Connect speedtest (OpenSpeedTest) companion image.
# Maps app options to env, then hands off to the upstream startup.
# Upstream: nginx-unprivileged with ENTRYPOINT=/docker-entrypoint.sh
#           CMD=nginx -g 'daemon off;'
# ==============================================================================
set -e
OPTIONS="/data/options.json"
log() { echo "[network-optimizer-speedtest-addon] $*"; }
get()     { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }
set_if()  { _v="$(get "$1")"; if [ -n "${_v}" ]; then export "$2=${_v}"; log "set $2=${_v}"; fi; }
set_bool(){ if is_true "$1"; then export "$2=true"; else export "$2=false"; fi; log "set $2"; }
set_int() { _v="$(get "$1")"; if [ -n "${_v}" ] && [ "${_v}" -gt 0 ] 2>/dev/null; then export "$2=${_v}"; log "set $2=${_v}"; fi; }

export TZ="$(get timezone)"; [ -z "${TZ}" ] && export TZ="America/New_York"
set_if   host_name                 HOST_NAME
set_if   host_ip                   HOST_IP
set_int  openspeedtest_port        OPENSPEEDTEST_PORT
set_if   openspeedtest_host        OPENSPEEDTEST_HOST
set_bool openspeedtest_https       OPENSPEEDTEST_HTTPS
set_int  openspeedtest_https_port  OPENSPEEDTEST_HTTPS_PORT
set_if   reverse_proxied_host_name REVERSE_PROXIED_HOST_NAME

log "starting OpenSpeedTest companion ..."

# FIXED: Direct exec to nginx's own entrypoint, passing inherited CMD as args.
# Upstream structure:
#   ENTRYPOINT ["/docker-entrypoint.sh"]
#   CMD ["nginx", "-g", "daemon off;"]
# With our ENTRYPOINT set, Docker passes CMD as "$@" to our script.
# We forward directly — nginx's entrypoint handles privilege dropping and
# worker management. tini (HA init:true) handles PID 1 signal forwarding.
# OLD:
#   if [ -n "${UPSTREAM_START:-}" ]; then
#     exec sh -c "${UPSTREAM_START}"
#   elif [ "$#" -gt 0 ]; then
#     exec "$@"
#   else
#     log "ERROR: no upstream start command ..."
#     exit 1
#   fi
# NEW:
exec /docker-entrypoint.sh "$@"