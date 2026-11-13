# The official image is distroless (no shell) and its binary links glibc. Copy the
# binary onto Debian slim so the options wrapper can set the environment, then
# exec the upstream binary.
#
# ARGs used in FROM must be declared before the first FROM (BuildKit).
ARG BUILD_FROM=debian:trixie-slim
ARG OPENOBSERVE_VERSION=v1.1.2

FROM docker.io/openobserve/openobserve:${OPENOBSERVE_VERSION} AS upstream

FROM ${BUILD_FROM}

ARG OPENOBSERVE_VERSION=v1.1.2
ENV OPENOBSERVE_VERSION=${OPENOBSERVE_VERSION}

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates jq tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=upstream /openobserve /usr/bin/openobserve
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 5080/tcp 5081/tcp

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

ENTRYPOINT ["/ha-entrypoint.sh"]
