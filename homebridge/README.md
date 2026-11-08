# Home Assistant App: Homebridge

[![Build][build-shield]][build]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_HomeKit support for non-HomeKit devices — thin wrapper on the official
[`homebridge/homebridge`](https://hub.docker.com/r/homebridge/homebridge) image._

## About

Uses **host networking** + host D-Bus (no in-container Avahi by default),
mounts Supervisor data at `/homebridge` (upstream path), optional UI TLS
from `/ssl`, then `exec`s `/init`. Config UI on port **8581**. Version
tracks dated stable tags from
[docker-homebridge](https://github.com/homebridge/docker-homebridge).

See [DOCS.md](DOCS.md).

## Credits

- [Homebridge](https://github.com/homebridge/homebridge) (Apache-2.0)
- [docker-homebridge](https://github.com/homebridge/docker-homebridge)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
