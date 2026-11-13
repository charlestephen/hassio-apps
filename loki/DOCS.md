# Grafana Loki

Thin Home Assistant wrapper around the official
[Loki](https://grafana.com/oss/loki/) image (`3.7.9`). It runs the single
binary with local filesystem storage under `/data/loki`, authentication off
(one tenant) and usage reporting off.

## Quick start

1. Install and start the app.
2. Point a log shipper at `http://dd815a57-loki:3100/loki/api/v1/push`. The
   [Grafana Alloy](../alloy/) app's default config does this when **Loki push
   URL** is set to that address.
3. In [Grafana](../grafana/), add a Loki data source with URL
   `http://dd815a57-loki:3100`.

`/ready` on port `3100` reports health. The app publishes host port `3101` by
default because PatchMon uses `3100`; other apps still reach it on `3100`.

## Options

| Option | Meaning |
|--------|---------|
| Log level | `debug`, `info`, `warn` or `error`. |
| Retention period | How long logs are kept (`744h`, `30d`, `12w`). `0` keeps everything. Applied by Loki's compactor. |

## Custom configuration

To use your own Loki configuration, put it at `loki.yaml` in the app's
configuration directory (`/addon_configs/<id>_loki/`, visible as `/config`
inside the app). When that file exists it replaces the generated config and the
options above are ignored. Store data under `/data/loki` so it is part of the
app's backups.

## Storage and backups

Everything is written to `/data/loki`. Backups are cold: the app stops while
the backup runs.
