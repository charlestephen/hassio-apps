# Changelog

## 0.164.0

- First Home Assistant app release wrapping OpenTelemetry Collector Contrib
  `0.164.0` (`otel/opentelemetry-collector-contrib`).
- Thin wrapper: COPY upstream binary onto HA base (official image is
  `FROM scratch`), generate config from options, `exec otelcol-contrib`.
- Default receivers: OTLP (4317/4318), optional `docker_stats`, optional
  Prometheus scrape.
- Optional exporters: OTLP/HTTP traces, metrics, logs; Prometheus remote_write.
- track-upstream via `upstream_repo` + Docker Hub image gate.

> Upstream v0.164.0: https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.164.0
