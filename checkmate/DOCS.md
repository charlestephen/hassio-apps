# Home Assistant App: Checkmate

## Overview

This app wraps [bluewave-labs/checkmate](https://github.com/bluewave-labs/checkmate)
`4.1.0` (AGPL-3.0). Checkmate requires an external MongoDB — confirmed from
its own `docker/docker-compose.yaml`: there's no embedded-database mode. This
app is wired to the [MongoDB](../mongodb/) app in this repository by
default, matching this repository's own convention of apps depending on a
shared database app rather than bundling one.

Upstream's image is Debian-based (`node:24-slim`), with a working shell but
no `jq`. This app adds only `jq`, starts as root to read Supervisor's
options (upstream itself runs as a non-root `node` user, same trade-off
this repository's Pocket ID app makes), then `exec`s upstream's own
entrypoint and command unchanged.

## Quick start

1. Install and start the **MongoDB** app. Note its **Root password**.
2. Install **Checkmate**. Set:
   - **Client host**: the public URL you'll reach it at (e.g.
     `https://checkmate.example.com`) — required.
   - **MongoDB password**: the MongoDB app's root password from step 1 (or
     a dedicated user's password, if you created one).
3. Leave **JWT secret** and **Encryption key** blank — both are generated
   and persisted under `/data` automatically on first start.
4. Start the app and open the web UI on port `52345`.

**MongoDB host/port/user/database** default to the MongoDB app's own
hostname (`dd815a57-mongodb`), port `27017`, user `root`, database
`checkmate` — change them only if you renamed that app, use a dedicated
user, or point at a different MongoDB instance entirely.

## Using a different MongoDB / custom connection

Set **Database connection string** directly to a full `mongodb://` URI to
bypass the MongoDB options above entirely — for a replica set, TLS, a
different host, or Mongo Atlas.

## Queue mode

**Queue mode** defaults to `primary` — a single Checkmate instance doing
both API serving and monitor execution, confirmed from upstream's own
`.env.example` as the standard single-instance setup. Set to `worker` only
if you're running multiple Checkmate instances behind a shared MongoDB and
splitting API/worker roles — not needed for a typical single-app install.

## Ports

| Port | Purpose |
|---|---|
| `52345/tcp` | Web UI and API. |
| `52346/tcp` | Internal `/livez` health check — not published; upstream's own reference compose doesn't publish it either. |

## Data

`/data` holds the generated JWT secret and encryption key. All actual
monitoring data (checks, history, users) lives in MongoDB and must be
backed up with that app — this app's container itself is stateless,
confirmed from upstream's own reference compose file (no volume on the
Checkmate service, only on `mongo`).

## Notes

- Upstream: [bluewave-labs/checkmate](https://github.com/bluewave-labs/checkmate).
- Image published on GHCR only (confirmed live — no Docker Hub listing).
- `env_vars` covers anything not exposed directly (`TOKEN_TTL`, `ORIGIN`,
  `LOG_LEVEL`, `QUEUE_PRIMARY_PROCESSES`, `STATUS_PAGE_THEMES_ENABLED`, …).
