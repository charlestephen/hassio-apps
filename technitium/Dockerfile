ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable
ARG TECHNITIUM_VERSION=15.6.1

# Stage 1: Pull the Technitium DNS Server app from the upstream image so the
# final image stays in lockstep with the primary developer's build.
# TECHNITIUM_VERSION is filled by scripts/update-upstream-version.py.
FROM technitium/dns-server:${TECHNITIUM_VERSION} AS technitium

# Stage 2: Build final image on HA base (Alpine 3.23, bashio + s6-overlay v3)
FROM ${BUILD_FROM}

# Runtime dependencies:
#   - aspnetcore10-runtime: Technitium 15.x targets .NET 10
#   - icu-libs: required by .NET globalization
#   - libmsquic: enables DNS-over-QUIC (DoQ) and DNS-over-HTTP/3 (DoH3);
#     packaged for Alpine/musl by the Microsoft QUIC Team in
#     v3.23/community, so no Microsoft apt repo is needed on this base.
RUN apk upgrade --no-cache \
    && apk add --no-cache \
      aspnetcore10-runtime \
      icu-libs \
      libmsquic

# Copy Technitium app from official upstream image. Drop compiler
# symbol files; they are not used at runtime.
COPY --from=technitium /opt/technitium/dns /opt/technitium/dns
RUN find /opt/technitium/dns -type f -name '*.pdb' -delete

# Home Assistant OS shares fs.inotify.max_user_instances (often 128) across
# every add-on. .NET's default file watchers take an instance each and the
# log then reports that inotify places are exhausted. Poll instead, and do
# not reload appsettings on change. Workstation GC keeps the heap smaller
# than server GC on a multi-core host.
ENV DOTNET_USE_POLLING_FILE_WATCHER=1 \
    DOTNET_HOSTBUILDER__RELOADCONFIGONCHANGE=false \
    DOTNET_gcServer=0 \
    DOTNET_GCConserveMemory=5

# Create state directory
RUN mkdir -p /etc/dns

# Copy local files
COPY rootfs/ /

# Make all s6-rc.d scripts executable
RUN find /etc/s6-overlay/s6-rc.d -type f \( -name "up" -o -name "run" -o -name "finish" \) \
    -exec chmod 755 {} \;

# Ports follow upstream technitium/dns-server, plus the Technitium web console.
EXPOSE 53/tcp 53/udp \
       853/tcp 853/udp \
       8053/tcp \
       5380/tcp 53443/tcp \
       67/udp

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
