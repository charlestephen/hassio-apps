ARG BUILD_FROM=ghcr.io/charlestephen/ratioreign:2.2.0

# Thin Home Assistant wrapper on RatioReign's official image. The upstream
# entrypoint is a single static binary; we only map HA options /data into the
# paths RatioReign expects, then exec it.
FROM ${BUILD_FROM}

# HA entrypoint must start as root to map /data and drop privileges via su-exec.
# hadolint ignore=DL3002
USER root
RUN apk upgrade --no-cache \
    && apk add --no-cache jq su-exec

ARG RATIOREIGN_VERSION=2.2.0
ENV RATIOREIGN_VERSION=${RATIOREIGN_VERSION}

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 7070/tcp

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
