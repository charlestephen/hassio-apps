# Home Assistant App: Akvorado

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[Akvorado](https://github.com/akvorado/akvorado) — collects NetFlow/IPFIX/sFlow,
enriches it, exports it to ClickHouse, and visualizes it in a web console
(AGPL-3.0). This app runs akvorado's orchestrator, inlet, outlet and console
processes together in one container, using the **Kafka**, **ClickHouse** and
**Valkey** apps from this repository as its dependencies.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fakvorado%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/akvorado
