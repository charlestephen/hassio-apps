ARG BUILD_FROM=ghcr.io/kereis/traefik-certs-dumper:1.8.32

# Thin Home Assistant wrapper on the kereis image. The image writes to a fixed
# /output volume, which Home Assistant cannot replace with the ssl folder, so its
# dump script is patched in place to read the output folder from OUTPUT_DIR. The
# image's healthcheck looks for the process /usr/bin/dump, so the path stays.
FROM ${BUILD_FROM}

ARG TRAEFIK_CERTS_DUMPER_VERSION=1.8.32
ENV TRAEFIK_CERTS_DUMPER_VERSION=${TRAEFIK_CERTS_DUMPER_VERSION}

# hadolint ignore=DL3018,SC2016
RUN apk add --no-cache jq \
    && sed -i 's|^outputdir=/output$|outputdir="${OUTPUT_DIR:-/output}"|' /usr/bin/dump \
    && grep -q 'OUTPUT_DIR' /usr/bin/dump

COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

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
