ARG BUILD_FROM=docker.io/clickhouse/clickhouse-server:26.8.40.7-alpine

# Thin Home Assistant wrapper on ClickHouse's official image. The wrapper
# only sets CLICKHOUSE_* environment variables the upstream entrypoint
# already understands, then execs it (same approach as the technitium app).
FROM ${BUILD_FROM}

RUN apk add --no-cache jq

ARG CLICKHOUSE_VERSION=26.8.40.7
ENV CLICKHOUSE_VERSION=${CLICKHOUSE_VERSION} \
    CLICKHOUSE_DB=default \
    CLICKHOUSE_USER=default

COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

EXPOSE 8123 9000

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
