ARG BUILD_FROM=docker.io/tecnativa/docker-socket-proxy:v0.5.0

# Thin Home Assistant wrapper on Tecnativa/docker-socket-proxy. Map HA options
# to the upstream 0/1 API toggles, then exec its docker-entrypoint + haproxy.
FROM ${BUILD_FROM}

# HA entrypoint must start as root to read /data/options.json.
# hadolint ignore=DL3002
USER root
# jq parses /data/options.json. Upstream image is Alpine-based HAProxy.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache jq

ARG PROXY_VERSION=0.5.0
ENV PROXY_VERSION=${PROXY_VERSION}

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 2375/tcp

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
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
