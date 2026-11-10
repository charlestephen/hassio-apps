# Home Assistant App: Dockhand

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Docker management UI - thin wrapper on the official Dockhand image._

## About

[Dockhand](https://dockhand.pro) manages Docker containers, Compose stacks, images and volumes. This app maps Home Assistant options to Dockhand's variables, uses the PostgreSQL app in this repository for its database, and runs the upstream entrypoint. Use it with the Hawser Agent for Dockhand app to manage other hosts.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [Dockhand](https://github.com/Finsys/dockhand)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fdockhand%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/dockhand
