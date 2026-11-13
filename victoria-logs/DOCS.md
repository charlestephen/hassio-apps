# VictoriaLogs

Thin Home Assistant wrapper around the official
[VictoriaLogs](https://docs.victoriametrics.com/) image (`1.53.0`). The upstream binary
runs as in the image, with data in `/data` and a retention period you choose.

## Quick start

1. Install and start the app and open the UI on port `9428` (`/select/vmui/`).
2. Send logs:
   - OTLP/HTTP to `http://dd815a57-victoria-logs:9428/insert/opentelemetry` (a client appends
     `/v1/logs`). In the [OTLP Collector](../otlp-collector/) app, set **OTLP logs endpoint**
     to that base URL.
   - Loki push to `http://dd815a57-victoria-logs:9428/insert/loki/api/v1/push`. The
     [Grafana Alloy](../alloy/) app's **Loki push URL** accepts it.
3. In [Grafana](../grafana/), install the VictoriaLogs data source plugin (**Plugins**
   option `victoriametrics-logs-datasource`) and use `http://dd815a57-victoria-logs:9428`.

OTLP must be protobuf, which is the default for OpenTelemetry SDKs and the
Collector. JSON-encoded OTLP is rejected.

## Options

| Option | Meaning |
|--------|---------|
| Log level | `INFO`, `WARN`, `ERROR`, `FATAL` or `PANIC`. |
| Retention period | How long data is kept: a number (months for VictoriaMetrics) or a number with `h`, `d`, `w` or `y`, for example `30d`. |
| Extra flags | Any other upstream command-line flags, separated by spaces, for example `-memory.allowedPercent=40`. |

## Storage and backups

Everything is written to `/data`. Backups are cold: the app stops while the
backup runs. `dd815a57-victoria-logs:9428/health` reports health.
