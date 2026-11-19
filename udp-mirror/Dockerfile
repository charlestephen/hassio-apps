ARG BUILD_FROM=ghcr.io/czerwonk/udp-mirror:0.1.1

# Thin Home Assistant wrapper on udp-mirror's official image. Adds jq to
# read the app options, builds the CLI flags, then execs upstream's binary.
FROM ${BUILD_FROM}

USER root
RUN apk add --no-cache jq || (apt-get update && apt-get install -y --no-install-recommends jq && rm -rf /var/lib/apt/lists/*)

ARG UDP_MIRROR_VERSION=0.1.1
ENV UDP_MIRROR_VERSION=${UDP_MIRROR_VERSION}

COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

EXPOSE 4560/udp

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
