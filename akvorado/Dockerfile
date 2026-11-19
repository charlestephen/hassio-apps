# Akvorado ships as gcr.io/distroless/static — no shell, no package manager —
# so it cannot run Supervisor's options templating or supervise its own four
# cooperating processes (orchestrator/inlet/outlet/console) the way this
# app needs to. Only the compiled binary is taken from upstream; everything
# else (shell, s6-overlay, bashio, jq, envsubst, curl) comes from the HA base
# image, same as every other app in this repo.
#
# Both ARGs used in a FROM must be declared in GLOBAL scope (before the
# first FROM in the whole file) or buildx silently resolves the CI-supplied
# --build-arg to blank for the second FROM instead of falling back to its
# own default.
ARG AKVORADO_VERSION=2026.10.1
ARG AKVORADO_IMAGE=ghcr.io/akvorado/akvorado:${AKVORADO_VERSION}
ARG GEOIPUPDATE_VERSION=8.0.0
ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable

FROM ${AKVORADO_IMAGE} AS upstream

FROM ${BUILD_FROM}

ARG AKVORADO_VERSION
ENV AKVORADO_VERSION=${AKVORADO_VERSION}
ARG GEOIPUPDATE_VERSION
ARG TARGETARCH

RUN apk add --no-cache jq gettext curl

# geoipupdate has no apk package; its own GitHub release ships a plain Go
# binary per arch (TARGETARCH is amd64/arm64, matching the release names).
RUN curl -fsSL "https://github.com/maxmind/geoipupdate/releases/download/v${GEOIPUPDATE_VERSION}/geoipupdate_${GEOIPUPDATE_VERSION}_linux_${TARGETARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 "geoipupdate_${GEOIPUPDATE_VERSION}_linux_${TARGETARCH}/geoipupdate"

COPY --from=upstream /usr/local/bin/akvorado /usr/local/bin/akvorado
COPY rootfs/ /

RUN if [ -d /etc/cont-init.d ]; then chmod -R 755 /etc/cont-init.d; fi && \
    if [ -d /etc/services.d ]; then chmod -R 755 /etc/services.d; fi

EXPOSE 2055/udp 4739/udp 6343/udp 8083/tcp

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
    org.opencontainers.image.licenses="AGPL-3.0-only" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
