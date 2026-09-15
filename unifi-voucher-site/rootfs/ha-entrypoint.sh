#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# HA wrapper for glenndehaan/unifi-voucher-site. Maps every app option to
# the corresponding upstream env var (incl. internal auth + OIDC), then hands
# off to the image's own startup. Empty/false => unset => upstream default.
#   Ref: https://github.com/glenndehaan/unifi-voucher-site
# ==============================================================================
set -e
OPTIONS="/data/options.json"
log() { echo "[unifi-voucher-site-addon] $*"; }
get()     { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }
set_if()  { _v="$(get "$1")"; if [ -n "${_v}" ]; then export "$2=${_v}"; case "$2" in *PASSWORD*|*TOKEN*|*SECRET*) log "set $2 (hidden)";; *) log "set $2=${_v}";; esac; fi; }
set_bool(){ export "$2=$(is_true "$1" && echo true || echo false)"; log "set $2"; }
set_int() { _v="$(get "$1")"; if [ -n "${_v}" ] && [ "${_v}" -gt 0 ] 2>/dev/null; then export "$2=${_v}"; log "set $2=${_v}"; fi; }

# UniFi connection
set_if   unifi_ip                          UNIFI_IP
set_int  unifi_port                        UNIFI_PORT
set_if   unifi_token                       UNIFI_TOKEN
set_if   unifi_site_id                     UNIFI_SITE_ID
set_if   unifi_ssid                        UNIFI_SSID
set_if   unifi_ssid_password               UNIFI_SSID_PASSWORD

# Internal auth
set_bool auth_internal_enabled             AUTH_INTERNAL_ENABLED
set_if   auth_internal_password            AUTH_INTERNAL_PASSWORD
set_if   auth_internal_bearer_token        AUTH_INTERNAL_BEARER_TOKEN

# OIDC / SSO
set_bool auth_oidc_enabled                 AUTH_OIDC_ENABLED
set_if   auth_oidc_issuer_base_url         AUTH_OIDC_ISSUER_BASE_URL
set_if   auth_oidc_app_base_url            AUTH_OIDC_APP_BASE_URL
set_if   auth_oidc_client_id               AUTH_OIDC_CLIENT_ID
set_if   auth_oidc_client_secret           AUTH_OIDC_CLIENT_SECRET
set_bool auth_oidc_redirect_login          AUTH_OIDC_REDIRECT_LOGIN
set_bool auth_oidc_restrict_visibility     AUTH_OIDC_RESTRICT_VISIBILITY

# Global auth
set_bool auth_disable                      AUTH_DISABLE

# Voucher generation
set_if   voucher_types                     VOUCHER_TYPES
set_bool voucher_custom                    VOUCHER_CUSTOM
set_bool voucher_note_required             VOUCHER_NOTE_REQUIRED

# Services
set_bool service_web                       SERVICE_WEB
set_bool service_api                       SERVICE_API

# Printers
set_if   printers                          PRINTERS
set_if   printers_layout                   PRINTERS_LAYOUT

# SMTP
set_if   smtp_from                         SMTP_FROM
set_if   smtp_host                         SMTP_HOST
set_int  smtp_port                         SMTP_PORT
set_bool smtp_secure                       SMTP_SECURE
set_if   smtp_username                     SMTP_USERNAME
set_if   smtp_password                     SMTP_PASSWORD

# Kiosk
set_bool kiosk_enabled                     KIOSK_ENABLED
set_if   kiosk_voucher_types               KIOSK_VOUCHER_TYPES
set_bool kiosk_name_required               KIOSK_NAME_REQUIRED
set_int  kiosk_timeout                     KIOSK_TIMEOUT
set_bool kiosk_homepage                    KIOSK_HOMEPAGE
set_bool kiosk_email                       KIOSK_EMAIL
set_if   kiosk_printer                     KIOSK_PRINTER

# Application
set_if   bind_address                      BIND_ADDRESS
set_if   log_level                         LOG_LEVEL
set_if   translation_default               TRANSLATION_DEFAULT
set_if   translation_hidden_languages      TRANSLATION_HIDDEN_LANGUAGES
set_bool translation_debug                 TRANSLATION_DEBUG

# Cleanup tasks
set_bool task_cleanup_expired              TASK_CLEANUP_EXPIRED
set_bool task_cleanup_unused               TASK_CLEANUP_UNUSED
set_int  task_cleanup_unused_days          TASK_CLEANUP_UNUSED_DAYS

log "starting UniFi Voucher Site ..."

# FIXED: Direct exec to node — no dumb-init needed.
# Upstream structure:
#   No ENTRYPOINT; CMD ["dumb-init", "node", "/app/server.js"]
# With our ENTRYPOINT, Docker passes CMD as args ($@).
# HA init:true (tini) handles PID 1 / signal reaping, so dumb-init is redundant.
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
exec node /app/server.js