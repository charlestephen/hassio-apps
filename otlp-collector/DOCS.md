# Home Assistant App: OTLP Collector

OpenTelemetry Collector Contrib as a Home Assistant app. It wraps the official
[`otel/opentelemetry-collector-contrib`](https://hub.docker.com/r/otel/opentelemetry-collector-contrib)
image `0.164.0`: the upstream binary is copied onto the HA base image, options
become a collector YAML, then the wrapper **`exec`s**
`/usr/bin/otelcol-contrib --config …`.

## Default pipeline (no custom YAML)

With **OTLP endpoint** set (and Protection mode off for Docker):

| Signal | Sources | Export |
| --- | --- | --- |
| Metrics | OTLP receive, Docker stats, Home Assistant `/api/prometheus`, optional extra scrapes | OTLP/HTTP (+ optional Prometheus remote_write) |
| Traces | OTLP receive (`:4317` / `:4318`) | OTLP/HTTP |
| Logs | OTLP receive | OTLP/HTTP |

Optional auto-enable when paths exist in the container:

- `hostmetrics` if `/hostfs/proc` is mounted
- `filelog` for Docker json logs if `/var/lib/docker/containers` is mounted
- `journald` if `/var/log/journal` or `/run/log/journal` is mounted

Stock Supervisor maps only give the Docker **socket** (with Protection mode
off), so Docker stats work out of the box; host/journal/filelog need extra
mounts or use [Grafana Alloy](../alloy/) for container log tailing.

## Quick start

1. Install **OTLP Collector**.
2. Turn **Protection mode → OFF** (required for Docker stats).
3. Set **OTLP endpoint** to your backend base URL, e.g.
   `http://24c4882f-victoria-logs:9428/insert/opentelemetry` or
   `http://tempo:4318`.
4. (Recommended) Create a long-lived HA token and paste it into **Home Assistant
   access token**; keep **Scrape Home Assistant Prometheus** on.
5. Start. Point instrumented apps at `http://<ha-host>:4318`.

### Example app → collector

```text
OTEL_EXPORTER_OTLP_ENDPOINT=http://homeassistant.local:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `otlp_endpoint` | *(empty)* | Shared OTLP/HTTP base for traces, metrics, and logs. |
| `otlp_*_endpoint` | *(empty)* | Optional per-signal overrides. |
| `prometheus_remote_write_endpoint` | *(empty)* | Extra metrics sink (VictoriaMetrics / Mimir). |
| `enable_docker_stats` | `true` | Container metrics via Docker socket. |
| `scrape_homeassistant` | `true` | Scrape `homeassistant:8123/api/prometheus`. |
| `ha_prometheus_token` | *(empty)* | Bearer token for that scrape. |
| `prometheus_scrape_targets` | *(empty)* | Extra comma-separated scrape targets. |
| `config_yaml` | *(empty)* | **Full collector YAML** — replaces the generated config every start. |
| `log_level` | `info` | Collector log verbosity. |

### Bring your own config

Paste a complete OpenTelemetry Collector config into **Full collector YAML**.
When that field is non-empty, none of the other options are applied (except the
binary still starts with that file). Use this for auth extensions, processors,
or backends the form does not cover.

Generated config (when not overridden) is written to `/data/collector.yaml`.

## Ports

| Port | Purpose |
| --- | --- |
| `4317/tcp` | OTLP gRPC |
| `4318/tcp` | OTLP HTTP |
| `8888/tcp` | Collector self-metrics |

Health check listens on **13133** inside the container (not published).

## Protection mode

**Off** for Docker stats. OTLP receive/export alone does not need the socket.

AppArmor profile name: `otlp_collector`.

## Notes

- Upstream:
  [opentelemetry-collector-contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib).
- track-upstream follows GitHub releases that also exist on Docker Hub as
  `otel/opentelemetry-collector-contrib:<version>`.
