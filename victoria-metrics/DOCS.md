# VictoriaMetrics

Thin Home Assistant wrapper around the official
[VictoriaMetrics](https://docs.victoriametrics.com/) image (`1.156.0`). The upstream binary
runs as in the image, with data in `/data` and a retention period you choose.

## Quick start

1. Install and start the app and open the UI on port `8428` (`/vmui/`).
2. Send metrics:
   - Prometheus remote write to `http://dd815a57-victoria-metrics:8428/api/v1/write`.
   - OTLP/HTTP to `http://dd815a57-victoria-metrics:8428/opentelemetry` (a client appends
     `/v1/metrics`). In the [OTLP Collector](../otlp-collector/) app, set **OTLP metrics
     endpoint** to that base URL, or use **Prometheus remote write endpoint**.
3. In [Grafana](../grafana/), add a Prometheus data source with URL
   `http://dd815a57-victoria-metrics:8428`.

OTLP must be protobuf, which is the default for OpenTelemetry SDKs and the
Collector. JSON-encoded OTLP is rejected.

## Scraping

VictoriaMetrics can scrape targets itself. Put a Prometheus-style scrape config
at `scrape.yml` in the app's configuration directory
(`/addon_configs/<id>_victoria_metrics/`, visible as `/config` inside the app)
and it is loaded with `-promscrape.config`. Without that file, scraping is off.

## Options

| Option | Meaning |
|--------|---------|
| Log level | `INFO`, `WARN`, `ERROR`, `FATAL` or `PANIC`. |
| Retention period | How long data is kept: a number (months for VictoriaMetrics) or a number with `h`, `d`, `w` or `y`, for example `30d`. |
| Extra flags | Any other upstream command-line flags, separated by spaces, for example `-memory.allowedPercent=40`. |

## Storage and backups

Everything is written to `/data`. Backups are cold: the app stops while the
backup runs. `dd815a57-victoria-metrics:8428/health` reports health.
