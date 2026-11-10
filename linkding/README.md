# Home Assistant App: Linkding

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Self-hosted [Linkding](https://github.com/sissbruecker/linkding) bookmark
manager, wrapping `ghcr.io/sissbruecker/linkding:latest-alpine` with the HA
app framework.

- **SQLite** by default, persisted to the app's `/data` (backed up with HA).
- **Config UI** for the basics (admin user, background tasks) **plus arbitrary
  env-var injection** — set any `LD_*` variable without a rebuild.
- **Ingress** (HA sidebar) + direct port **9090**.

See [DOCS.md](DOCS.md).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Flinkding%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/linkding
