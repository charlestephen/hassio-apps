# Home Assistant App: Terrastate

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[Terrastate](https://github.com/webhippie/terrastate) — a self-hosted
Terraform HTTP state backend, with basic auth and optional at-rest
encryption. Thin Home Assistant wrapper around the official
[`webhippie/terrastate`][image] image `2.11.4` (upstream binary and
entrypoint preserved). See [DOCS.md](DOCS.md).

[image]: https://hub.docker.com/r/webhippie/terrastate

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fterrastate%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/terrastate
