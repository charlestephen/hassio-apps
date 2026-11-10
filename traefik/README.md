# Home Assistant App: Traefik

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_[Traefik](https://traefik.io/) reverse proxy and load balancer for Home Assistant — file-based dynamic config, optional Let's Encrypt, dashboard via Ingress or port 8080._

## About

This app installs the official [Traefik](https://github.com/traefik/traefik)
binary (checksum-verified from GitHub Releases) on the Home Assistant base
image. Static config is generated from the Configuration tab (or a custom
file); dynamic routes live under `/config/dynamic/` by default
(`app_config` — the app's own folder, `addon_configs/<repo>_traefik/` on disk).

The app version tracks upstream Traefik releases via this repository's
upstream updater; wrapper-only fixes use a suffix (e.g. `3.7.17-1`).

See [DOCS.md](DOCS.md) for setup, options, and a starter dynamic config.

## Credits

- [Traefik](https://github.com/traefik/traefik) (MIT) — Traefik Labs

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Ftraefik%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/traefik
