# Home Assistant App: UniFi Notifi
#
# First-party enricher: UniFi Alarm Manager webhook → threat lookback → Slack.
FROM ghcr.io/hassio-addons/base:stable

ARG BUILD_ARCH

# stdlib-only Python enricher; ensure python3 is present on the base image.
RUN apk upgrade --no-cache \
    && apk add --no-cache python3

COPY rootfs /

RUN chmod 755 /usr/local/bin/unifi-notifi.py \
    && if [ -d /etc/services.d ]; then chmod -R 755 /etc/services.d; fi \
    && if [ -d /etc/cont-init.d ]; then chmod -R 755 /etc/cont-init.d; fi

EXPOSE 8099

ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: UniFi Notifi" \
  org.opencontainers.image.description="Enrich UniFi Alarm Manager threat webhooks into Slack Block Kit" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.licenses="MIT"
