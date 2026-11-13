# Grafana Mimir

Thin Home Assistant wrapper around the official
[Mimir](https://grafana.com/oss/mimir/) image (`3.2.5`). It runs the monolithic
target with local filesystem storage under `/data/mimir`, a single tenant
(multi-tenancy off) and usage statistics off.

## Quick start

1. Install and start the app.
2. Send metrics with Prometheus remote write to
   `http://dd815a57-mimir:9009/api/v1/push`. The
   [OTLP Collector](../otlp-collector/) app's **Prometheus remote write
   endpoint** option accepts that URL.
3. In [Grafana](../grafana/), add a Prometheus data source with URL
   `http://dd815a57-mimir:9009/prometheus`.

`/ready` on port `9009` reports health. The listen port is `9009`, not
Mimir's `8080` default, so it does not collide with other apps on the host.

## Options

| Option | Meaning |
|--------|---------|
| Log level | `debug`, `info`, `warn` or `error`. |
| Retention period | How long blocks are kept (`90d`, `1y`). `0` keeps everything. |

## Custom configuration

Put your own Mimir configuration at `mimir.yaml` in the app's configuration
directory (`/addon_configs/<id>_mimir/`, visible as `/config` inside the app).
When that file exists it replaces the generated config and the options above
are ignored. Keep storage paths under `/data/mimir` so they are backed up.

## Storage and backups

Local storage is meant for small and home deployments. Backups are cold: the
app stops while the backup runs.
