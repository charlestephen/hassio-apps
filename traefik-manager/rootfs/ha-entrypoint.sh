#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper entrypoint for Traefik Manager.
#
# Reads the app options from /data/options.json, exports the matching Traefik
# Manager environment variables, then execs gunicorn (upstream's own CMD).
# Empty / false options are treated as "unset" so Traefik Manager falls back
# to its own defaults (the setup wizard runs on first start with nothing set).
#   Ref: https://traefik-manager.xyzlab.dev/env-vars.html
# ==============================================================================
set -e

OPTIONS="/data/options.json"
TRAEFIK_MANAGER_VERSION="${TRAEFIK_MANAGER_VERSION:-unknown}"

log() { echo "[traefik-manager-app] $*"; }

get()      { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }
is_true()  { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

# Export ${2} from option ${1} only when the option has a non-empty value.
export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*SECRET*|*TOKEN*|*KEY*) log "set $2 (hidden)";;
            *)                                 log "set $2=${_v}";;
        esac
    fi
}

# Export ${2}=<int> from option ${1} only when it is a positive integer.
export_int_if_pos() {
    _v="$(get "$1")"
    if [ -n "${_v}" ] && [ "${_v}" -gt 0 ] 2>/dev/null; then
        export "$2=${_v}"; log "set $2=${_v}"
    fi
}

# Export ${2}=true only when option ${1} is true (omit otherwise, so the
# upstream default of true for AUTH_ENABLED / COOKIE_SECURE etc still wins).
export_bool_if_set() {
    _v="$(jq -r --arg k "$1" 'if has($k) then (.[$k] | tostring) else empty end' "${OPTIONS}" 2>/dev/null)"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"; log "set $2=${_v}"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} not found; starting with image defaults."
fi

# --- Connection ---------------------------------------------------------------
export_if_set 'traefik_api_url'             'TRAEFIK_API_URL'
export_if_set 'traefik_api_user'            'TRAEFIK_API_USER'
export_if_set 'traefik_api_password'        'TRAEFIK_API_PASSWORD'
export_bool_if_set 'traefik_insecure_skip_verify' 'TRAEFIK_INSECURE_SKIP_VERIFY'
export_if_set 'domains'                     'DOMAINS'
export_if_set 'cert_resolver'               'CERT_RESOLVER'

# --- Config files (all persisted under HA's /data volume) ---------------------
export_if_set 'config_path'                 'CONFIG_PATH'
export_if_set 'config_paths'                'CONFIG_PATHS'
export_if_set 'config_dir'                  'CONFIG_DIR'
export_if_set 'settings_path'               'SETTINGS_PATH'

# --- Optional file paths --------------------------------------------------------
export_if_set 'acme_json_path'              'ACME_JSON_PATH'
export_if_set 'access_log_path'             'ACCESS_LOG_PATH'
export_if_set 'static_config_path'          'STATIC_CONFIG_PATH'
export_if_set 'plugins_dir'                 'PLUGINS_DIR'

# --- Backups --------------------------------------------------------------------
export_if_set 'backup_dir'                  'BACKUP_DIR'
export_int_if_pos 'backup_keep_count'       'BACKUP_KEEP_COUNT'

# --- Authentication ---------------------------------------------------------------
export_bool_if_set 'auth_enabled'           'AUTH_ENABLED'
export_if_set 'admin_password'              'ADMIN_PASSWORD'
export_if_set 'secret_key'                  'SECRET_KEY'
export_if_set 'otp_encryption_key'          'OTP_ENCRYPTION_KEY'
export_bool_if_set 'cookie_secure'          'COOKIE_SECURE'
export_int_if_pos 'inactivity_timeout_minutes' 'INACTIVITY_TIMEOUT_MINUTES'
export_int_if_pos 'proxy_fix_hops'          'PROXY_FIX_HOPS'

# --- Traefik restart (Static Config editor) --------------------------------------
export_if_set 'restart_method'              'RESTART_METHOD'
export_if_set 'traefik_container'           'TRAEFIK_CONTAINER'
export_if_set 'docker_host'                 'DOCKER_HOST'
export_if_set 'signal_file_path'            'SIGNAL_FILE_PATH'

# --- CrowdSec ---------------------------------------------------------------------
export_if_set 'crowdsec_lapi_url'           'CROWDSEC_LAPI_URL'
export_if_set 'crowdsec_api_key'            'CROWDSEC_API_KEY'
export_if_set 'crowdsec_machine_id'         'CROWDSEC_MACHINE_ID'
export_if_set 'crowdsec_machine_password'   'CROWDSEC_MACHINE_PASSWORD'
export_if_set 'crowdsec_client_cert'        'CROWDSEC_CLIENT_CERT'
export_if_set 'crowdsec_client_key'         'CROWDSEC_CLIENT_KEY'
export_if_set 'crowdsec_ca_cert'            'CROWDSEC_CA_CERT'
export_int_if_pos 'crowdsec_read_timeout'   'CROWDSEC_READ_TIMEOUT'
export_int_if_pos 'crowdsec_connect_timeout' 'CROWDSEC_CONNECT_TIMEOUT'
export_int_if_pos 'crowdsec_alert_limit'    'CROWDSEC_ALERT_LIMIT'

# --- OIDC / SSO ---------------------------------------------------------------------
export_bool_if_set 'oidc_enabled'           'OIDC_ENABLED'
export_if_set 'oidc_provider_url'           'OIDC_PROVIDER_URL'
export_if_set 'oidc_client_id'              'OIDC_CLIENT_ID'
export_if_set 'oidc_client_secret'          'OIDC_CLIENT_SECRET'
export_if_set 'oidc_display_name'           'OIDC_DISPLAY_NAME'
export_if_set 'oidc_allowed_emails'         'OIDC_ALLOWED_EMAILS'
export_if_set 'oidc_allowed_groups'         'OIDC_ALLOWED_GROUPS'
export_bool_if_set 'oidc_allow_any_authenticated' 'OIDC_ALLOW_ANY_AUTHENTICATED'
export_if_set 'oidc_groups_claim'           'OIDC_GROUPS_CLAIM'
export_bool_if_set 'oidc_auto_login'        'OIDC_AUTO_LOGIN'

# --- Geolocation / Agents / Misc ------------------------------------------------
export_if_set 'geoip_db_path'               'GEOIP_DB_PATH'
export_int_if_pos 'agent_api_rate_limit'    'AGENT_API_RATE_LIMIT'
export_if_set 'base_path'                   'BASE_PATH'
export_if_set 'log_level'                   'LOG_LEVEL'
export_if_set 'requests_ca_bundle'          'REQUESTS_CA_BUNDLE'

log "Starting Traefik Manager v${TRAEFIK_MANAGER_VERSION} ..."
cd /app
exec gunicorn --bind 0.0.0.0:5000 --workers 2 --log-level info app:app
