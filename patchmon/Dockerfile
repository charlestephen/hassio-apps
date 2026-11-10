ARG BUILD_FROM=docker.io/library/alpine:3.24
ARG PATCHMON_VERSION=2.1.8

FROM ghcr.io/patchmon/patchmon-server:${PATCHMON_VERSION} AS upstream

FROM ${BUILD_FROM}
# Valkey is the cache PatchMon needs (Redis protocol); jq reads the app options;
# the PostgreSQL client creates the database; su-exec drops root.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache valkey valkey-cli ca-certificates tzdata jq postgresql18-client su-exec \
    && adduser -D -H -s /sbin/nologin -u 65532 patchmon \
    && mkdir -p /app

COPY --from=upstream /app /app
COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

ARG PATCHMON_VERSION
ENV PATCHMON_VERSION=${PATCHMON_VERSION} \
    PORT=3000 \
    AGENTS_DIR=/app/agents \
    SSG_CONTENT_DIR=/app/ssg-content \
    GOMEMLIMIT=256MiB
WORKDIR /app

EXPOSE 3000/tcp

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
    org.opencontainers.image.licenses="AGPL-3.0-only" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
