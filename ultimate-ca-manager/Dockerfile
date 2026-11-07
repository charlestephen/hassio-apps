ARG BUILD_FROM=docker.io/neyslim/ultimate-ca-manager:2.251

# Thin Home Assistant wrapper on Ultimate CA Manager. Map HA options to UCM
# environment variables, persist PKI under /ssl/ucm (symlinked into /data for
# addon backups), then exec upstream /entrypoint.sh as user ucm.
FROM ${BUILD_FROM}

# HA entrypoint must start as root to read /data/options.json and chown PKI dirs.
# hadolint ignore=DL3002
USER root

# jq parses options.json. Upstream image is Debian slim.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

ARG UCM_VERSION=2.251
ENV UCM_VERSION=${UCM_VERSION}

COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 8443/tcp 8080/tcp 8053/tcp 8053/udp

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
    org.opencontainers.image.licenses="AGPL-3.0-only" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# Preserve upstream's gunicorn CMD. Supervisor may still start with an empty
# command; ha-entrypoint.sh falls back to the same argv when $# is 0.
ENTRYPOINT ["/ha-entrypoint.sh"]
CMD ["sh", "-c", "cd /opt/ucm/backend && gunicorn -c gunicorn_config.py wsgi:app"]
