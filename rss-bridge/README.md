# Home Assistant App: RSS-Bridge

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[RSS-Bridge](https://github.com/RSS-Bridge/rss-bridge) — generates Atom/RSS
feeds for websites that don't provide their own. Thin Home Assistant wrapper
around the official [`rssbridge/rss-bridge`][image] image. See
[DOCS.md](DOCS.md).

[image]: https://hub.docker.com/r/rssbridge/rss-bridge

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Frss-bridge%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/rss-bridge
