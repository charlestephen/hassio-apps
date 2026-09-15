#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper entrypoint for the Ozark-Connect Network Optimizer.
# Maps app options (/data/options.json) to the upstream environment
# variables, persists app state under /data, then hands off to the image's
# own startup. Empty/false options fall back to upstream defaults.
#   Ref: https://github.com/Ozark-Connect/NetworkOptimizer
# ==============================================================================
set -e
OPTIONS="/data/options.json"
log() { echo "[network-optimizer-addon] $*"; }
get()     { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }
set_if()  { _v="$(get "$1")"; if [ -n "${_v}" ]; then export "$2=${_v}"; case "$2" in *PASSWORD*) log "set $2 (hidden)";; *) log "set $2=${_v}";; esac; fi; }
set_bool(){ if is_true "$1"; then export "$2=true"; else export "$2=false"; fi; log "set $2"; }
set_int() { _v="$(get "$1")"; if [ -n "${_v}" ] && [ "${_v}" -gt 0 ] 2>/dev/null; then export "$2=${_v}"; log "set $2=${_v}"; fi; }

# Persist upstream state dirs (/app/data, /app/logs, /app/ssh-keys) under HA /data
# FIXED: Added chown BEFORE symlink to prevent race condition with upstream entrypoint
for d in data logs ssh-keys; do
  mkdir -p "/data/${d}"
  chown -R app:app "/data/${d}" 2>/dev/null || true        # Preempt upstream's chown
  if [ ! -L "/app/${d}" ]; then rm -rf "/app/${d}" 2>/dev/null || true; ln -sfn "/data/${d}" "/app/${d}"; fi
done

export TZ="$(get timezone)"; [ -z "${TZ}" ] && export TZ="America/New_York"
set_bool bind_localhost_only        BIND_LOCALHOST_ONLY
set_if   app_password               APP_PASSWORD
set_if   host_ip                    HOST_IP
set_if   host_name                  HOST_NAME
set_if   reverse_proxied_host_name  REVERSE_PROXIED_HOST_NAME
# FIXED: .NET uses hierarchical env vars with double underscores
# OLD: IPERF3_SERVER_ENABLED  →  NEW: Iperf3Server__Enabled
set_bool iperf3_server_enabled      Iperf3Server__Enabled
set_int  openspeedtest_port         OPENSPEEDTEST_PORT
set_if   openspeedtest_host         OPENSPEEDTEST_HOST
set_bool openspeedtest_https        OPENSPEEDTEST_HTTPS
set_int  openspeedtest_https_port   OPENSPEEDTEST_HTTPS_PORT
set_if   log_level                  LOG_LEVEL
set_if   app_log_level              APP_LOG_LEVEL
set_if   demo_mode_mappings         DEMO_MODE_MAPPINGS

log "starting Network Optimizer (initial admin password appears below on first run) ..."

# FIXED: Direct exec to upstream entrypoint — removes extra sh -c layer
# Benefits:
#  1. Signals (SIGTERM) propagate cleanly to .NET process
#  2. No unnecessary shell fork
#  3. Matches upstream's intended startup pattern
# OLD:
#   if [ -n "${UPSTREAM_START:-}" ]; then
#     exec sh -c "${UPSTREAM_START}"
#   elif [ "$#" -gt 0 ]; then
#     exec "$@"
#   else
#     log "ERROR: no upstream start command found."
#     exit 1
#   fi
# NEW:
exec /entrypoint.sh