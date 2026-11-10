# Home Assistant App: Traefik Manager

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

A clean, self-hosted web UI for your [Traefik](https://traefik.io) reverse
proxy — routes, middlewares, certificates and logs, without editing YAML by
hand.

A thin Home Assistant wrapper around the official
[`ghcr.io/chr0nzz/traefik-manager`](https://github.com/chr0nzz/traefik-manager)
image. Multi-arch: `aarch64`, `amd64`.

See [DOCS.md](DOCS.md) for configuration, including OIDC/SSO and CrowdSec.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Ftraefik-manager%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/traefik-manager
