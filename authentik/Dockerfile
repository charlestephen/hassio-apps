ARG BUILD_FROM=ghcr.io/goauthentik/server:2026.8.5

# Thin Home Assistant wrapper on the official authentik image. Map HA options to
# AUTHENTIK_* variables, then run the upstream entrypoint in allinone mode
# (server and worker in one process).
FROM ${BUILD_FROM}

# Start as root to read /data/options.json; the upstream entrypoint chowns
# /data and drops to the authentik user.
# hadolint ignore=DL3002
USER root

ARG AUTHENTIK_VERSION=2026.8.5
ENV AUTHENTIK_VERSION=${AUTHENTIK_VERSION}

COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

EXPOSE 9000/tcp 9443/tcp

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="CharleStephen (https://github.com/charlestephen)" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Apps" \
    org.opencontainers.image.authors="CharleStephen (https://github.com/charlestephen)" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
