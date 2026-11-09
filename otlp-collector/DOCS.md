# Home Assistant App: OTLP Collector

OpenTelemetry Collector Contrib as a Home Assistant app. It wraps the official
[`otel/opentelemetry-collector-contrib`](https://hub.docker.com/r/otel/opentelemetry-collector-contrib)
image `0.165.0`: the upstream binary is copied onto Alpine, options become a
collector YAML, then the wrapper **`exec`s**
`/usr/bin/otelcol-contrib --config …`.

## Default pipeline (no custom YAML)

With **OTLP endpoint** set:

| Signal | Sources | Export |
| --- | --- | --- |
| Metrics | OTLP receive, Docker stats, Home Assistant `/api/prometheus`, optional extra scrapes | OTLP/HTTP (+ optional Prometheus remote_write) |
| Traces | OTLP receive (`:4317` / `:4318`) | OTLP/HTTP |
| Logs | OTLP receive | OTLP/HTTP |

Leave **Full collector YAML** empty to use this generated default. Paste a
complete YAML into that option to replace it entirely on every start.

Optional auto-enable when paths exist in the container:

- `hostmetrics` if `/hostfs/proc` is mounted
- `filelog` for Docker json logs if `/var/lib/docker/containers` is mounted
- `journald` if `/var/log/journal` or `/run/log/journal` is mounted

Docker stats come from the [Docker Socket Proxy](../docker-socket-proxy/) app
(see below), so this app never needs the raw Docker socket. Host, journal and
filelog collection need extra mounts; use [Grafana Alloy](../alloy/) for
container log tailing.

## Quick start

1. Install **OTLP Collector**.
2. For Docker stats, set up the Docker Socket Proxy (next section). Without it
   the collector still runs and only skips container metrics.
3. Set **OTLP endpoint** to your backend base URL, e.g.
   `http://otel-backend.example.com:4318` or
   `http://logs.example.com:9428/insert/opentelemetry`.
4. (Recommended) Create a long-lived HA token and paste it into **Home Assistant
   access token**; keep **Scrape Home Assistant Prometheus** on.
5. Start. Point instrumented apps at `http://ha-host.example.com:4318`.

### Example app → collector

```text
OTEL_EXPORTER_OTLP_ENDPOINT=http://ha-host.example.com:4318
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
| `8888/tcp` | Collector self-metrics (host port `8889` by default) |

Health check listens on **13133** inside the container (not published).

## Docker stats

Container metrics are read through the Docker Socket Proxy app in this
repository, which filters the Docker API:

1. Install and start **Docker Socket Proxy**. Turn its **Protection mode OFF**
   (it is the only app that mounts the socket).
2. In its options, turn **Containers** on. **Events** is already on.
3. Leave **Docker host** here at its default,
   `tcp://dd815a57-docker-socket-proxy:2375`. The hostname is the app slug
   with the repository prefix, so it differs if you added a fork under another
   URL; the Supervisor shows the name on the proxy's Info page.

The collector waits up to 20 seconds for the proxy at start. If it cannot
connect it starts without Docker stats and logs a warning; restart it after
the proxy is running. Turn **Enable Docker stats** off to skip all of this.

## Protection mode

Leave **on**. This app does not use the Docker socket.

AppArmor profile name: `otlp_collector`.

## Notes

- Upstream:
  [opentelemetry-collector-contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib).
- track-upstream follows GitHub releases that also exist on Docker Hub as
  `otel/opentelemetry-collector-contrib:<version>`.
