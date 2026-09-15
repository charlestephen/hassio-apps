ARG BUILD_FROM=ghcr.io/ozark-connect/network-optimizer:latest

# Thin Home Assistant wrapper around the upstream Ozark-Connect Network
# Optimizer image. We only inject the app options as environment variables
# and hand off to the image's own startup — the app itself is unmodified.
FROM ${BUILD_FROM}

# FIXED: Simplified jq installation for Debian-based dotnet/aspnet base image
# Previous version tried apk/apt-get/microdnf chains unnecessarily.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

# FIXED: Removed UPSTREAM_START env var.
# The entrypoint directly execs /entrypoint.sh (upstream's entrypoint),
# so no indirection or extra shell layer is needed.
# Upstream CMD is inherited; entrypoint handles gosu + dotnet invocation.

EXPOSE 8042/tcp

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
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]