# Home Assistant App: RatioReign

[![Build][build-shield]][build]
[![Release][release-shield]][release]

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

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v2.2.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/ratioreign
[upstream]: https://github.com/charlestephen/ratioreign

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
