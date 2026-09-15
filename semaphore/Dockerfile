ARG BUILD_FROM=ghcr.io/hassio-addons/base:21.0.0
ARG SEMAPHORE_VERSION=2.18.12
ARG TERRAFORM_VERSION=1.15.7
ARG OPENTOFU_VERSION=1.12.3

# Stage 1: pull the Semaphore binary from the upstream image (statically-linked
# Go binary with embedded web UI — no external assets needed).
FROM semaphoreui/semaphore:v${SEMAPHORE_VERSION} AS semaphore

# Stage 2: donor image for the Terraform CLI (static Go binary, official
# multi-arch image — no RUN steps, so cross-arch safe). OpenTofu can't be
# staged the same way: its official image ONBUILD-fails downstream builds
# (opentofu/opentofu#1931), so the binary is fetched from GitHub releases below.
FROM docker.io/hashicorp/terraform:${TERRAFORM_VERSION} AS terraform

# Final stage: build on HA base (Alpine 3.24, bashio + s6-overlay v3)
FROM ${BUILD_FROM}

# Runtime dependencies:
#   - ansible: Ansible automation (primary Semaphore use case)
#   - git: repository checkout for projects
#   - openssh-client: SSH connections to managed hosts
#   - sshpass: password-based SSH auth in Ansible inventory
#   - rsync: used by some Ansible modules (e.g. synchronize)
#   - python3: Ansible runtime requirement
#   - py3-requests / py3-jinja2: common Ansible collection deps
RUN apk add --no-cache \
      ansible \
      git \
      openssh-client \
      sshpass \
      rsync \
      python3 \
      py3-requests \
      py3-jinja2

# Copy the Semaphore binary from the upstream image
COPY --from=semaphore /usr/local/bin/semaphore /usr/local/bin/semaphore

# Terraform + OpenTofu CLIs for Semaphore's Terraform/OpenTofu app types.
# Semaphore invokes `terraform` / `tofu` from PATH (and runs `init` itself).
COPY --from=terraform /bin/terraform /usr/local/bin/terraform

ARG OPENTOFU_VERSION
ARG TARGETARCH
RUN wget -q "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_${TARGETARCH}.zip" \
      -O /tmp/tofu.zip \
    && unzip -q /tmp/tofu.zip tofu -d /usr/local/bin \
    && chmod 755 /usr/local/bin/tofu \
    && rm /tmp/tofu.zip

# Persistent state lives under /data/semaphore (SQLite database, task tmp files)
RUN mkdir -p /data/semaphore

# Copy local s6 service scripts and helpers
COPY rootfs/ /

# Ensure all s6-rc.d scripts are executable
RUN find /etc/s6-overlay/s6-rc.d -type f \( -name "up" -o -name "run" -o -name "finish" \) \
    -exec chmod 755 {} \;

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
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/charlestephen" \
    org.opencontainers.image.source="https://github.com/charlestephen/hassio-apps" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
