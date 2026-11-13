# The official image is FROM scratch (binary only). Copy that binary onto Alpine
# so the options wrapper can build the flags, then exec the upstream binary.
#
# ARGs used in FROM must be declared before the first FROM (BuildKit).
ARG BUILD_FROM=alpine:3.24
ARG VICTORIA_LOGS_VERSION=v1.53.0

FROM docker.io/victoriametrics/victoria-logs:${VICTORIA_LOGS_VERSION} AS upstream

FROM ${BUILD_FROM}

ARG VICTORIA_LOGS_VERSION=v1.53.0
ENV VICTORIA_LOGS_VERSION=${VICTORIA_LOGS_VERSION}

# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache ca-certificates jq tzdata

COPY --from=upstream /victoria-logs-prod /victoria-logs-prod
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 9428/tcp

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
