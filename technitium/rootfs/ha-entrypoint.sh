#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# Home Assistant wrapper for Technitium DNS Server (technitium/dns-server).
#
# Maps the app options to Technitium's environment variables, starts a small
# background task that does the Home Assistant specific setup through
# Technitium's REST API, then runs upstream's own command. The server itself is
# not touched: DNS_SERVER_* variables are read by Technitium only when the
# config does not exist yet.
# Reference: https://github.com/TechnitiumSoftware/DnsServer/blob/master/DockerEnvironmentVariables.md
# ==============================================================================
set -euo pipefail

OPTIONS="/data/options.json"
CONFIG_DIR="/data/technitium"
API="http://127.0.0.1:5380/api"
APP_NAME="Query Logs (PostgreSQL)"
PG_PASSWORD_FILE="/data/.postgres_password"

log() { echo "[technitium-app] $*"; }
warn() { echo "[technitium-app] WARNING: $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}")" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    echo "[technitium-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

mkdir -p "${CONFIG_DIR}"

# ---- One-shot recovery: move webservice.config aside so it is seeded again ----
if is_true reset_webservice_config; then
    config="${CONFIG_DIR}/webservice.config"
    marker="${CONFIG_DIR}/.webservice-config-reset"
    if [ -f "${config}" ] && [ ! -f "${marker}" ]; then
        backup="${config}.bak.$(date +%Y%m%d%H%M%S)"
        warn "Resetting the web service config; the old one is kept as ${backup}."
        mv "${config}" "${backup}"
        touch "${marker}"
    elif [ ! -f "${marker}" ]; then
        touch "${marker}"
    fi
fi

# ---- Options -> environment ---------------------------------------------------
export_if_set() { # option variable
    local value
    value="$(get "$1")"
    if [ -n "${value}" ]; then
        export "$2=${value}"
        log "set $2=${value}"
    fi
}
export_bool() { # option variable
    if [ -n "$(jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}")" ]; then
        if is_true "$1"; then export "$2=true"; else export "$2=false"; fi
        log "set $2=${!2}"
    fi
}

export DNS_SERVER_WEB_SERVICE_LOCAL_ADDRESSES
DNS_SERVER_WEB_SERVICE_LOCAL_ADDRESSES="$(get web_service_local_addresses)"
DNS_SERVER_WEB_SERVICE_LOCAL_ADDRESSES="${DNS_SERVER_WEB_SERVICE_LOCAL_ADDRESSES:-0.0.0.0}"

export_if_set dns_server_domain DNS_SERVER_DOMAIN
export_if_set dns_server_recursion DNS_SERVER_RECURSION
export_if_set dns_server_forwarders DNS_SERVER_FORWARDERS
export_if_set dns_server_forwarder_protocol DNS_SERVER_FORWARDER_PROTOCOL
export_if_set dns_server_block_list_urls DNS_SERVER_BLOCK_LIST_URLS
export_bool dns_server_prefer_ipv6 DNS_SERVER_PREFER_IPV6
export_bool dns_server_enable_blocking DNS_SERVER_ENABLE_BLOCKING
export_bool dns_server_optional_protocol_dns_over_http DNS_SERVER_OPTIONAL_PROTOCOL_DNS_OVER_HTTP

# The admin password goes in as a file so it does not sit in the process
# environment.
ADMIN_PASSWORD="$(get dns_server_admin_password)"
if [ -n "${ADMIN_PASSWORD}" ]; then
    umask 077
    printf '%s' "${ADMIN_PASSWORD}" > /run/technitium-admin-password
    export DNS_SERVER_ADMIN_PASSWORD_FILE=/run/technitium-admin-password
    umask 022
    log "set DNS_SERVER_ADMIN_PASSWORD_FILE (password hidden)"
fi

# Free-form DNS_SERVER_* passthrough, for example the SSO and LDAP settings.
while IFS= read -r line; do
    [ -n "${line}" ] || continue
    key="${line%%=*}"
    value="${line#*=}"
    if [[ "${key}" =~ ^DNS_SERVER_[A-Z0-9_]+$ && "${key}" != "${line}" ]]; then
        export "${key}=${value}"
        case "${key}" in
            *PASSWORD*|*SECRET*) log "set ${key} from extra_env (hidden)" ;;
            *) log "set ${key} from extra_env" ;;
        esac
    else
        warn "skipping a malformed extra_env entry"
    fi
done < <(jq -r '(.extra_env // [])[]' "${OPTIONS}")

# ---- Setup that needs the running server --------------------------------------
api() { # method path [curl args...]
    local method="$1" path="$2"
    shift 2
    curl -sf --max-time 20 -X "${method}" -H "Authorization: Bearer ${TOKEN}" "$@" "${API}${path}"
}

configure_query_logs() {
    local pg_host pg_port pg_db pg_user pg_pw admin_user admin_pw days current merged url
    admin_pw="$(get postgres_admin_password)"
    if [ -z "${admin_pw}" ]; then
        log "query logs: set the PostgreSQL admin password to log queries to the PostgreSQL app"
        return 0
    fi
    admin_user="$(get postgres_admin_user)"
    pg_host="$(get postgres_host)"
    pg_port="$(get postgres_port)"
    pg_db="$(get postgres_db)"
    pg_user="$(get postgres_user)"
    pg_pw="$(get postgres_password)"
    days="$(get query_log_days)"
    if [ -z "${pg_pw}" ]; then
        if [ ! -s "${PG_PASSWORD_FILE}" ]; then
            (umask 077 && head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n' > "${PG_PASSWORD_FILE}")
        fi
        pg_pw="$(cat "${PG_PASSWORD_FILE}")"
    fi

    local tries=0 out
    until out="$(PGPASSWORD="${admin_pw}" psql -X -q -h "${pg_host}" -p "${pg_port}" -U "${admin_user}" -d postgres -c 'SELECT 1' 2>&1)"; do
        case "${out}" in
            *"authentication failed"*) warn "query logs: PostgreSQL refused '${admin_user}'; check the admin password"; return 0 ;;
        esac
        tries=$((tries + 1))
        if [ "${tries}" -ge 30 ]; then
            warn "query logs: cannot reach PostgreSQL at ${pg_host}:${pg_port}; skipping"
            return 0
        fi
        sleep 2
    done
    PGPASSWORD="${admin_pw}" psql -X -q -v ON_ERROR_STOP=1 -h "${pg_host}" -p "${pg_port}" -U "${admin_user}" \
        -d postgres -v u="${pg_user}" -v p="${pg_pw}" -v d="${pg_db}" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('ALTER ROLE %I LOGIN PASSWORD %L', :'u', :'p')
WHERE EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'u') \gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'d', :'u')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'d') \gexec
SELECT format('ALTER DATABASE %I OWNER TO %I', :'d', :'u') \gexec
SQL
    PGPASSWORD="${admin_pw}" psql -X -q -v ON_ERROR_STOP=1 -h "${pg_host}" -p "${pg_port}" -U "${admin_user}" \
        -d "${pg_db}" -v u="${pg_user}" <<'SQL'
SELECT format('GRANT ALL ON SCHEMA public TO %I', :'u') \gexec
SQL

    if ! api GET /apps/list | jq -e --arg n "${APP_NAME}" '.response.apps[] | select(.name == $n)' >/dev/null; then
        url="$(api GET /apps/listStoreApps | jq -r --arg n "${APP_NAME}" '.response.storeApps[] | select(.name == $n) | .url' | head -1)"
        if [ -z "${url}" ]; then
            warn "query logs: '${APP_NAME}' was not found in the Technitium app store (no internet?)"
            return 0
        fi
        log "installing the '${APP_NAME}' app"
        api POST /apps/downloadAndInstall --data-urlencode "name=${APP_NAME}" --data-urlencode "url=${url}" >/dev/null \
            || { warn "query logs: could not install the app"; return 0; }
    fi

    # Keep whatever the user changed in the web console and set only the
    # connection and retention values.
    current="$(api GET /apps/config/get --get --data-urlencode "name=${APP_NAME}" | jq -r '.response.config // empty')"
    [ -n "${current}" ] || current='{}'
    merged="$(jq -c --arg db "${pg_db}" --arg conn "Server=${pg_host}; Port=${pg_port}; Username=${pg_user}; Password=${pg_pw};" \
        --argjson days "${days:-30}" \
        '. + {enableLogging: true, databaseName: $db, connectionString: $conn, maxLogDays: $days}' <<<"${current}")"
    if api POST /apps/config/set --data-urlencode "name=${APP_NAME}" --data-urlencode "config=${merged}" | jq -e '.status == "ok"' >/dev/null; then
        log "query logs go to PostgreSQL database '${pg_db}' at ${pg_host}:${pg_port}"
    else
        warn "query logs: could not save the app config"
    fi
}

announce_discovery() {
    if [ -z "${SUPERVISOR_TOKEN:-}" ]; then return 0; fi
    if curl -sf --max-time 10 -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" -H 'Content-Type: application/json' \
        -d '{"service":"technitium","config":{"host":"127.0.0.1","port":5380}}' http://supervisor/discovery >/dev/null; then
        log "service discovery sent to Home Assistant"
    else
        warn "service discovery was not accepted by Home Assistant"
    fi
}

post_start() {
    local password tries=0 response
    password="$(get dns_server_admin_password)"
    if [ -z "${password}" ]; then
        warn "no admin password is set, so the setup that uses the API is skipped."
        warn "Set the admin password in the app options to enable it."
        announce_discovery
        return 0
    fi
    until response="$(curl -sf --max-time 5 -X POST --data-urlencode "user=admin" --data-urlencode "pass=${password}" "${API}/user/login")"; do
        tries=$((tries + 1))
        if [ "${tries}" -ge 45 ]; then
            warn "the Technitium API did not answer in 90 s; skipping the API setup"
            return 0
        fi
        sleep 2
    done
    TOKEN="$(jq -r '.token // .response.token // empty' <<<"${response}")"
    if [ -z "${TOKEN}" ]; then
        warn "could not sign in to the Technitium API (was the admin password changed in the web console?)"
        announce_discovery
        return 0
    fi
    if is_true postgres_query_logs; then configure_query_logs; fi
    announce_discovery
    api GET /user/logout >/dev/null || true
    log "post-start setup complete"
}

# The background task is a child of the process that becomes the DNS server.
( set +e; post_start ) &

log "starting Technitium DNS Server ${TECHNITIUM_VERSION:-}"
exec /usr/bin/dotnet /opt/technitium/dns/DnsServerApp.dll "${CONFIG_DIR}"
