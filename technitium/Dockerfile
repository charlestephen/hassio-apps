ARG BUILD_FROM=docker.io/technitium/dns-server:15.6.2

# Thin Home Assistant wrapper on Technitium's official image. The image already
# carries .NET and libmsquic (DNS-over-QUIC and HTTP/3). This layer adds the
# tools the wrapper needs, maps app options to Technitium's environment
# variables, and runs upstream's own command.
FROM ${BUILD_FROM}

# jq reads the app options, iproute2 lists the host addresses, and the
# PostgreSQL client prepares the query log database.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq iproute2 postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Home Assistant OS shares fs.inotify.max_user_instances (often 128) across
# every app. .NET's default file watchers take an instance each, so poll
# instead, and do not reload appsettings on change. Workstation GC keeps the
# heap smaller than server GC on a multi-core host.
ENV DOTNET_USE_POLLING_FILE_WATCHER=1 \
    DOTNET_HOSTBUILDER__RELOADCONFIGONCHANGE=false \
    DOTNET_gcServer=0 \
    DOTNET_GCConserveMemory=5

ARG TECHNITIUM_VERSION=15.6.2
ENV TECHNITIUM_VERSION=${TECHNITIUM_VERSION}

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
    org.opencontainers.image.licenses="GPL-3.0-only" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
