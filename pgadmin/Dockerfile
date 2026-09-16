ARG BUILD_FROM=ghcr.io/hassio-addons/base:21.0.0
# pgAdmin's official image is Alpine 3.23 / Python 3.14 — the same as our base —
# so its virtualenv is relocatable onto the HA base image.
# renovate: datasource=docker depName=dpage/pgadmin4 versioning=docker
ARG PGADMIN_VERSION=9.17

# Stage 1: pgAdmin from the official image
FROM dpage/pgadmin4:${PGADMIN_VERSION} AS pgadmin

# Stage 2: final image on the HA base
FROM ${BUILD_FROM}

# Runtime libraries for pgAdmin's bundled Python 3.14 and its compiled
# extensions. (Alpine's own python3 is 3.12, which the cp314 venv can't use, so
# we bring pgAdmin's interpreter along instead of installing one.)
RUN apk add --no-cache \
      gdbm \
      icu-libs \
      krb5-libs \
      libbz2 \
      libedit \
      libffi \
      libgcc \
      libjpeg-turbo \
      libldap \
      libmd \
      libpq \
      libsasl \
      libstdc++ \
      libuuid \
      lmdb \
      mpdecimal \
      ncurses-libs \
      readline \
      sqlite-libs \
      xz-libs \
      zlib \
      ca-certificates \
      su-exec \
      shadow

# pgAdmin's official image bundles Python 3.14 under /usr/local (the
# python:alpine layout). Copy the interpreter, the app and its virtualenv so the
# cp314 extensions match their interpreter.
COPY --from=pgadmin /usr/local /usr/local
COPY --from=pgadmin /pgadmin4 /pgadmin4
COPY --from=pgadmin /venv /venv

# Let the musl loader find libpython3.14.so in /usr/local/lib.
ENV LD_LIBRARY_PATH=/usr/local/lib

# Copy local files
COPY rootfs/ /

# Corrects permissions for s6 v3
RUN if [ -d /etc/cont-init.d ]; then chmod -R 755 /etc/cont-init.d; fi && \
    if [ -d /etc/services.d ]; then chmod -R 755 /etc/services.d; fi

EXPOSE 5050

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
