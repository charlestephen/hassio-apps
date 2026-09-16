# Home Assistant App: Grafana Alloy
#
# The base image is pinned directly in the FROM line. As of Supervisor 2026.04.0
# the BUILD_FROM build-arg is no longer injected unless a build.yaml declares
# build_from, so the modern, recommended approach is to set the base image here.
# ghcr.io/home-assistant/base is a multi-arch (amd64/aarch64) Alpine image and
# buildx selects the matching platform automatically.
FROM ghcr.io/home-assistant/base:3.24

# Pin the Alloy release for reproducible builds.
ARG ALLOY_VERSION="v1.19.2"
# BUILD_ARCH is always injected by the Supervisor (amd64, aarch64, ...).
ARG BUILD_ARCH

# Grafana Alloy is a glibc binary; libc6-compat provides the shim so it runs on
# Alpine's musl. unzip is used to unpack the release archive.
RUN apk add --no-cache libc6-compat unzip

# Download and install the Alloy binary. Alloy publishes arm64 (not aarch64)
# assets, so translate the HA arch name on the fly.
RUN \
    curl -sSLf -o /tmp/alloy.zip \
      "https://github.com/grafana/alloy/releases/download/${ALLOY_VERSION}/alloy-linux-${BUILD_ARCH//aarch64/arm64}.zip" \
    && unzip -q /tmp/alloy.zip -d /tmp \
    && mv /tmp/alloy-linux-* /usr/bin/alloy \
    && chmod +x /usr/bin/alloy \
    && rm -f /tmp/alloy.zip

# App filesystem: default config, config generator (cont-init) and the
# s6 long-run service.
COPY rootfs /

# Build metadata (replaces the legacy build.yaml labels).
ARG BUILD_VERSION
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: Grafana Alloy" \
  org.opencontainers.image.description="Ship all container logs to Loki with Grafana Alloy" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.licenses="MIT"
