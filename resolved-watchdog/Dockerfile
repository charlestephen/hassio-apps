# Home Assistant App: Resolved Watchdog
#
# Tiny script app: probes the host resolver and restarts systemd-resolved over
# the host system D-Bus when it hangs. Alpine thin wrap (no s6/bashio).
ARG BUILD_FROM=alpine:3.24
FROM ${BUILD_FROM}

ARG BUILD_ARCH

# dbus-send talks to the host system bus; Alpine busybox provides nslookup/timeout.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache dbus jq

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: Resolved Watchdog" \
  org.opencontainers.image.description="Auto-restarts host systemd-resolved when it hangs" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/ha-entrypoint.sh"]
