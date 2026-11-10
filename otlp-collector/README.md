# Home Assistant App: OTLP Collector

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

OpenTelemetry Collector Contrib — receive **logs**, **traces**, and **metrics**
over OTLP, scrape Docker container stats + Home Assistant Prometheus, and
export to a user-chosen OTLP endpoint (optional full `config_yaml` override).
Thin Home Assistant wrapper around
[`otel/opentelemetry-collector-contrib`][image] `0.165.0` (upstream binary
`otelcol-contrib` preserved).

For **container log shipping to Loki via the Docker socket**, keep using the
[Grafana Alloy](../alloy/) app. This collector is the OTLP hub and metrics /
traces path. See [DOCS.md](DOCS.md).

[image]: https://hub.docker.com/r/otel/opentelemetry-collector-contrib

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fotlp-collector%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/otlp-collector
