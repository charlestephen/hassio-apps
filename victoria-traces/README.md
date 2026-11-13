# Home Assistant App: VictoriaTraces

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Trace storage for Home Assistant: VictoriaTraces on port `10428`, with OTLP ingestion and a Jaeger-compatible query API.
Thin Home Assistant wrapper around [`victoriametrics/victoria-traces`][image] `0.13.0`. See
[DOCS.md](DOCS.md).

[image]: https://hub.docker.com/r/victoriametrics/victoria-traces

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fvictoria-traces%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/victoria-traces
