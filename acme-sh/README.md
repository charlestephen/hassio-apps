# Home Assistant App: Acme.sh

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Certificate client built on the official `ghcr.io/acmesh-official/acme.sh`
image. Issues and renews certificates and runs deploy hooks. The
default store for each name is `/ssl/acme.sh/<domain>`, linked from
`/data/acme.sh/<domain>`.

acme.sh upgrades itself on start and before each renewal. The image is not
pinned to a release.

See [DOCS.md](DOCS.md) for setup.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Facme-sh%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/acme-sh
