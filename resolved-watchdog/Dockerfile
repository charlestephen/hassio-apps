# Home Assistant Add-on: Resolved Watchdog
#
# Tiny script add-on: probes the host resolver and restarts systemd-resolved over
# the host system D-Bus when it hangs. Only extra dependency is dbus-send.
FROM ghcr.io/home-assistant/base:3.24

ARG BUILD_ARCH

# dbus-send is used to call systemd1.RestartUnit on the host system bus.
RUN apk add --no-cache dbus

COPY rootfs /

ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant Add-on: Resolved Watchdog" \
  org.opencontainers.image.description="Auto-restarts host systemd-resolved when it hangs" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.licenses="MIT"
