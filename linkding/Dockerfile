# Home Assistant App: Linkding
#
# Runtime base = the upstream linkding alpine image. The HA app framework
# (s6-overlay) is grafted in from the HA Alpine base via multi-stage COPY.
# s6-overlay binaries are static, so there are NO RUN steps -> amd64 + aarch64
# both cross-build cleanly. Config is read with the python3 already bundled in
# the linkding image (instead of bashio, which would need bash/jq via a RUN).
FROM ghcr.io/home-assistant/base:3.24 AS habase

FROM ghcr.io/sissbruecker/linkding:latest-alpine
# s6-overlay's /init must run as root (to run cont-init, chown the /data volume,
# and supervise services); the service itself drops back to www-data at runtime.
USER root
ARG BUILD_ARCH

# Graft s6-overlay v3 from the HA base.
COPY --from=habase /init /init
COPY --from=habase /package /package
COPY --from=habase /command /command
COPY --from=habase /etc/s6-overlay /etc/s6-overlay
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

# App filesystem: config generator (cont-init) + the s6 long-run service.
COPY rootfs /

ENTRYPOINT ["/init"]

ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_REPOSITORY
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="addon" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.title="Home Assistant App: Linkding" \
  org.opencontainers.image.description="Linkding bookmark manager (SQLite) for Home Assistant" \
  org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
  org.opencontainers.image.licenses="MIT"
