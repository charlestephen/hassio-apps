# Home Assistant App: Cloudflared (dual-replica HA)
#
# Built on the official, multi-arch cloudflare/cloudflared image: the static
# binary is COPY'd onto the Home Assistant base (which provides s6-overlay +
# bashio). Because cloudflared is statically linked there are NO RUN steps, and
# the multi-arch COPY --from is resolved per --platform — clean on your native
# per-arch builders (no emulation).
# Filled by scripts/update-upstream-version.py on each upstream release.
# Source image: docker.io/cloudflare/cloudflared.
# Declared in global scope because COPY --from cannot expand build args.
ARG CLOUDFLARED_VERSION="2026.9.3"
FROM docker.io/cloudflare/cloudflared:${CLOUDFLARED_VERSION} AS cloudflared

FROM ghcr.io/hassio-addons/base:stable

# BUILD_ARCH is injected by the Supervisor / CI (amd64, aarch64).
ARG BUILD_ARCH

# Pull the cloudflared binary straight from the official image for this platform.
COPY --from=cloudflared /usr/local/bin/cloudflared /usr/bin/cloudflared

# App filesystem: config validator (cont-init) + the two s6 replica services.
COPY rootfs /

# Build metadata (matches the alloy app's label set).
ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: Cloudflared" \
  org.opencontainers.image.description="Dual-replica Cloudflare Tunnel (HA) on the stock cloudflared image" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.licenses="MIT"
