# udp-mirror's own image has no shell and no PATH entry for its own binary
# (it ships at /app/udp_mirror; the image's own ENTRYPOINT names "udp-mirror",
# which does not exist anywhere in the image and is unresolvable as shipped).
# Only the compiled binary is taken from upstream; the HA base image supplies
# the shell and jq needed to read Supervisor's options.
#
# Both ARGs used in a FROM must be declared in GLOBAL scope (before the
# first FROM in the whole file) or buildx silently resolves the CI-supplied
# --build-arg to blank for the second FROM instead of falling back to its
# own default.
ARG UDP_MIRROR_VERSION=0.1.1
ARG UDP_MIRROR_IMAGE=ghcr.io/czerwonk/udp-mirror:${UDP_MIRROR_VERSION}
ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable

FROM ${UDP_MIRROR_IMAGE} AS upstream

FROM ${BUILD_FROM}

ARG UDP_MIRROR_VERSION
ENV UDP_MIRROR_VERSION=${UDP_MIRROR_VERSION}

RUN apk add --no-cache jq

COPY --from=upstream /app/udp_mirror /usr/local/bin/udp-mirror
COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

EXPOSE 4560/udp

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
    io.hass.version="${BUILD_VERSION}" \
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
