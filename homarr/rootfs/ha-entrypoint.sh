#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper entrypoint for Homarr.
#
# Reads the add-on options from /data/options.json, exports the matching Homarr
# environment variables, then hands off to Homarr's own entrypoint (which
# supervises redis + nginx + Next.js). Empty / false options are treated as
# "unset" so Homarr falls back to its own defaults.
#   Ref: https://homarr.dev/docs/advanced/environment-variables/
#        https://homarr.dev/docs/advanced/single-sign-on/
# ==============================================================================
set -e

OPTIONS="/data/options.json"
HOMARR_VERSION="${HOMARR_VERSION:-unknown}"

log() { echo "[homarr-addon] $*"; }

get()      { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null; }
is_true()  { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

# Export ${2} from option ${1} only when the option has a non-empty value.
export_if_set() {
    _v="$(get "$1")"
    if [ -n "${_v}" ]; then
        export "$2=${_v}"
        case "$2" in
            *PASSWORD*|*SECRET*|*TOKEN*) log "set $2 (hidden)";;
            *)                          log "set $2=${_v}";;
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

# Export ${2}=true only when option ${1} is true (omit otherwise).
export_true() {
    if is_true "$1"; then export "$2=true"; log "set $2=true"; fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} not found; starting Homarr with image defaults."
fi

# --- General ------------------------------------------------------------------
export_if_set 'log_level' 'LOG_LEVEL'
PUID_VAL="$(get 'puid')"; export PUID="${PUID_VAL:-0}"
PGID_VAL="$(get 'pgid')"; export PGID="${PGID_VAL:-0}"
log "run as PUID=${PUID} PGID=${PGID}"
export_true 'no_external_connection' 'NO_EXTERNAL_CONNECTION'
if [ "$(jq -r '.enable_dns_caching // true' "${OPTIONS}" 2>/dev/null)" = "false" ]; then
    export ENABLE_DNS_CACHING="false"; log "set ENABLE_DNS_CACHING=false"
fi

# --- Security: SECRET_ENCRYPTION_KEY (auto-generate + persist if blank) --------
KEY="$(get 'secret_encryption_key')"
if [ -z "${KEY}" ]; then
    KEYFILE="/data/.secret_encryption_key"
    if [ ! -s "${KEYFILE}" ]; then
        openssl rand -hex 32 > "${KEYFILE}"
        chmod 600 "${KEYFILE}"
        log "generated a new SECRET_ENCRYPTION_KEY (persisted to ${KEYFILE})"
    fi
    KEY="$(cat "${KEYFILE}")"
fi
export SECRET_ENCRYPTION_KEY="${KEY}"
log "set SECRET_ENCRYPTION_KEY (hidden)"

# --- Database -----------------------------------------------------------------
# Default: embedded SQLite persisted in HA's /data volume (Homarr's /appdata is
# an ephemeral anonymous volume). Set external_db to point at an external DB.
if is_true 'external_db'; then
    export_if_set 'db_driver'   'DB_DRIVER'
    export_if_set 'db_dialect'  'DB_DIALECT'
    export_if_set 'db_host'     'DB_HOST'
    export_int_if_pos 'db_port' 'DB_PORT'
    export_if_set 'db_name'     'DB_NAME'
    export_if_set 'db_user'     'DB_USER'
    export_if_set 'db_password' 'DB_PASSWORD'
    log "using external database"
else
    mkdir -p /data/db
    export DB_DRIVER="better-sqlite3"
    export DB_DIALECT="sqlite"
    export DB_URL="/data/db/db.sqlite"
    log "using embedded SQLite at ${DB_URL}"
fi

# --- Authentication (common) --------------------------------------------------
export_if_set 'auth_providers'          'AUTH_PROVIDERS'
export_if_set 'auth_session_expiry_time' 'AUTH_SESSION_EXPIRY_TIME'
export_if_set 'auth_logout_redirect_url' 'AUTH_LOGOUT_REDIRECT_URL'
export_if_set 'auth_cookie_prefix'      'AUTH_COOKIE_PREFIX'

# --- OIDC / SSO ---------------------------------------------------------------
export_if_set 'oidc_client_name'               'AUTH_OIDC_CLIENT_NAME'
export_if_set 'oidc_issuer'                    'AUTH_OIDC_ISSUER'
export_if_set 'oidc_client_id'                 'AUTH_OIDC_CLIENT_ID'
export_if_set 'oidc_client_secret'             'AUTH_OIDC_CLIENT_SECRET'
export_if_set 'oidc_scope_overwrite'           'AUTH_OIDC_SCOPE_OVERWRITE'
export_if_set 'oidc_groups_attribute'          'AUTH_OIDC_GROUPS_ATTRIBUTE'
export_if_set 'oidc_name_attribute_overwrite'  'AUTH_OIDC_NAME_ATTRIBUTE_OVERWRITE'
export_if_set 'oidc_token_endpoint_auth_method' 'AUTH_OIDC_TOKEN_ENDPOINT_AUTH_METHOD'
export_true   'oidc_auto_login'                'AUTH_OIDC_AUTO_LOGIN'
export_true   'oidc_groups_local_management'   'AUTH_OIDC_GROUPS_LOCAL_MANAGEMENT'
export_true   'oidc_force_userinfo'            'AUTH_OIDC_FORCE_USERINFO'
export_true   'oidc_enable_dangerous_account_linking' 'AUTH_OIDC_ENABLE_DANGEROUS_ACCOUNT_LINKING'

# --- LDAP ---------------------------------------------------------------------
export_if_set 'ldap_uri'                       'AUTH_LDAP_URI'
export_if_set 'ldap_base'                       'AUTH_LDAP_BASE'
export_if_set 'ldap_bind_dn'                    'AUTH_LDAP_BIND_DN'
export_if_set 'ldap_bind_password'              'AUTH_LDAP_BIND_PASSWORD'
export_if_set 'ldap_username_attribute'         'AUTH_LDAP_USERNAME_ATTRIBUTE'
export_if_set 'ldap_user_mail_attribute'        'AUTH_LDAP_USER_MAIL_ATTRIBUTE'
export_if_set 'ldap_group_class'                'AUTH_LDAP_GROUP_CLASS'
export_if_set 'ldap_group_member_attribute'     'AUTH_LDAP_GROUP_MEMBER_ATTRIBUTE'
export_if_set 'ldap_group_member_user_attribute' 'AUTH_LDAP_GROUP_MEMBER_USER_ATTRIBUTE'
export_if_set 'ldap_search_scope'               'AUTH_LDAP_SEARCH_SCOPE'
export_if_set 'ldap_username_filter_extra_arg'  'AUTH_LDAP_USERNAME_FILTER_EXTRA_ARG'
export_if_set 'ldap_group_filter_extra_arg'     'AUTH_LDAP_GROUP_FILTER_EXTRA_ARG'

# --- External Redis -----------------------------------------------------------
if is_true 'redis_is_external'; then
    export REDIS_IS_EXTERNAL="true"
    export_if_set 'redis_host'        'REDIS_HOST'
    export_int_if_pos 'redis_port'    'REDIS_PORT'
    export_if_set 'redis_username'    'REDIS_USERNAME'
    export_if_set 'redis_password'    'REDIS_PASSWORD'
    export_if_set 'redis_database_index' 'REDIS_DATABASE_INDEX'
    export_if_set 'redis_tls_ca'      'REDIS_TLS_CA'
    log "using external Redis"
fi

# --- Docker integration -------------------------------------------------------
export_if_set 'docker_hostnames'    'DOCKER_HOSTNAMES'
export_if_set 'docker_ports'        'DOCKER_PORTS'
export_if_set 'docker_socket_paths' 'DOCKER_SOCKET_PATHS'

# --- Outbound proxy -----------------------------------------------------------
export_if_set 'http_proxy'  'HTTP_PROXY'
export_if_set 'https_proxy' 'HTTPS_PROXY'
export_if_set 'no_proxy'    'NO_PROXY'

# --- Make data locations writable by the runtime user ------------------------
# Homarr's own entrypoint su-execs the app to PUID:PGID and its run.sh does
# `mkdir -p /appdata/db` and creates the SQLite DB. But HA's /data (where we
# redirect the DB) and Homarr's /appdata volume are root-owned, so a non-root
# PUID cannot create the database. This wrapper runs as root *before* Homarr
# drops privileges, so fix ownership here to whatever PUID:PGID is configured.
mkdir -p /data/db /appdata/db /appdata/redis /appdata/trusted-certificates
if [ "${PUID}:${PGID}" != "0:0" ]; then
    log "ensuring /data and /appdata are owned by ${PUID}:${PGID} ..."
    chown -R "${PUID}:${PGID}" /data /appdata 2>/dev/null || \
        log "WARNING: could not chown /data or /appdata (is the add-on running as root?)"
fi

log "Starting Homarr v${HOMARR_VERSION} ..."
# Hand off to Homarr's own entrypoint (ENTRYPOINT /app/entrypoint.sh, CMD sh run.sh)
exec /app/entrypoint.sh sh run.sh
