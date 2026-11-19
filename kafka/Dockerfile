ARG BUILD_FROM=docker.io/apache/kafka:4.4.0

# Thin Home Assistant wrapper on Apache Kafka's official image. Adds jq to
# read the app options, then runs upstream's own /etc/kafka/docker/run script
# (which formats KRaft storage on first boot given CLUSTER_ID).
FROM ${BUILD_FROM}

USER root
RUN microdnf install -y jq || (apt-get update && apt-get install -y --no-install-recommends jq && rm -rf /var/lib/apt/lists/*)

ARG KAFKA_VERSION=4.4.0
ENV KAFKA_VERSION=${KAFKA_VERSION}

COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

EXPOSE 9092

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
