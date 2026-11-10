ARG BUILD_FROM=docker.io/library/alpine:3.24

# Build PgBouncer from the upstream release tarball. Alpine's own package lags
# behind the latest release.
FROM ${BUILD_FROM} AS build
ARG PGBOUNCER_VERSION=1.26.1
# hadolint ignore=DL3018
RUN apk add --no-cache build-base libevent-dev openssl-dev c-ares-dev pkgconf curl \
    && curl -fsSL -o /tmp/pgbouncer.tar.gz \
      "https://github.com/pgbouncer/pgbouncer/releases/download/pgbouncer_$(echo "${PGBOUNCER_VERSION}" | tr . _)/pgbouncer-${PGBOUNCER_VERSION}.tar.gz" \
    && tar -xzf /tmp/pgbouncer.tar.gz -C /tmp \
    && cd "/tmp/pgbouncer-${PGBOUNCER_VERSION}" \
    && ./configure --prefix=/usr --with-openssl --with-cares --disable-evdns \
    && make -j"$(nproc)" pgbouncer \
    && install -D -m 755 pgbouncer /out/usr/bin/pgbouncer \
    && strip /out/usr/bin/pgbouncer

FROM ${BUILD_FROM}
# jq reads the app options; the PostgreSQL client creates the authentication
# role; su-exec drops root for the pooler.
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache libevent c-ares libssl3 libcrypto3 ca-certificates jq postgresql18-client su-exec \
    && adduser -D -H -s /sbin/nologin pgbouncer \
    && mkdir -p /etc/pgbouncer \
    && chown pgbouncer:pgbouncer /etc/pgbouncer

COPY --from=build /out/usr/bin/pgbouncer /usr/bin/pgbouncer
COPY --chmod=755 rootfs/ha-entrypoint.sh /ha-entrypoint.sh

ARG PGBOUNCER_VERSION=1.26.1
ENV PGBOUNCER_VERSION=${PGBOUNCER_VERSION}

EXPOSE 6432/tcp

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
    org.opencontainers.image.licenses="ISC" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

ENTRYPOINT ["/ha-entrypoint.sh"]
