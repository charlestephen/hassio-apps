# The official image is distroless (no shell). Copy its static binary onto
# Alpine so the options wrapper can write the config, then exec the binary.
#
# ARGs used in FROM must be declared before the first FROM (BuildKit).
ARG BUILD_FROM=alpine:3.24
ARG TEMPO_VERSION=3.1.1

FROM docker.io/grafana/tempo:${TEMPO_VERSION} AS tempo

FROM ${BUILD_FROM}

ARG TEMPO_VERSION=3.1.1
ENV TEMPO_VERSION=${TEMPO_VERSION}

# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache ca-certificates jq su-exec tzdata

COPY --from=tempo /tempo /usr/bin/tempo
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 3200/tcp 4317/tcp 4318/tcp

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
