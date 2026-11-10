# PatchMon

[PatchMon](https://github.com/PatchMon/PatchMon) (`2.1.8`) is a Linux patch
management and monitoring platform. Agents on your servers report to it, and it
shows which hosts have updates, which are out of date, and what changed.

## Quick start

1. Install and start the **PostgreSQL** app from this repository.
2. Install **PatchMon** and set:
   - **Server URL**: the address you open PatchMon at, for example
     `http://homeassistant.local:3100`.
   - **Database password**: a new password for the database login.
   - **PostgreSQL admin password**: the PostgreSQL app's superuser password. With
     it, PatchMon creates its database and login on every start. Leave it empty
     if you create them yourself.
3. Start the app and open the web UI on port `3100`. On first use PatchMon shows
   a setup wizard that creates the first administrator.

## What is inside

PatchMon needs PostgreSQL and a Redis-compatible cache. PostgreSQL is the
PostgreSQL app. The cache is [Valkey](https://valkey.io), which runs inside this
app on the loopback address with a generated password, so nothing else can reach
it. It keeps no data on disk, so it starts empty each time; PatchMon rebuilds
what it needs. The signing and encryption keys PatchMon needs are generated on
first start and kept in `/data/secrets`, which is included in backups. Back them
up: losing them signs everyone out and makes stored secrets unreadable.

The optional in-browser RDP feature needs the separate `guacd` service, which is
not included.

## Options

| Option | Meaning |
|--------|---------|
| Server URL | Required. Where you open PatchMon. Comma-separate several addresses. |
| PostgreSQL host / port | Leave the host empty to find the PostgreSQL app. |
| Database name / user / password | The database PatchMon uses. The password is required. |
| PostgreSQL admin user / password | Used to create the database and login. |
| Trust proxy | Turn on behind a reverse proxy. |
| Log level | `debug`, `info`, `warn` or `error`. |
| Timezone | Optional, for example `Europe/London`. |
| Extra environment variables | Any other PatchMon setting, such as the OIDC variables. |

## Behind a reverse proxy

Set **Server URL** to the public address, for example
`https://patchmon.example.com`, and turn on **Trust proxy**. Agents connect
outbound to that address, so it must be reachable from your servers.

## Single sign-on

PatchMon supports OIDC. Add the variables from the PatchMon documentation under
**Extra environment variables**, for example with Authentik from this repository
as the provider.

## Ports

| Port | Use |
|------|-----|
| `3100/tcp` | Web UI and agent API (the app listens on 3000 inside) |
