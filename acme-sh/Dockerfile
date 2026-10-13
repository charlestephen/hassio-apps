# Home Assistant App: Acme.sh
#
# Runtime is the official image with no version pin. The entry script upgrades
# acme.sh on start and before each renewal, then re-links any custom deploy
# hooks so an upgrade cannot drop them before they run.
# hadolint ignore=DL3007
ARG BUILD_FROM=ghcr.io/acmesh-official/acme.sh:latest
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

COPY --chmod=755 rootfs/usr/local/bin/acme-run /usr/local/bin/acme-run

ENV LE_WORKING_DIR=/acmebin \
    LE_CONFIG_HOME=/data/acme.sh \
    HOME=/data/acme.sh

ENTRYPOINT ["/usr/local/bin/acme-run"]

ARG BUILD_ARCH
ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: Acme.sh" \
  org.opencontainers.image.description="Acme.sh certificate client with deploy hooks and self-upgrade" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.licenses="MIT"
