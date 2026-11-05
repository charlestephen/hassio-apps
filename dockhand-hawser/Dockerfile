# Home Assistant App: Hawser Agent for Dockhand
#
# Wraps the upstream Hawser agent (https://github.com/Finsys/hawser) on the HA
# base image. Version is pinned here and in build.yaml; track-upstream bumps both.
FROM ghcr.io/hassio-addons/base:stable

ARG HAWSER_VERSION="0.2.53"
ARG BUILD_ARCH

# Runtime tools Hawser needs for Compose stacks + the ingress status page.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        darkhttpd \
        docker-cli \
        docker-cli-compose \
        jq \
    && mkdir -p /usr/libexec/docker/cli-plugins \
    && ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Download, checksum-verify, and install the Hawser binary from GitHub Releases.
# Hawser publishes arm64 (not aarch64) assets; binary is statically linked.
RUN \
    ARCH="${BUILD_ARCH}" \
    && if [ "${ARCH}" = "aarch64" ]; then ARCH="arm64"; fi \
    && ASSET="hawser_${HAWSER_VERSION}_linux_${ARCH}.tar.gz" \
    && BASE_URL="https://github.com/Finsys/hawser/releases/download/v${HAWSER_VERSION}" \
    && curl -sSLf -o "/tmp/${ASSET}" "${BASE_URL}/${ASSET}" \
    && curl -sSLf -o /tmp/checksums.txt "${BASE_URL}/checksums.txt" \
    && EXPECTED="$(awk -v a="${ASSET}" '$2 == a { print $1 }' /tmp/checksums.txt)" \
    && [ -n "${EXPECTED}" ] \
    && ACTUAL="$(sha256sum "/tmp/${ASSET}" | awk '{print $1}')" \
    && [ "${EXPECTED}" = "${ACTUAL}" ] \
    && tar -xzf "/tmp/${ASSET}" -C /tmp hawser \
    && install -m 0755 /tmp/hawser /usr/local/bin/hawser \
    && rm -rf /tmp/hawser "/tmp/${ASSET}" /tmp/checksums.txt

ENV HAWSER_VERSION=${HAWSER_VERSION}

COPY rootfs /

ARG BUILD_VERSION
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: Hawser Agent for Dockhand" \
  org.opencontainers.image.description="Hawser agent bridging Home Assistant Docker to Dockhand" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.licenses="MIT"
