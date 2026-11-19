# OpenObserve

Thin Home Assistant wrapper around the official
[OpenObserve Enterprise Edition](https://openobserve.ai/) image (`1.1.2`),
pulled from the [public AWS ECR mirror](https://gallery.ecr.aws/zinclabs/openobserve-enterprise)
rather than `o2cr.ai` directly (that registry needs credentials this build
doesn't have — confirmed denied). Same `/openobserve` binary path, same
`ZO_*` environment variables, same Basic Auth behavior as the Community
image this previously wrapped (confirmed by running both side by side), so
this is a drop-in replacement: same options, same `/data/openobserve`
layout, no changes needed to an existing install beyond updating the app.
Runs free with no license key — a key only unlocks Enterprise's paid
features (set it in-app under Management → License once you have one; this
app has no option for it). It runs the single binary with local disk
storage under `/data/openobserve` and telemetry off.

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
   [OTLP Collector](../otlp-collector/) app in this repository targets this
   app by default — just set its **OpenObserve username**/**password**
   options to the root account above (or a service account); it builds this
   header automatically. Sending from elsewhere still needs the header built
   by hand.

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
