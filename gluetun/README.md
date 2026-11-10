# Home Assistant App: Gluetun

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Multi-provider VPN client (OpenVPN / WireGuard) with DNS-over-TLS, kill
switch, HTTP proxy, and Shadowsocks. Thin Home Assistant wrapper around the
official [`qmcgaw/gluetun`][image] image `v3.41.3` (upstream
`/gluetun-entrypoint` preserved). Source:
[qdm12/gluetun][upstream].

Needs `/dev/net/tun` and `NET_ADMIN`. Configure your provider in the app
options, then point LAN clients or other apps at the HTTP proxy (`8888`) or
Shadowsocks (`8388`). See [DOCS.md](DOCS.md).

[upstream]: https://github.com/qdm12/gluetun
[image]: https://hub.docker.com/r/qmcgaw/gluetun

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fgluetun%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/gluetun
