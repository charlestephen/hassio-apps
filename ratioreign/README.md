# Home Assistant App: RatioReign

[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Headless BitTorrent ratio-farming daemon — sends realistic tracker announces
and simulated upload counters without transferring torrent data. Thin Home
Assistant wrapper around the official
[`ghcr.io/charlestephen/ratioreign`][upstream] image `2.1.0` (upstream
entrypoint preserved).

Open the Web UI on port **7070** to edit config, manage torrents, and wire up
RSS / qBittorrent sync. See [DOCS.md](DOCS.md).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v2.1.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/ratioreign
[upstream]: https://github.com/charlestephen/ratioreign
