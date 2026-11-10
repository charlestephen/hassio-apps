# Home Assistant App: RatioReign

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Headless BitTorrent ratio-farming daemon — sends realistic tracker announces
and simulated upload counters without transferring torrent data. Thin Home
Assistant wrapper around the official
[`ghcr.io/charlestephen/ratioreign`][upstream] image `2.2.0` (upstream
entrypoint preserved).

HTTP Basic Auth is **on by default** (auto-generated password on first start —
check the app log). Open the Web UI on port **7070** to edit config, manage
torrents, and wire up RSS / qBittorrent sync. See [DOCS.md](DOCS.md).

[upstream]: https://github.com/charlestephen/ratioreign

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fratioreign%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/ratioreign
