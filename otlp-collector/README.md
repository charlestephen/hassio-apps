# Home Assistant App: OTLP Collector

[![Release][release-shield]][release]

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

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v0.165.0-2-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/otlp-collector
[image]: https://hub.docker.com/r/otel/opentelemetry-collector-contrib
