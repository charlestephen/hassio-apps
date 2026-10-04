# Changelog

## 1.20.1
- Upgrade Grafana Alloy v1.19.2 -> 1.20.1.

> Upstream v1.20.1: https://github.com/grafana/alloy/releases/tag/v1.20.1
>
> ## [1.20.1](https://github.com/grafana/alloy/compare/v1.20.0...v1.20.1) (2026-09-28)
>
>
> ### Bug Fixes 🐛
>
> * **loki:** Add the timestamp to batch size calculation [backport] ([#7248](https://github.com/grafana/alloy/issues/7248)) ([3457a1c](https://github.com/grafana/alloy/commit/3457a1ccc8da558ffbd162c040a0d8ca62a0c54f)) (@grobinson-grafana)
> * **loki:** Include estimate for stream labels in batch size [backport] ([#7247](https://github.com/grafana/alloy/issues/7247)) ([b346475](https://github.com/grafana/alloy/commit/b346475ab6242f6d9762d37e3c26bee9f65126c0)) (@grobinson-grafana)
> * **loki:** Make loki_write_sent_bytes_total and loki_write_dropped_bytes_total count uncompressed bytes [backport] ([#7249](https://github.com/grafana/alloy/issues/7249)) ([575025a](https://github.com/grafana/alloy/commit/575025a43c8b204cb2e28edd7cb3a71e56455465)) (@grobinson-grafana)
> * **otelcol.connector.host_info:** Mirror upstream logic and fix potential sources of over-count [backport] ([#7253](https://github.com/grafana/alloy/issues/7253)) ([479eb6f](https://github.com/grafana/alloy/commit/479eb6f11b2149b8326d0d229601d977e2630aaf)) (@jcreixell)
> * **otelcol.receiver.cloudflare:** Default max_request_body_size to 20MiB [backport] ([#7254](https://github.com/grafana/alloy/issues/7254)) ([237fac7](https://github.com/grafana/alloy/commit/237fac76db82fd1466f920b577e4274d77bb244d)) (@sindef)
> * **prometheus.remote_write:** Tolerate unknown WAL record types on replay [backport] ([#7237](https://github.com/grafana/alloy/issues/7237)) ([a613be5](https://github.com/grafana/alloy/commit/a613be532ebd9cfa247039c5bee9c2c2ef185625)) (@kgeckhart)
>
> ## Upgrading
>
> Read the [release notes] for specific instructions on upgrading from older versions:
>
> [release notes]: https://grafana.com/docs/alloy/v1.20/release-notes/
>
> ## Installation
>
> Refer to our [installation guide] for how to install Grafana Alloy.
>
> [installation guide]: https://grafana.com/docs/alloy/v1.20/get-started/install/

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
