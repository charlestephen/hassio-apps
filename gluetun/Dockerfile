ARG BUILD_FROM=docker.io/qmcgaw/gluetun:v3.41.3

# Thin Home Assistant wrapper on Gluetun's official image. Map HA options to
# Gluetun environment variables, then exec upstream /gluetun-entrypoint.
FROM ${BUILD_FROM}

# HA entrypoint must start as root to read /data/options.json and exec upstream.
# hadolint ignore=DL3002
USER root
# jq parses /data/options.json. Upstream image is Alpine-based.
RUN apk upgrade --no-cache \
    && apk add --no-cache jq

ARG GLUETUN_VERSION=3.41.3
ENV GLUETUN_VERSION=${GLUETUN_VERSION}

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

# Control server, HTTP proxy, Shadowsocks (TCP+UDP) — same as upstream.
EXPOSE 8000/tcp 8888/tcp 8388/tcp 8388/udp

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
