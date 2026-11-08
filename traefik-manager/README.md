# Home Assistant App: Traefik Manager

[![Build][build-shield]][build]

A clean, self-hosted web UI for your [Traefik](https://traefik.io) reverse
proxy — routes, middlewares, certificates and logs, without editing YAML by
hand.

A thin Home Assistant wrapper around the official
[`ghcr.io/chr0nzz/traefik-manager`](https://github.com/chr0nzz/traefik-manager)
image. Multi-arch: `aarch64`, `amd64`.

See [DOCS.md](DOCS.md) for configuration, including OIDC/SSO and CrowdSec.

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
