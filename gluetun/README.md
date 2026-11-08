# Home Assistant App: Gluetun

[![Build][build-shield]][build]
[![Release][release-shield]][release]

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

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v3.41.3-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/gluetun
[upstream]: https://github.com/qdm12/gluetun
[image]: https://hub.docker.com/r/qmcgaw/gluetun

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
