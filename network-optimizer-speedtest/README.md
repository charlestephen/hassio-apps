# Home Assistant App: Network Optimizer Speed Test

[![Build][build-shield]][build]
[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

OpenSpeedTest frontend customized by Ozark Connect so results post back to
**Network Optimizer**. Thin wrapper around
[`ghcr.io/ozark-connect/speedtest`][image] `2.10.7` (upstream
`/docker-entrypoint.sh` preserved).

Requires the companion **[Network Optimizer](../network-optimizer/)** app.
Use the **same** `host_name` / `host_ip` / `reverse_proxied_host_name` values
on both apps so the assigned URL is followed for result reporting and
canonical redirects. See [DOCS.md](DOCS.md).

Web UI: host port **3005** (container 3000).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v2.10.7-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/network-optimizer-speedtest
[image]: https://ghcr.io/ozark-connect/speedtest

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
