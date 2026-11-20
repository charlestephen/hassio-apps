# Home Assistant App: Activepieces

## Overview

This app wraps [activepieces/activepieces](https://github.com/activepieces/activepieces)
`0.93.0`. The core app is MIT-licensed; a separate `packages/ee` tree under a
non-OSI Enterprise license exists upstream for paid features — this app
configures none of them, nothing here touches that code path.

Upstream's own image is Debian-based with a working shell and root user.
This app adds only `jq` (to read Supervisor's options), maps HA options to
`AP_*` environment variables, then **`exec`s** upstream's own entrypoint
unchanged (`tini -- ./docker-entrypoint.sh`), which picks `WORKER_AND_APP`
mode by default — server and worker in one process, confirmed from reading
that entrypoint script directly.

## Quick start

1. Install **Activepieces**. Set **Frontend URL** to the public URL you'll
   reach it at (e.g. `https://pieces.example.com`) — required, used for
   webhooks, OAuth redirects, and emailed links.
2. Leave **Encryption key** and **JWT secret** blank on first start — both
   are generated and persisted under `/data` automatically. Back them up;
   losing the encryption key makes stored connection credentials unreadable.
3. Start the app and open the web UI. Create the first account from the
   sign-up screen — there's no admin-email/password option here, because
   upstream has none; account creation is a UI flow, not an env var
   (confirmed against upstream's own environment-variables documentation).

That's it for a standalone instance — **Database** defaults to `pglite`
(embedded, no setup) and **Queue** defaults to `memory` (embedded, no
setup), matching upstream's own fully-standalone configuration path.

## Using PostgreSQL / Valkey instead

For production use (multiple workers, larger workloads), point Activepieces
at this repository's own apps instead of the embedded defaults:

1. Install and start the **PostgreSQL** app (and/or **Valkey**).
2. Set **Database** to `postgres`; **Database host/port/name/user/password**
   default to that app's own hostname (`dd815a57-postgres`) — create the
   `activepieces` role/database there yourself first (this app doesn't
   auto-create either, unlike the Authentik/Pocket ID apps in this
   repository — Activepieces has no admin-credential option for that).
3. Optionally set **Queue** to `standalone` and the matching Valkey
   host/port/password.

## Execution mode

**Execution mode** defaults to `UNSANDBOXED` — plain process `fork()`, no
special container privileges, supports npm packages in Code steps
(confirmed from upstream's own sandboxing documentation). `SANDBOX_CODE_ONLY`
adds a V8 isolate per Code step (no npm) with the same, no-privilege
requirement. Upstream's two stricter modes (`SANDBOX_PROCESS` /
`SANDBOX_CODE_AND_PROCESS`) need `CAP_SYS_ADMIN`/privileged mode and are
deliberately not exposed as options here — use **Extra environment
variables** (`AP_EXECUTION_MODE`) plus `full_access: true` in a fork of this
app if you need them.

## Ports

| Port | Purpose |
|---|---|
| `80/tcp` | Web UI and API (host port `8095` by default). |

## Data

`/data` holds the generated encryption key/JWT secret, the embedded PGLite
database (when **Database** is `pglite`), and upstream's own `cache`
directory (symlinked from `/usr/src/app/cache`, matching the one volume
upstream's own `docker-compose.yml` persists). All included in backups. With
external PostgreSQL, the database itself lives there instead and must be
backed up with that app.

## Notes

- Upstream: [activepieces/activepieces](https://github.com/activepieces/activepieces).
- Runs as root inside the container (upstream sets no `USER`).
- `env_vars` covers anything not exposed directly — file storage to S3
  (`AP_FILE_STORAGE_LOCATION=S3` + `AP_S3_*`), sandbox tuning, and more; see
  upstream's
  [environment variables reference](https://activepieces.com/docs/install/configuration/environment-variables).
