#!/usr/bin/with-contenv bashio
# =============================================================================
# Validate configuration before the connector replicas start.
# =============================================================================
set -e

if ! bashio::config.has_value 'tunnel_token'; then
    bashio::log.fatal "No 'tunnel_token' is set."
    bashio::log.fatal "Create a remotely-managed tunnel in the Cloudflare Zero Trust"
    bashio::log.fatal "dashboard (Networks -> Tunnels), copy its connector token, and"
    bashio::log.fatal "paste it into this add-on's Configuration tab."
    bashio::exit.nok
fi

bashio::log.info "Cloudflared: starting 2 HA replicas (cloudflared0 + cloudflared1)"
bashio::log.info "of one remotely-managed tunnel. Hostnames/ingress are managed in the"
bashio::log.info "Cloudflare dashboard. Metrics: :36400 (replica 0), :36401 (replica 1)."
