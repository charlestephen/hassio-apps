# Changelog

## 1.19.2

- Upgrade Grafana Alloy v1.17.1 -> v1.19.2.

## 1.17.1-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-alloy-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 1.17.0.a

- Upgrade base image from `ghcr.io/home-assistant/base:3.23` to `3.24` (Alpine
  3.24). Brings musl 1.2.5, OpenSSL 3.4, and the latest Python 3.12 patch. No
  change to Alloy configuration or behaviour.

## 1.17.0

- Upgrade Grafana Alloy from `v1.16.2` to `v1.17.0`. Key upstream changes:
  - `otelcol.*` components updated to OpenTelemetry Collector v0.121.
  - `prometheus.operator.*` components add support for scraping `ScrapeConfig`
    custom resources directly.
  - Improved health reporting: `loki.write` now surfaces per-stream send errors
    in the component health endpoint.
  - Minor CPU overhead reduction in `loki.process` when no stage drops a log
    line.
  See the [upstream release notes](https://github.com/grafana/alloy/releases/tag/v1.17.0) for the full list.

## 1.16.2.d

- Grant the AppArmor profile access to `/etc/s6-overlay` so `s6-rc-compile` can
  read the service database at boot (fixes the `s6-rc-compile … Permission
  denied` error under enforcement).

## 1.16.2.c

- Grant the AppArmor profile read access to `/init` and the s6/bashio scripts
  (`ix` → `rix`) so s6-overlay can start under AppArmor enforcement.

## 1.16.2.b

- Add an AppArmor profile (`apparmor.txt`) so the app runs confined under
  Home Assistant. It grants Alloy access to the host Docker socket
  (`/run/docker.sock` / `/var/run/docker.sock`), `/data`, `/config` and outbound
  networking. If you hit unexpected permission errors, set `apparmor: false` in
  the app config to fall back to the default profile.

## 1.16.2.a

- **Docker socket:** the built-in default config now points at
  `/var/run/docker.sock` instead of `/run/docker.sock`. Both refer to the same
  socket — the Supervisor bind-mounts the host Docker socket at
  `/run/docker.sock`, and `/var/run/docker.sock` is its symlink on the Alpine
  base image — so log collection is unchanged. Protection mode must still be
  disabled for the socket to be mounted (see DOCS).

## 1.16.2

- Align the app version with the bundled Grafana Alloy release (`v1.16.2`) so
  upstream auto-updates bump a version Home Assistant can see.

## 1.0.0

- Initial release.
- Grafana Alloy `v1.16.2` on the Home Assistant Alpine base image (`base:3.23`).
- Ships all host container logs to Loki by default via the Docker socket.
- Config precedence: `/config/config.alloy` file → inline `alloy_config` option →
  built-in default.
- Exposes the Alloy HTTP UI / metrics on port `12345`.
