ARG BUILD_FROM=ghcr.io/bluewave-labs/checkmate:4.1.0

# Thin Home Assistant wrapper on the official Checkmate image (Debian
# node:24-slim, non-root "node" user). Map HA options to the environment
# variables Checkmate's own app reads directly (no custom env handling in
# upstream's own entrypoint -- confirmed by reading it), then exec upstream's
# entrypoint + CMD unchanged.
FROM ${BUILD_FROM}

# HA entrypoint must start as root to read /data/options.json; this repo's
# other thin wrappers on non-root upstream images (e.g. Pocket ID) do the
# same rather than engineering a privilege drop back to the upstream user.
# hadolint ignore=DL3002
USER root

ARG CHECKMATE_VERSION=4.1.0
ENV CHECKMATE_VERSION=${CHECKMATE_VERSION}

# jq parses options; openssl (already in the image) generates
# JWT_SECRET/ENCRYPTION_KEY when left blank.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 52345/tcp

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
    org.opencontainers.image.licenses="AGPL-3.0-only" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
