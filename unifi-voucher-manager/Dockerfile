ARG BUILD_FROM=docker.io/etiennecollin/unifi-voucher-manager:latest

# Thin HA wrapper around etiennecollin/unifi-voucher-manager
# (Next.js frontend + Rust backend in one image).
FROM ${BUILD_FROM}

# FIXED: Base image is Alpine 3.22 (confirmed from upstream Dockerfile)
# Simplified to apk-only. No need for apt-get/microdnf fallback chains.
USER root
RUN apk add --no-cache jq \
    && rm -rf /var/cache/apk/*

COPY rootfs/ /
RUN chmod +x /ha-entrypoint

# FIXED: Removed UPSTREAM_START env var entirely.
# Upstream ENTRYPOINT=./entrypoint.sh and CMD=./run_wrapper.sh are inherited.
# No shell indirection needed — we exec the upstream entrypoint directly.
# To verify upstream config:
#   podman inspect docker.io/etiennecollin/unifi-voucher-manager:latest \
#     --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'

EXPOSE 3000/tcp 8080/tcp

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

ENTRYPOINT ["/ha-entrypoint"]