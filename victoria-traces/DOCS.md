# VictoriaTraces

Thin Home Assistant wrapper around the official
[VictoriaTraces](https://docs.victoriametrics.com/) image (`0.13.0`). The upstream binary
runs as in the image, with data in `/data` and a retention period you choose.

## Quick start

1. Install and start the app.
2. Send traces over OTLP/HTTP to `http://dd815a57-victoria-traces:10428/insert/opentelemetry`
   (a client appends `/v1/traces`). In the [OTLP Collector](../otlp-collector/) app, set
   **OTLP traces endpoint** to that base URL.
3. In [Grafana](../grafana/), add a Jaeger data source with URL
   `http://dd815a57-victoria-traces:10428/select/jaeger`.

## Options

| Option | Meaning |
|--------|---------|
| Log level | `INFO`, `WARN`, `ERROR`, `FATAL` or `PANIC`. |
| Retention period | How long data is kept: a number (months for VictoriaMetrics) or a number with `h`, `d`, `w` or `y`, for example `30d`. |
| Extra flags | Any other upstream command-line flags, separated by spaces, for example `-memory.allowedPercent=40`. |

## Storage and backups

Everything is written to `/data`. Backups are cold: the app stops while the
backup runs. `dd815a57-victoria-traces:10428/health` reports health.
