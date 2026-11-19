ARG BUILD_FROM=docker.io/webhippie/terrastate:2.11.4

# Thin Home Assistant wrapper on the official Terrastate image (Alpine-based,
# has its own shell). Map HA options to its TERRASTATE_* environment
# variables, keep state on the HA /data volume, then exec the upstream
# binary/entrypoint exactly as its own image does (ENTRYPOINT
# /usr/bin/terrastate, CMD server).
FROM ${BUILD_FROM}

# HA entrypoint must start as root to read /data/options.json and write to
# the /data volume; upstream's own image runs as its own "terrastate" user.
# hadolint ignore=DL3002
USER root

ARG TERRASTATE_VERSION=2.11.4
ENV TERRASTATE_VERSION=${TERRASTATE_VERSION}

# hadolint ignore=DL3018
RUN apk add --no-cache jq

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 8080/tcp 8081/tcp

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
