#!/usr/bin/with-contenv bashio
# =============================================================================
# Pre-flight: confirm the host D-Bus socket is available (needed to restart the
# unit). Detection still works without it; recovery does not.
# =============================================================================
if [ ! -S /run/dbus/system_bus_socket ]; then
    bashio::log.warning "Host D-Bus socket not found at /run/dbus/system_bus_socket."
    bashio::log.warning "Ensure 'host_dbus: true' is set and Protection mode is OFF;"
    bashio::log.warning "without it the watchdog can DETECT but not RESTART systemd-resolved."
fi
bashio::log.info "Resolved Watchdog initialised."
