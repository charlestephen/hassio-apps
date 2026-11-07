# Official contrib image is FROM scratch (binary only). Copy that binary onto
# the Home Assistant base so the HA options wrapper has a shell, then exec the
# same upstream binary with --config.
#
# ARGs used in FROM must be declared before the first FROM (BuildKit).
ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable
ARG OTELCOL_VERSION=0.165.0

FROM docker.io/otel/opentelemetry-collector-contrib:${OTELCOL_VERSION} AS otelcol

FROM ${BUILD_FROM}

# Re-declare for use inside this stage.
ARG OTELCOL_VERSION=0.165.0
ENV OTELCOL_VERSION=${OTELCOL_VERSION}

RUN apk upgrade --no-cache \
    && apk add --no-cache jq

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
