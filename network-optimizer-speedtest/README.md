# Home Assistant App: Network Optimizer Speed Test

[![Build][build-shield]][build]
[![Version][version-shield]][version]
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

[image]: https://ghcr.io/ozark-connect/speedtest

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fnetwork-optimizer-speedtest%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/network-optimizer-speedtest
