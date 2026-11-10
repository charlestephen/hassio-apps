# Home Assistant App: PatchMon

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Linux patch management and monitoring — the official
[PatchMon](https://github.com/PatchMon/PatchMon) server with a built-in cache._

## About

PatchMon shows which of your Linux hosts have pending updates. This app runs the
official server image next to a private Valkey cache and uses the PostgreSQL app
from this repository for its database. The version follows upstream releases.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [PatchMon](https://github.com/PatchMon/PatchMon) (AGPL-3.0)
- [Valkey](https://valkey.io) (BSD-3-Clause)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fpatchmon%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/patchmon
