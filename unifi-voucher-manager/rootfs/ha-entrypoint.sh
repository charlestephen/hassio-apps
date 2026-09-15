#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# HA wrapper for etiennecollin/unifi-voucher-manager. Maps app options to
# the upstream env vars, then hands off to the image's own startup (which runs
# both the Rust backend and the Next.js frontend).
#   Ref: https://github.com/etiennecollin/unifi-voucher-manager
# ==============================================================================
set -e
OPTIONS="/data/options.json"
log() { echo "[unifi-voucher-manager-addon] $*"; }
get()     { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }
set_if()  { _v="$(get "$1")"; if [ -n "${_v}" ]; then export "$2=${_v}"; case "$2" in *API_KEY*|*PASSWORD*) log "set $2 (hidden)";; *) log "set $2=${_v}";; esac; fi; }
set_bool(){ export "$2=$(is_true "$1" && echo true || echo false)"; log "set $2"; }
set_int() { _v="$(get "$1")"; if [ -n "${_v}" ] && [ "${_v}" -gt 0 ] 2>/dev/null; then export "$2=${_v}"; log "set $2=${_v}"; fi; }

# UniFi
set_if unifi_controller_url           UNIFI_CONTROLLER_URL
set_if unifi_api_key                  UNIFI_API_KEY
set_bool unifi_has_valid_cert         UNIFI_HAS_VALID_CERT
set_if unifi_site_id                  UNIFI_SITE_ID
set_if guest_subnetwork               GUEST_SUBNETWORK

# WiFi (QR codes)
set_if wifi_ssid                      WIFI_SSID
set_if wifi_password                  WIFI_PASSWORD
set_if wifi_type                      WIFI_TYPE
set_bool wifi_hidden                  WIFI_HIDDEN

# Vouchers
set_int rolling_voucher_duration_minutes ROLLING_VOUCHER_DURATION_MINUTES

# Service
set_if timezone                       TIMEZONE
set_if backend_log_level              BACKEND_LOG_LEVEL
set_if frontend_bind_host             FRONTEND_BIND_HOST
set_int frontend_bind_port            FRONTEND_BIND_PORT
set_if frontend_to_backend_url        FRONTEND_TO_BACKEND_URL
set_if backend_bind_host              BACKEND_BIND_HOST
set_int backend_bind_port             BACKEND_BIND_PORT

log "starting UniFi Voucher Manager (frontend :${FRONTEND_BIND_PORT:-3000}, backend :${BACKEND_BIND_PORT:-8080}) ..."

# FIXED: Direct exec to upstream entrypoint — inherits ENTRYPOINT + CMD
# Upstream structure:
#   ENTRYPOINT ["./entrypoint.sh"]
#   CMD ["./run_wrapper.sh"]
# Our wrapper sets env vars, then execs the upstream entrypoint, which:
#   1. Writes runtime-config.js for the frontend
#   2. execs "./run_wrapper.sh" (the CMD)
# Benefits:
#   - No extra shell layer
#   - Clean signal propagation (SIGTERM reaches Rust/Node)
#   - Matches upstream's intended startup pattern
exec /entrypoint.sh