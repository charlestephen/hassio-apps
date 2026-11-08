#!/usr/bin/env sh
# shellcheck shell=sh
# ==============================================================================
# Home Assistant wrapper for tarampampam/error-pages.
# Map /data/options.json → env, then exec upstream `error-pages serve`.
# ==============================================================================
set -eu

OPTIONS="/data/options.json"
VERSION="${ERROR_PAGES_VERSION:-unknown}"

log() { echo "[error-pages-addon] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}" 2>/dev/null)" = "true" ]; }

export_env() {
    _v="$(get "$1")"
    [ -n "${_v}" ] || return 0
    export "$2=${_v}"
    log "set $2=${_v}"
}

export_bool() {
    if is_true "$1"; then
        export "$2=true"
        log "set $2=true"
    else
        export "$2=false"
        log "set $2=false"
    fi
}

if [ ! -f "${OPTIONS}" ]; then
    log "WARNING: ${OPTIONS} missing; starting error-pages with defaults"
fi

# Listen address is fixed; host port comes from Supervisor Network settings.
export LISTEN_ADDR="0.0.0.0"
export LISTEN_PORT="8080"

export_env 'theme' 'TEMPLATE_NAME'
export_env 'default_error_page' 'DEFAULT_ERROR_PAGE'
export_bool 'send_same_http_code' 'SEND_SAME_HTTP_CODE'
export_bool 'show_details' 'SHOW_DETAILS'
export_env 'rotation_mode' 'ROTATION_MODE'
export_bool 'disable_l10n' 'DISABLE_L10N'
export_env 'proxy_headers' 'PROXY_HTTP_HEADERS'
export_env 'log_level' 'LOG_LEVEL'
export_env 'log_format' 'LOG_FORMAT'

# Defaults matching config.yaml when options are absent.
: "${TEMPLATE_NAME:=app-down}"
: "${DEFAULT_ERROR_PAGE:=404}"
: "${SEND_SAME_HTTP_CODE:=false}"
: "${SHOW_DETAILS:=false}"
: "${ROTATION_MODE:=disabled}"
: "${DISABLE_L10N:=false}"
: "${LOG_LEVEL:=info}"
: "${LOG_FORMAT:=console}"

log "Starting error-pages v${VERSION} (theme=${TEMPLATE_NAME}, rotation=${ROTATION_MODE}) ..."
exec /usr/bin/error-pages serve
