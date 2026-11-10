# Home Assistant App: Traefik
#
# Downloads the official Traefik release binary onto the HA base image, then
# runs Traefik (+ nginx for Ingress dashboard) under s6-overlay.
FROM ghcr.io/hassio-addons/base:stable

ARG TRAEFIK_VERSION="3.7.18"
ARG BUILD_ARCH

# nginx proxies the dashboard for HA Ingress; gomplate renders the static config.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache nginx gomplate

# Download, checksum-verify, and install Traefik from GitHub Releases.
# Traefik publishes arm64 (not aarch64) assets.
RUN \
    ARCH="${BUILD_ARCH}" \
    && if [ "${ARCH}" = "aarch64" ]; then ARCH="arm64"; fi \
    && ASSET="traefik_v${TRAEFIK_VERSION}_linux_${ARCH}.tar.gz" \
    && BASE_URL="https://github.com/traefik/traefik/releases/download/v${TRAEFIK_VERSION}" \
    && curl -sSLf -o "/tmp/${ASSET}" "${BASE_URL}/${ASSET}" \
    && curl -sSLf -o /tmp/traefik_checksums.txt "${BASE_URL}/traefik_v${TRAEFIK_VERSION}_checksums.txt" \
    && awk -v a="${ASSET}" '$2 == a { print $1 "  /tmp/" $2 }' /tmp/traefik_checksums.txt > /tmp/traefik.sha256 \
    && [ -s /tmp/traefik.sha256 ] \
    && sha256sum -c /tmp/traefik.sha256 \
    && tar -xzf "/tmp/${ASSET}" -C /usr/local/bin traefik \
    && chmod +x /usr/local/bin/traefik \
    && rm -f "/tmp/${ASSET}" /tmp/traefik_checksums.txt /tmp/traefik.sha256

ENV TRAEFIK_VERSION=${TRAEFIK_VERSION}

COPY rootfs /

EXPOSE 80/tcp 443/tcp 8080/tcp

ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
    io.hass.name="Traefik" \
    io.hass.description="Traefik reverse proxy for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="CharleStephen (https://github.com/charlestephen)" \
    org.opencontainers.image.title="Home Assistant App: Traefik" \
    org.opencontainers.image.description="Traefik reverse proxy for Home Assistant" \
    org.opencontainers.image.vendor="Home Assistant Apps" \
    org.opencontainers.image.authors="CharleStephen (https://github.com/charlestephen)" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/traefik/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
