# Dockhand

Thin Home Assistant wrapper around the official
[Dockhand](https://dockhand.pro) image (`1.0.57`). Dockhand manages Docker
containers, Compose stacks, images and volumes from a web UI. This app keeps its
data in the PostgreSQL app from this repository instead of SQLite.

## Quick start

1. Turn **Protection mode** off for this app (app page, Info tab). Home Assistant
   only mounts the Docker socket when it is off. Without the socket, Dockhand
   cannot see any containers.
2. Install and start the **PostgreSQL** app.
3. Set **Database password**. To let the app create its database and login, also
   set **PostgreSQL admin password**.
4. Start the app and open the Web UI on port `3010`.

Dockhand starts at its first-run screen. Create the admin user there.

## Docker socket

The app manages the Docker engine that Home Assistant itself runs on, so it sees
the Supervisor and every other app container. Be careful with actions on
`hassio_*` and `addon_*` containers.

To manage a different Docker host, install the **Hawser Agent for Dockhand** app
on it and add it as an environment in Dockhand.

## Database

Dockhand creates its tables on first start. The database must exist and the
login needs rights on it; set the admin password and the app does both. There is
no migration from SQLite: switching an existing install starts with an empty
database.

## Options

| Option | Variable | Notes |
| --- | --- | --- |
| Database settings | `DATABASE_URL` | Built from the database options; the password is URL-encoded. |
| Public origin | `ORIGIN` | Needed for passkeys and behind a reverse proxy. |
| Encryption key | `ENCRYPTION_KEY` | Generated into `/data/.encryption_key` when empty. Back it up. |
| User ID / Group ID | `PUID`, `PGID` | Default `0` so the Docker socket is readable. |
| Export metrics | `EXPORT_METRICS` | Prometheus at `/metrics`. |
| Disable local login | `DISABLE_LOCAL_LOGIN` | |

## Extra environment variables

The box at the bottom of the options adds any other variable. Rows marked secret
stay masked in the UI and the log. They are applied last, so they override the
options above.

## Data

`/data` holds the encryption key, stacks, git repositories and the scanner
cache. Application data is in PostgreSQL.
