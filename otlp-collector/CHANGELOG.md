# Changelog

## 0.164.0

- Default pipeline: shared `otlp_endpoint` exports traces, metrics, and logs;
  Docker stats + Home Assistant Prometheus scrape on by default; optional
  per-signal overrides and Prometheus remote_write; `config_yaml` still
  replaces the generated config entirely.
- Best-effort `hostmetrics` / Docker `filelog` / `journald` when those host
  paths are mounted into the container.
- First Home Assistant app release wrapping OpenTelemetry Collector Contrib
  `0.164.0` (`otel/opentelemetry-collector-contrib`).
- Thin wrapper: COPY upstream binary onto HA base (official image is
  `FROM scratch`), generate config from options, `exec otelcol-contrib`.
- track-upstream via `upstream_repo` + Docker Hub image gate.

> Upstream v0.164.0: https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.164.0

