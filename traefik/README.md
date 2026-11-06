# Home Assistant App: Traefik

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_[Traefik](https://traefik.io/) reverse proxy and load balancer for Home Assistant — file-based dynamic config, optional Let's Encrypt, dashboard via Ingress or port 8080._

## About

This app installs the official [Traefik](https://github.com/traefik/traefik)
binary (checksum-verified from GitHub Releases) on the Home Assistant base
image. Static config is generated from the Configuration tab (or a custom
file); dynamic routes live under `/homeassistant/traefik/` by default
(HA config directory — `traefik/` next to `configuration.yaml` on disk).

The app version tracks upstream Traefik releases via this repository's
upstream updater.

See [DOCS.md](DOCS.md) for setup, options, and a starter dynamic config.

## Credits

- [Traefik](https://github.com/traefik/traefik) (MIT) — Traefik Labs

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
