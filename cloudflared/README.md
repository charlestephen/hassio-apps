# Home Assistant App: Cloudflared

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Dual-replica [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
for high availability, built on the stock `cloudflare/cloudflared` image.

- Runs **two connector replicas** (`cloudflared0`, `cloudflared1`) of one
  remotely-managed tunnel — Cloudflare-native load-balancing & failover.
- Paste your **connector token** into the Home Assistant UI; routing is managed
  in the Cloudflare Zero Trust dashboard.
- **Prometheus metrics** per replica (`:36400`, `:36401`) for VictoriaMetrics.
- **Auto-updates** with upstream cloudflared (Renovate + Forgejo CI);
  cloudflared's own self-updater is disabled.

See [DOCS.md](DOCS.md) for setup.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fcloudflared%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/cloudflared
