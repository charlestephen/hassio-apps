# Home Assistant App: Traefik Manager Agent

Runs the **Traefik Manager Agent (TMA)** next to a Traefik instance on a
remote host, so the [Traefik Manager](../traefik-manager/) app running
elsewhere (e.g. on Home Assistant) can manage it.

A thin Home Assistant wrapper around the official
[`ghcr.io/chr0nzz/traefik-manager-agent`](https://github.com/chr0nzz/traefik-manager)
image. Multi-arch: `aarch64`, `amd64`.

See [DOCS.md](DOCS.md) for configuration.
