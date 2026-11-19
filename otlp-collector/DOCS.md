# Home Assistant App: OTLP Collector

OpenTelemetry Collector Contrib as a Home Assistant app. It wraps the official
[`otel/opentelemetry-collector-contrib`](https://hub.docker.com/r/otel/opentelemetry-collector-contrib)
image `0.165.0`: the upstream binary is copied onto Alpine, options become a
collector YAML, then the wrapper **`exec`s**
`/usr/bin/otelcol-contrib --config …`.

By default, traces, metrics, and logs all export to the
[OpenObserve](../openobserve/) app in this repository with authentication
already wired up — install that app, set a username/password here, and
start. Mimir, VictoriaMetrics, or any other OTLP/Prometheus backend remain
fully supported as an override; see "Other backends" below.

## Default pipeline (no custom YAML)

With **OpenObserve URL/username/password** set (the default target — see
below) or an **OTLP endpoint** set:

| Signal | Sources | Export |
| --- | --- | --- |
| Metrics | OTLP receive, Docker stats, Home Assistant `/api/prometheus`, optional extra scrapes | OpenObserve or OTLP/HTTP (+ optional Prometheus remote_write) |
| Traces | OTLP receive (`:4317` / `:4318`) | OpenObserve or OTLP/HTTP |
| Logs | OTLP receive, host journal (`journald`, on by default) | OpenObserve or OTLP/HTTP |

Leave **Full collector YAML** empty to use this generated default. Paste a
complete YAML into that option to replace it entirely on every start.

### Docker container logs and Home Assistant/Supervisor system logs

This app requests Supervisor's `journald` permission by default (no
Protection Mode change, no extra option needed), which mounts the host's
system journal read-only and feeds it through the collector's `journald`
receiver automatically. On a Supervisor host where Docker's own logging
driver is `journald` — check with `docker info --format '{{.LoggingDriver}}'`
on the host; confirmed live on a real Supervisor install that this is the
case — this one mount recovers **both** halves of "all the logs": every
container's stdout/stderr (they're logged through journald, not Docker's
json-file driver) and Home Assistant Core/Supervisor's own system-level
output, all in the same journal stream, with no raw Docker socket and no
`/var/lib/docker/containers` file access (Supervisor has no `map` type for
that path at all — confirmed against the current app config reference).
If your host's Docker logging driver is `json-file` instead of `journald`,
this mechanism won't see container logs; check your host's own Docker
config (`/etc/docker/daemon.json`) rather than this app's options.

Optional auto-enable when paths exist in the container:

- `hostmetrics` if `/hostfs/proc` is mounted
- `filelog` for Docker json logs if `/var/lib/docker/containers` is mounted
  (no `map` type exposes this path, so this never actually triggers under
  Supervisor today — kept for a manual/non-Supervisor deployment with a
  custom bind mount)

Docker stats come from the [Docker Socket Proxy](../docker-socket-proxy/) app
(see below), so this app never needs the raw Docker socket. Host, journal and
filelog collection need extra mounts; use [Grafana Alloy](../alloy/) for
container log tailing.

## Quick start (default target: OpenObserve)

1. Install and start the [OpenObserve](../openobserve/) app in this
   repository first; set its **Root email** and **Root password**.
2. Install **OTLP Collector**. Set **OpenObserve URL** (default
   `http://dd815a57-openobserve:5080`, i.e. that app's own hostname — change
   it only if you renamed the app or point at an OpenObserve instance
   elsewhere), **OpenObserve username**/**password** (the same root email and
   password from step 1, or a service account you create later), and leave
   **OpenObserve organization** at `default` unless you made another one.
3. For Docker stats, set up the Docker Socket Proxy (see below). Without it
   the collector still runs and only skips container metrics.
4. (Recommended) Create a long-lived HA token and paste it into **Home Assistant
   access token**; keep **Scrape Home Assistant Prometheus** on.
5. Start. Point instrumented apps at `http://ha-host.example.com:4318`.

Traces, metrics, and logs all land in OpenObserve's `default` organization
(or **OpenObserve stream name**, if set) with no further configuration. Open
OpenObserve's own web UI on port `5080` to query them.

### Example app → collector

```text
OTEL_EXPORTER_OTLP_ENDPOINT=http://ha-host.example.com:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
```

## Other backends (Mimir, VictoriaMetrics, another collector, ...)

OpenObserve above is the default, but any signal can be redirected
independently:

- **A different OTLP-capable backend entirely** (another collector, Jaeger,
  Mimir's or VictoriaMetrics' own native OTLP endpoint): set **OTLP endpoint**
  (all signals) or **OTLP traces/metrics/logs endpoint** (one signal only).
  Whichever of these is set for a signal always wins over OpenObserve for
  that signal — you can mix freely, e.g. metrics to Mimir while traces and
  logs still go to OpenObserve.
- **Metrics only, via Prometheus remote_write** (the traditional
  VictoriaMetrics/Mimir path, as an addition to — not a replacement for —
  whatever is exporting metrics above): set **Prometheus remote_write
  endpoint** to the backend's `/api/v1/write`-style URL. This does not need
  OpenObserve credentials and has no effect on traces/logs.
- **A fully custom pipeline** none of the above options cover (auth
  extensions, additional processors, a backend with its own exporter type):
  paste a complete config into **Full collector YAML**; every other option is
  then ignored.

OpenObserve credentials (the `Authorization: Basic` header) are only ever
attached to exporters actually pointed at the configured OpenObserve URL —
setting an OTLP override for a signal sends that signal to its own endpoint
with no OpenObserve auth header attached.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `openobserve_url` | `http://dd815a57-openobserve:5080` | Default export target — this repository's OpenObserve app. |
| `openobserve_organization` | `default` | OpenObserve organization to ingest into. |
| `openobserve_username` / `openobserve_password` | *(empty)* | OpenObserve login used for the `Authorization: Basic` header. Required together to enable OpenObserve export. |
| `openobserve_stream` | *(empty)* | Optional custom OpenObserve stream name; empty uses its own `default` stream. |
| `otlp_endpoint` | *(empty)* | Advanced: shared OTLP/HTTP base for traces, metrics, and logs — overrides OpenObserve for every signal (e.g. Mimir, VictoriaMetrics, another collector). |
| `otlp_*_endpoint` | *(empty)* | Advanced: per-signal overrides of the above (and of OpenObserve, for just that signal). |
| `prometheus_remote_write_endpoint` | *(empty)* | Extra metrics sink (VictoriaMetrics / Mimir `remote_write`), in addition to whatever exports metrics above. |
| `compression` | `gzip` | Applied to every `otlphttp` exporter (traces, metrics, logs). `zstd`/`snappy`/`zlib`/`deflate`/`lz4` or `none`. Does not affect `prometheus_remote_write_endpoint`, which only supports `snappy`. |
| `enable_docker_stats` | `true` | Container metrics via Docker socket. |
| `scrape_homeassistant` | `true` | Scrape `homeassistant:<port>/api/prometheus`. |
| `ha_port` | `80` | Port Home Assistant serves on for that scrape (`8123` for a default install). |
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
