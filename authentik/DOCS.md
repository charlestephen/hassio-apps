# Authentik

Thin Home Assistant wrapper around the official
[authentik](https://goauthentik.io) image (`2026.8.5`). The upstream
entrypoint runs in `allinone` mode, so the server and the worker run in one
container.

## Quick start

1. Install and start the **PostgreSQL** app from this repository.
2. Install **Authentik**. In its configuration set:
   - **Database password**: a new password for the `authentik` role.
   - **Database admin password**: the PostgreSQL app's superuser password. With
     it, the app creates the `authentik` role and database on start. Leave it
     empty if you create them yourself.
3. Optionally set **Initial admin email** and **Initial admin password** for the
   `akadmin` account. Without them, open `/if/flow/initial-setup/` on first
   start and set the password there.
4. Start the app and open the web UI on port `9000`.

If you create the database yourself instead, make the database user its owner,
because PostgreSQL 15 and later do not let other roles create tables in `public`:

```sql
ALTER DATABASE authentik OWNER TO authentik;
\c authentik
GRANT ALL ON SCHEMA public TO authentik;
```

## Options

| Option | Meaning |
|--------|---------|
| Database host / port / name / user / password | Connection to PostgreSQL. The PostgreSQL app is `dd815a57-postgres`. |
| Database admin user / password | Used only to create the role and database. |
| Secret key | Leave empty to generate one on first start (`/data/.secret_key`). Back it up. |
| Initial admin email / password | First start only. |
| Log level | `trace`, `debug`, `info`, `warning` (default) or `error`. At `info` every request, including each relying party's token and userinfo calls, is logged as a line of about 430 bytes. |
| Extra environment variables | Any other `AUTHENTIK_*` variable. |

## Behind a reverse proxy

authentik trusts `X-Forwarded-*` headers from private address ranges by default,
so a Traefik app on the same host works without extra settings. Use the public
HTTPS address when you register OIDC redirect URIs.

## Ports

| Port | Use |
|------|-----|
| `9000/tcp` | Web UI and OIDC endpoints (HTTP) |
| `9443/tcp` | Same, HTTPS with a self-signed certificate |

## Running on an SD card

The default log level is `warning`, which cuts request logging to almost nothing
(200 requests logged about 2.5 KB instead of about 86 KB in testing). Existing
installs keep the level they already have, so set **Log level** to `warning`
yourself. Authentik also stores events in PostgreSQL; lowering the event
retention in **System > Settings** in the admin interface reduces those writes.

## Data

Media and the generated secret key are stored in `/data` and included in backups.
The database lives in the PostgreSQL app and must be backed up with it.

## Not included

The stock compose file mounts the Docker socket into the worker so authentik can
manage outposts. This app does not, so outposts must be run separately.
