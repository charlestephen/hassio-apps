ARG BUILD_FROM=ghcr.io/homarr-labs/homarr:v1.70.0

# Thin Home Assistant wrapper on Homarr's official image. Homarr is a
# self-contained monolith (its own entrypoint supervises redis + nginx +
# Next.js), so we do NOT add s6-overlay; we only inject the add-on options as
# environment variables and then hand off to Homarr's own entrypoint.
FROM ${BUILD_FROM}

# jq: parse /data/options.json in the wrapper entrypoint.
# openssl is already present in the Homarr image (used for SECRET_ENCRYPTION_KEY).
RUN apk add --no-cache jq

# Surface the Homarr version to the runtime entrypoint (for log output).
ARG HOMARR_VERSION=unknown
ENV HOMARR_VERSION=${HOMARR_VERSION}

# Wrapper entrypoint (options -> env -> exec Homarr's entrypoint)
COPY rootfs/ /
RUN chmod +x /ha-entrypoint.sh

EXPOSE 7575/tcp

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
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.authors="CharleStephen (https://github.com/charlestephen)" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
