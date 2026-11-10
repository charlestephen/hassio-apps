# Home Assistant App: Ultimate CA Manager

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_[Ultimate CA Manager](https://github.com/NeySlim/ultimate-ca-manager) —
self-hosted Certificate Authority with ACME, SCEP, EST, OCSP, CRL, TSA, and
SSH CA. Thin wrapper on the official Docker image._

## About

This app maps Home Assistant options to UCM environment variables, persists
all PKI material under `/ssl/ucm/` (bind-mounted over upstream data volumes;
`/data/ucm` symlink for addon backups), auto-generates and persists
`KEY_ENCRYPTION_KEY`, then `exec`s the upstream entrypoint as **root**.

The app version tracks upstream releases via `upstream_repo`.

See [DOCS.md](DOCS.md) for storage layout, ports, and proxy settings.

## Credits

- [Ultimate CA Manager](https://github.com/NeySlim/ultimate-ca-manager) (AGPL-3.0-only) — NeySlim

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fultimate-ca-manager%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/ultimate-ca-manager
