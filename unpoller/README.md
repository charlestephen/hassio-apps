# Home Assistant App: UnPoller

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_UniFi metrics for Prometheus, InfluxDB and Loki - thin wrapper on the official UnPoller image._

## About

[UnPoller](https://github.com/unpoller/unpoller) polls a UniFi controller and exports devices, clients, sites and events to Prometheus, InfluxDB and Loki. This app maps Home Assistant options to `UP_*` variables and runs the upstream binary. UnPoller has no SQL database, so there are no PostgreSQL options.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [UnPoller](https://github.com/unpoller/unpoller) (MIT)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Funpoller%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/unpoller
