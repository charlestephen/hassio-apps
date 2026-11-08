ARG BUILD_FROM=alpine:3.24
# error-pages ships a single static Go binary in a distroless image; copy it
# onto Alpine with jq so the HA options wrapper can map config → env, then exec
# upstream `error-pages serve` (no s6/bashio).
# renovate: datasource=docker depName=ghcr.io/tarampampam/error-pages
ARG ERROR_PAGES_VERSION=4.2.7

FROM ghcr.io/tarampampam/error-pages:${ERROR_PAGES_VERSION} AS errorpages

FROM ${BUILD_FROM}

ARG ERROR_PAGES_VERSION=4.2.7
ENV ERROR_PAGES_VERSION=${ERROR_PAGES_VERSION}

# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache ca-certificates jq \
    && update-ca-certificates

COPY --from=errorpages /bin/error-pages /usr/bin/error-pages
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 8080

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
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
