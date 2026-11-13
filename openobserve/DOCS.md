# OpenObserve

Thin Home Assistant wrapper around the official
[OpenObserve](https://openobserve.ai/) image (`1.1.2`). It runs the single binary
with local disk storage under `/data/openobserve` and telemetry off.

## Quick start

1. Set **Root email** and **Root password**, then start the app. It does not start
   without them. They are used only when OpenObserve first creates its database;
   change the password in the UI afterwards.
2. Open the UI on port `5080` and sign in.
3. Send data over OTLP with basic authentication using the root account (or a
   service account). In the default organisation `default`:

   | Signal | OTLP/HTTP URL |
   |--------|---------------|
   | Logs | `http://dd815a57-openobserve:5080/api/default/v1/logs` |
   | Metrics | `http://dd815a57-openobserve:5080/api/default/v1/metrics` |
   | Traces | `http://dd815a57-openobserve:5080/api/default/v1/traces` |

   OTLP gRPC is on port `5081`. Authentication is a header,
   `Authorization: Basic <base64 of email:password>`. The
   [OTLP Collector](../otlp-collector/) app has no option for that header, so use
   its **Collector YAML** override with an `otlphttp` exporter and `headers`.

## Options

| Option | Meaning |
|--------|---------|
| Root email / password | Root account, required. |
| Retention days | How long data is kept. |
| Web URL | Public address, for links behind a reverse proxy. |
| Extra environment variables | Any other `ZO_*` setting. |

## Storage and backups

Data is on local disk in `/data/openobserve` (SQLite metadata). Backups are cold:
the app stops while the backup runs.
