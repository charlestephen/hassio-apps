# UnPoller

Thin Home Assistant wrapper around the official
[UnPoller](https://unpoller.com) image (`v5.9.4`). UnPoller polls a UniFi
controller and exports the data to Prometheus, InfluxDB and Loki.

UnPoller has no SQL database, so this app has no PostgreSQL options. Point it at
Prometheus, InfluxDB or Loki, which hold the history.

## Quick start

1. In the UniFi console, create an API key or a local read-only user with
   access to all sites.
2. Install **UnPoller** and set **Controller URL** and **Controller API key**
   (or user and password).
3. Start the app. Prometheus scrapes `http://<home-assistant>:9130/metrics`.

For a UniFi OS console, use the console address without a port, for example
`https://192.168.1.1`.

## Outputs

| Output | Turn on with | Port or target |
| --- | --- | --- |
| Prometheus | **Prometheus output** (default on) | `9130/tcp`, path `/metrics` |
| InfluxDB | set **InfluxDB URL** | the URL you give |
| Loki | set **Loki URL** | the URL you give |

Outputs that are not configured are disabled, so UnPoller does not retry them.

## Options

| Option | Variable |
| --- | --- |
| Controller URL / API key / user / password | `UP_UNIFI_DEFAULT_URL`, `_API_KEY`, `_USER`, `_PASS` |
| Verify TLS certificate | `UP_UNIFI_DEFAULT_VERIFY_SSL` |
| Sites | `UP_UNIFI_DEFAULT_SITE_0`, `_1`, ... |
| Save sites / DPI / IDS / events / alarms / anomalies | `UP_UNIFI_DEFAULT_SAVE_*` |
| Prometheus namespace | `UP_PROMETHEUS_NAMESPACE` |
| InfluxDB | `UP_INFLUXDB_URL`, `_USER`, `_PASS`, `_DB` |
| Loki | `UP_LOKI_URL`, `_USER`, `_PASS`, `_TENANT_ID` |
| Debug logging | `UP_POLLER_DEBUG` |

## Extra environment variables

The box at the bottom of the options adds any other `UP_*` variable, for example
a second controller with `UP_UNIFI_CONTROLLER_0_URL`. Rows marked secret stay
masked in the UI and the log. They are applied last, so they override the
options above.
