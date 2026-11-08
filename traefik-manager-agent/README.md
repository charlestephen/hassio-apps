# Home Assistant App: Traefik Manager Agent

[![Build][build-shield]][build]

Runs the **Traefik Manager Agent (TMA)** next to a Traefik instance on a
remote host, so the [Traefik Manager](../traefik-manager/) app running
elsewhere (e.g. on Home Assistant) can manage it.

A thin Home Assistant wrapper around the official
[`ghcr.io/chr0nzz/traefik-manager-agent`](https://github.com/chr0nzz/traefik-manager)
image. Multi-arch: `aarch64`, `amd64`.

See [DOCS.md](DOCS.md) for configuration.

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
