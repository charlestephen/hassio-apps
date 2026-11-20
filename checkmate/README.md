# Home Assistant App: Checkmate

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[Checkmate](https://github.com/bluewave-labs/checkmate) — open-source uptime
and infrastructure monitoring (HTTP/ping/port/DNS/Docker/gRPC/WebSocket/
game-server checks). Thin Home Assistant wrapper around the official
[`checkmate`][image] image `4.1.0`; wired to this repository's
[MongoDB](../mongodb/) app by default. See [DOCS.md](DOCS.md).

[image]: https://github.com/bluewave-labs/checkmate/pkgs/container/checkmate

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fcheckmate%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/checkmate
