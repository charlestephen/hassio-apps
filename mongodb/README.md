# Home Assistant App: MongoDB

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

MongoDB document database, used here as storage for other apps (e.g.
[Checkmate](../checkmate/)). Thin Home Assistant wrapper around the official
[`library/mongo`][image] image `8.0`. See [DOCS.md](DOCS.md).

[image]: https://hub.docker.com/_/mongo

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fmongodb%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/mongodb
