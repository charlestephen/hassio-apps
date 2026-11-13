# Grafana Tempo

Thin Home Assistant wrapper around the official
[Tempo](https://grafana.com/oss/tempo/) image (`3.1.1`). It runs monolithic mode
(`-target=all`, no Kafka) with local filesystem storage under `/data/tempo` and
usage reporting off.

## Quick start

1. Install and start the app.
2. Send traces over OTLP to `dd815a57-tempo:4317` (gRPC) or
   `http://dd815a57-tempo:4318` (HTTP). The
   [OTLP Collector](../otlp-collector/) app can forward to either.
3. In [Grafana](../grafana/), add a Tempo data source with URL
   `http://dd815a57-tempo:3200`.

`/ready` on port `3200` reports health.

## Network

The OTLP ports are reachable by other apps without any setting. They are not
published on the host by default because the OTLP Collector app already uses
`4317` and `4318`. Set a host port under **Network** to reach them from outside
Home Assistant.

## Options

| Option | Meaning |
|--------|---------|
| Log level | `debug`, `info`, `warn` or `error`. |
| Retention period | How long traces are kept (`336h`, `14d`). |

## Custom configuration

Put your own Tempo configuration at `tempo.yaml` in the app's configuration
directory (`/addon_configs/<id>_tempo/`, visible as `/config` inside the app).
When that file exists it replaces the generated config and the options above
are ignored. Keep storage paths under `/data/tempo` so they are backed up.

## Storage and backups

Local storage is meant for small and home deployments. Backups are cold: the
app stops while the backup runs.
