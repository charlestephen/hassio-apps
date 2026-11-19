# Official contrib image is FROM scratch (binary only). Copy that binary onto
# Debian with jq so the HA options wrapper can generate config, then exec the
# upstream binary. No s6/bashio — the collector is a single long-running process.
#
# Debian, not Alpine: the collector's own `journald` receiver shells out to
# the real `journalctl` binary (confirmed live -- it fails outright with
# "executable file not found in $PATH" otherwise) and Alpine ships no
# journalctl/libsystemd package at all (musl + OpenRC, no systemd). Debian's
# `systemd` package provides journalctl and works fine in `--directory` mode
# with no live systemd/D-Bus needed (confirmed live) for no-install-recommends
# dependencies (libsystemd-shared, libapparmor1) beyond itself.
#
# ARGs used in FROM must be declared before the first FROM (BuildKit).
ARG BUILD_FROM=debian:trixie-slim
ARG OTELCOL_VERSION=0.165.0

FROM docker.io/otel/opentelemetry-collector-contrib:${OTELCOL_VERSION} AS otelcol

FROM ${BUILD_FROM}

# Re-declare for use inside this stage.
ARG OTELCOL_VERSION=0.165.0
ENV OTELCOL_VERSION=${OTELCOL_VERSION}

# netcat-openbsd: the docker-stats reachability check uses `nc`, present in
# Alpine's busybox by default but not in Debian slim.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates jq systemd netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=otelcol /otelcol-contrib /usr/bin/otelcol-contrib
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

# OTLP gRPC / HTTP; collector self-metrics
EXPOSE 4317/tcp 4318/tcp 8888/tcp

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
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
