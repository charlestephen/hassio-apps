# Grafana

Thin Home Assistant wrapper around the official
[Grafana](https://grafana.com/oss/grafana/) image (`13.3.1`). Grafana's database,
plugins and settings live in `/data/grafana`, so they are part of the app's
backups.

## Quick start

1. Install and start the app, then open the web UI on host port `3030`
   (Grafana listens on `3000` inside the app; other apps already use `3000`
   on the host).
2. Sign in as `admin`. With no **Admin password** set, the upstream default is
   `admin` and Grafana asks you to change it at first sign-in.
3. Add data sources with these URLs (the apps reach each other by name):

   | App | Data source | URL |
   |-----|-------------|-----|
   | [Loki](../loki/) | Loki | `http://dd815a57-loki:3100` |
   | [Tempo](../tempo/) | Tempo | `http://dd815a57-tempo:3200` |
   | [Mimir](../mimir/) | Prometheus | `http://dd815a57-mimir:9009/prometheus` |

## Options

| Option | Meaning |
|--------|---------|
| Admin user / password | Applied only when Grafana creates its database. Change the password in the UI afterwards. |
| Root URL | Public address, for links and OAuth callbacks behind a reverse proxy. |
| Plugins | Comma-separated plugin IDs installed on start. |
| Log level | `debug`, `info`, `warn` or `error`. |
| Extra environment variables | Any other `GF_*` setting, for example `GF_AUTH_GENERIC_OAUTH_*` for OIDC sign-in with Pocket ID. |

## Provisioning

Files placed in `provisioning/` inside the app's configuration directory
(`/addon_configs/<id>_grafana/`, visible as `/config` inside the app) are read
as Grafana provisioning: `datasources/`, `dashboards/`, `alerting/` and
`plugins/`. When that directory exists, the app points `GF_PATHS_PROVISIONING`
at it, so it replaces Grafana's built-in (empty) provisioning directory.

## Database

Grafana uses SQLite in `/data/grafana`. To use the PostgreSQL app instead, set
`GF_DATABASE_TYPE=postgres`, `GF_DATABASE_HOST`, `GF_DATABASE_NAME`,
`GF_DATABASE_USER` and `GF_DATABASE_PASSWORD` under **Extra environment
variables**.
