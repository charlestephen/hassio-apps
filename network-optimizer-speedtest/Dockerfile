ARG BUILD_FROM=ghcr.io/ozark-connect/speedtest:latest

# Thin HA wrapper around the upstream OpenSpeedTest companion image.
# Base: nginxinc/nginx-unprivileged:stable-alpine (Alpine).
FROM ${BUILD_FROM}

# FIXED: Base image is Alpine (nginx-unprivileged:stable-alpine).
# Simplified to apk-only. No need for apt-get/microdnf fallback chains.
USER root
RUN apk add --no-cache jq \
    && rm -rf /var/cache/apk/*

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

# FIXED: Removed UPSTREAM_START env var.
# Upstream structure (inherited from nginx-unprivileged):
#   ENTRYPOINT ["/docker-entrypoint.sh"]
#   CMD ["nginx", "-g", "daemon off;"]
# With our ENTRYPOINT set, Docker passes CMD as args ($@) to our script.
# We exec nginx's entrypoint directly with those args — no shell indirection.
# To verify upstream config:
#   podman inspect ghcr.io/ozark-connect/speedtest:latest \
#     --format '{{json .Config.Entrypoint}} {{json .Config.Cmd}}'

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
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]