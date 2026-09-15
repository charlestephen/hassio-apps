#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper entrypoint for the Traefik Manager Agent (TMA).
#
# Reads the app options from /data/options.json, exports the matching TMA
# environment variables, then execs the tma binary. TMA has no settings file
# of its own — it is driven entirely by environment variables, and anything
# it is not configured for simply does not appear in the Traefik Manager UI
# for that server.
#   Ref: https://traefik-manager.xyzlab.dev/agent.html
# ==============================================================================
set -e

OPTIONS="/data/options.json"
TMA_VERSION="${TMA_VERSION:-unknown}"

log() { echo "[traefik-manager-agent-app] $*"; }

get()      { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }

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

export_int_if_pos() {
    _v="$(get "$1")"
    if [ -n "${_v}" ] && [ "${_v}" -gt 0 ] 2>/dev/null; then
        export "$2=${_v}"; log "set $2=${_v}"
    fi
}

export_bool_if_set() {
    _v="$(jq -r --arg k "$1" 'if has($k) then (.[$k] | tostring) else empty end' "${OPTIONS}" 2>/dev/null)"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"; log "set $2=${_v}"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} not found; starting with image defaults."
fi

# --- Required -------------------------------------------------------------------
TMA_API_KEY_VAL="$(get 'tma_api_key')"
if [ -z "${TMA_API_KEY_VAL}" ]; then
    log "FATAL: tma_api_key is required (generated in Traefik Manager under Settings -> Agents)."
    exit 1
fi
export TMA_API_KEY="${TMA_API_KEY_VAL}"
log "set TMA_API_KEY (hidden)"

# --- Agent server -----------------------------------------------------------------
export_int_if_pos 'tma_port'       'TMA_PORT'
export_int_if_pos 'tma_rate_limit' 'TMA_RATE_LIMIT'
export_bool_if_set 'tma_debug'     'TMA_DEBUG'

# --- Traefik connection -------------------------------------------------------------
export_if_set 'traefik_api_url'                'TRAEFIK_API_URL'
export_if_set 'traefik_api_user'               'TRAEFIK_API_USER'
export_if_set 'traefik_api_password'           'TRAEFIK_API_PASSWORD'
export_bool_if_set 'traefik_insecure_skip_verify' 'TRAEFIK_INSECURE_SKIP_VERIFY'

# --- Config files ------------------------------------------------------------------
export_if_set 'config_path'         'CONFIG_PATH'
export_if_set 'static_config_path'  'STATIC_CONFIG_PATH'

# --- Optional paths -----------------------------------------------------------------
export_if_set 'acme_json_path'      'ACME_JSON_PATH'
export_if_set 'access_log_path'     'ACCESS_LOG_PATH'
export_if_set 'plugins_dir'         'PLUGINS_DIR'

# --- Backups (persisted under this app's /data volume by default) -------------------
export_if_set 'backup_dir'          'BACKUP_DIR'
export_int_if_pos 'backup_keep_count' 'BACKUP_KEEP_COUNT'

# --- Traefik restart -----------------------------------------------------------------
export_if_set 'restart_method'      'RESTART_METHOD'
export_if_set 'traefik_container'   'TRAEFIK_CONTAINER'
export_if_set 'docker_host'         'DOCKER_HOST'
export_if_set 'signal_file_path'    'SIGNAL_FILE_PATH'

# --- CrowdSec ---------------------------------------------------------------------
export_if_set 'crowdsec_lapi_url'         'CROWDSEC_LAPI_URL'
export_if_set 'crowdsec_api_key'          'CROWDSEC_API_KEY'
export_if_set 'crowdsec_machine_id'       'CROWDSEC_MACHINE_ID'
export_if_set 'crowdsec_machine_password' 'CROWDSEC_MACHINE_PASSWORD'
export_if_set 'crowdsec_client_cert'      'CROWDSEC_CLIENT_CERT'
export_if_set 'crowdsec_client_key'       'CROWDSEC_CLIENT_KEY'
export_if_set 'crowdsec_ca_cert'          'CROWDSEC_CA_CERT'
export_int_if_pos 'crowdsec_read_timeout' 'CROWDSEC_READ_TIMEOUT'
export_int_if_pos 'crowdsec_alert_limit'  'CROWDSEC_ALERT_LIMIT'

# --- Git backup (agent-managed; only if this agent pushes its own repo) -------------
export_bool_if_set 'git_backup_enabled'        'GIT_BACKUP_ENABLED'
export_if_set 'git_backup_repo'                'GIT_BACKUP_REPO'
export_if_set 'git_backup_branch'              'GIT_BACKUP_BRANCH'
export_if_set 'git_backup_username'            'GIT_BACKUP_USERNAME'
export_if_set 'git_backup_token'               'GIT_BACKUP_TOKEN'
export_bool_if_set 'git_backup_auto_push'      'GIT_BACKUP_AUTO_PUSH'
export_if_set 'git_backup_commit_message'      'GIT_BACKUP_COMMIT_MESSAGE'

log "Starting Traefik Manager Agent v${TMA_VERSION} ..."
exec tma
