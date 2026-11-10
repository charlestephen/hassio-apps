ARG BUILD_FROM=alpine:3.24
# renovate: datasource=docker depName=ghcr.io/charlestephen/dns-ip-list-chunker
ARG DNS_IP_LIST_CHUNKER_VERSION=1.5.0

FROM ghcr.io/charlestephen/dns-ip-list-chunker:${DNS_IP_LIST_CHUNKER_VERSION} AS upstream

FROM ${BUILD_FROM}

ARG DNS_IP_LIST_CHUNKER_VERSION=1.5.0
ENV DNS_IP_LIST_CHUNKER_VERSION=${DNS_IP_LIST_CHUNKER_VERSION}

# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache ca-certificates jq \
    && update-ca-certificates

COPY --from=upstream /dns-ip-list-chunker /usr/bin/dns-ip-list-chunker
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
