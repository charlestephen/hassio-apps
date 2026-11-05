ARG BUILD_FROM=docker.io/pocketid/pocket-id:v2.19.2

# Thin Home Assistant wrapper on Pocket ID's official image. Map HA options to
# Pocket ID environment variables, persist /app/data on the HA /data volume,
# then exec upstream /app/docker/entrypoint.sh.
FROM ${BUILD_FROM}

# HA entrypoint must start as root to read /data/options.json and chown data.
# hadolint ignore=DL3002
USER root
# jq parses options; openssl generates ENCRYPTION_KEY when left blank.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache jq openssl

ARG POCKET_ID_VERSION=2.19.2
ENV POCKET_ID_VERSION=${POCKET_ID_VERSION}

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 1411/tcp

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
    org.opencontainers.image.licenses="BSD-2-Clause" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
