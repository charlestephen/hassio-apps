ARG BUILD_FROM=ghcr.io/ozark-connect/speedtest:2.10.7

# Thin Home Assistant wrapper on the official Network Optimizer Speed Test
# image (customized OpenSpeedTest). Upstream /docker-entrypoint.sh preserved.
FROM ${BUILD_FROM}

USER root
# Alpine nginx base.
RUN apk upgrade --no-cache \
    && apk add --no-cache jq

ARG NETWORK_OPTIMIZER_SPEEDTEST_VERSION=2.10.7
ENV NETWORK_OPTIMIZER_SPEEDTEST_VERSION=${NETWORK_OPTIMIZER_SPEEDTEST_VERSION}

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 3000/tcp

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
    org.opencontainers.image.licenses="BSL-1.1" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
