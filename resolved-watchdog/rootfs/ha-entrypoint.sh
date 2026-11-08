#!/usr/bin/env sh
# shellcheck shell=sh
# =============================================================================
# Resolved Watchdog
#
# Periodically test the HOST resolver stub; if it stops answering, restart the
# host's systemd-resolved over the host system D-Bus.
# =============================================================================
set -eu

OPTIONS="/data/options.json"

log() { echo "[resolved-watchdog] $*"; }

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}" 2>/dev/null || true; }

if [ ! -S /run/dbus/system_bus_socket ]; then
    log "WARNING: Host D-Bus socket not found at /run/dbus/system_bus_socket."
    log "WARNING: Ensure host_dbus is enabled and Protection mode is OFF;"
    log "WARNING: without it the watchdog can DETECT but not RESTART systemd-resolved."
fi

export DBUS_SYSTEM_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"

CANARY="$(get canary_host)"; CANARY="${CANARY:-cloudflare.com}"
STUB="$(get stub_address)"; STUB="${STUB:-127.0.0.53}"
INTERVAL="$(get interval)"; INTERVAL="${INTERVAL:-30}"
TIMEOUT="$(get timeout)"; TIMEOUT="${TIMEOUT:-5}"
THRESHOLD="$(get failures_before_restart)"; THRESHOLD="${THRESHOLD:-2}"
UNIT="$(get restart_unit)"; UNIT="${UNIT:-systemd-resolved.service}"

log "Watching host resolver ${STUB} (probe: ${CANARY}) every ${INTERVAL}s."
log "Will restart ${UNIT} after ${THRESHOLD} consecutive failures."

fails=0
while true; do
    if timeout "${TIMEOUT}" nslookup "${CANARY}" "${STUB}" >/dev/null 2>&1; then
        if [ "${fails}" -ne 0 ]; then
            log "Host resolver answered again (was failing ${fails}x)."
            fails=0
        fi
    else
        fails=$((fails + 1))
        log "WARNING: Host resolver did not answer (${fails}/${THRESHOLD})."
        if [ "${fails}" -ge "${THRESHOLD}" ]; then
            log "ERROR: Restarting ${UNIT} via host D-Bus..."
            if dbus-send --system --print-reply --reply-timeout=10000 \
                 --dest=org.freedesktop.systemd1 /org/freedesktop/systemd1 \
                 org.freedesktop.systemd1.Manager.RestartUnit \
                 string:"${UNIT}" string:"replace" >/dev/null 2>&1; then
                log "Restart of ${UNIT} requested; pausing 30s."
            else
                log "ERROR: Could not restart ${UNIT} over host D-Bus — check host_dbus access / D-Bus policy."
            fi
            fails=0
            sleep 30
        fi
    fi
    sleep "${INTERVAL}"
done
