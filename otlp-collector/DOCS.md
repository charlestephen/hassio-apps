# Home Assistant App: OTLP Collector

OpenTelemetry Collector Contrib as a Home Assistant app. It wraps the official
[`otel/opentelemetry-collector-contrib`](https://hub.docker.com/r/otel/opentelemetry-collector-contrib)
image `0.164.0`: the upstream binary is copied onto the HA base image (the
upstream container is `FROM scratch`), options become a collector YAML, then
the wrapper **`exec`s** `/usr/bin/otelcol-contrib --config …`.

## What this app is for

| Signal | How it gets in | Typical export |
| --- | --- | --- |
| Traces | OTLP gRPC `:4317` / HTTP `:4318` | Tempo / any OTLP traces URL |
| Metrics | OTLP + optional Docker stats + optional Prometheus scrape | OTLP metrics and/or Prometheus remote_write |
| Logs | OTLP (apps push here) | Loki OTLP (`http://loki:3100/otlp`) or any OTLP logs URL |

**Container stdout/stderr logs** are best collected with the existing
[Grafana Alloy](../alloy/) app (`loki.source.docker`). The Collector has no
first-class Docker-logs API receiver; Alloy already solves that on HA OS.

## Protection mode

Turn **Protection mode off** if you enable **Docker stats**. The Supervisor
only mounts the host Docker socket when protection is disabled. OTLP receive /
export alone does not need the socket.

## Quick start

1. Install **OTLP Collector**.
2. Set at least one exporter URL (traces, metrics, and/or logs). With none set,
   the app uses a `debug` exporter so it still starts for bring-up.
3. Optionally enable Docker stats and/or Prometheus scrape targets.
4. Start the app. Point instrumented apps at
   `http://<ha-host>:4318` (OTLP/HTTP) or `:4317` (OTLP/gRPC).

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `log_level` | `info` | Collector log verbosity. |
| `enable_docker_stats` | `true` | `docker_stats` receiver on `unix:///var/run/docker.sock`. |
| `prometheus_scrape_targets` | *(empty)* | Comma-separated scrape targets (`host:port` or URL). |
| `otlp_traces_endpoint` | *(empty)* | Base URL for `otlphttp` traces (e.g. `http://tempo:4318`). |
| `otlp_metrics_endpoint` | *(empty)* | Base URL for `otlphttp` metrics. |
| `otlp_logs_endpoint` | *(empty)* | Base URL for `otlphttp` logs (e.g. `http://loki:3100/otlp`). |
| `prometheus_remote_write_endpoint` | *(empty)* | Prometheus / Mimir remote_write URL. |
| `config_yaml` | *(empty)* | Full collector YAML; overwrites `/data/collector.yaml` every start. |

### Example

```yaml
log_level: info
enable_docker_stats: true
prometheus_scrape_targets: "homeassistant:8123"
otlp_traces_endpoint: "http://tempo:4318"
otlp_metrics_endpoint: ""
otlp_logs_endpoint: "http://loki:3100/otlp"
prometheus_remote_write_endpoint: "http://mimir:9009/api/v1/push"
config_yaml: ""
```

Generated config is stored at `/data/collector.yaml`.

## Ports

| Port | Purpose |
| --- | --- |
| `4317/tcp` | OTLP gRPC |
| `4318/tcp` | OTLP HTTP |
| `8888/tcp` | Collector self-metrics (Prometheus format) |

Health check listens on **13133** inside the container (not published by default).

## Coexistence with Alloy

- **Alloy** — Docker container logs → Loki (and optional host metrics).
- **OTLP Collector** — OTLP hub for traces/metrics/logs from apps, Docker
  stats metrics, optional Prometheus scrape, export to your backends.

Use both; do not expect this app to replace Alloy’s Docker log tailing.

## Notes

- Upstream docs:
  [opentelemetry-collector-contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib).
- track-upstream bumps when GitHub releases a tag that also exists on Docker
  Hub as `otel/opentelemetry-collector-contrib:<version>` (Hub tags omit `v`).
- Image pin follows Hub availability (e.g. `0.164.0` when `0.164.1` is not
  published yet).
