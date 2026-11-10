# UniFi API Server

Thin Home Assistant wrapper around the official
[UniFi API Server](https://github.com/sirkirby/unifi-mcp/tree/main/apps/api)
(`0.26.0`), a REST and read-only GraphQL service in front of UniFi Network,
Protect and Access. It shares its controller code with the UniFi MCP apps.

The API server stores its state (registered controllers, API keys, audit log) in
a SQLite file. Upstream has no PostgreSQL support, so this app has no PostgreSQL
options; the file lives in `/data` and is included in backups.

## Quick start

1. Install and start **UniFi API Server**.
2. Open the log and copy the bootstrap admin key printed on the first start. It
   is also kept in `/data/bootstrap-admin-key`.
3. Open the Web UI on port `8089`, sign in with that key and register your
   controller with its address and an API key.
4. Create scoped API keys for your clients.

REST resources are under `/v1/`, the health check is `/v1/health`, and the
OpenAPI document and GraphQL endpoint are described in the upstream docs.

## Options

| Option | Variable |
| --- | --- |
| State encryption key | `UNIFI_API_DB_KEY` |
| Log level | `UNIFI_API_LOGGING_LEVEL` |
| Read-only mode | `UNIFI_READ_ONLY` |
| Return sensitive fields | `UNIFI_API_REDACT_SENSITIVE_FIELDS=false` |

The app always sets `UNIFI_API_STATE_DIR=/data`, `UNIFI_API_DB_PATH=/data/state.db`
and listens on `8080`.

Back up the state encryption key with the data. Without it the stored controller
credentials cannot be read.

## Security

Anyone who holds an API key can call the actions its scopes allow. The port is
plain HTTP, so keep it on your LAN or put it behind a TLS reverse proxy.

## Extra environment variables

The box at the bottom of the options adds any other variable. Rows marked secret
stay masked in the UI and the log. They are applied last, so they override the
options above.
