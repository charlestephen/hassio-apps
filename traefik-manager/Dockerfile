ARG BUILD_FROM=ghcr.io/chr0nzz/traefik-manager:1.13.5

# Thin Home Assistant wrapper on the official Traefik Manager image. It's a
# self-contained Flask app served by gunicorn, so we do NOT add s6-overlay;
# we only translate the app options into its environment variables and
# then hand off to its own CMD.
FROM ${BUILD_FROM}

# jq: parse /data/options.json in the wrapper entrypoint.
RUN apk add --no-cache jq

# Surface the upstream version to the runtime entrypoint (for log output).
ARG TRAEFIK_MANAGER_VERSION=unknown
ENV TRAEFIK_MANAGER_VERSION=${TRAEFIK_MANAGER_VERSION}

# Wrapper entrypoint (options -> env -> exec gunicorn)
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 5000/tcp

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
    org.opencontainers.image.licenses="GPL-3.0" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
