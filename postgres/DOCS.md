# Home Assistant App: PostgreSQL

## Overview

PostgreSQL 18 object-relational database server, suitable as the recorder
backend for Home Assistant or as a database for other apps and services on
your network.

The cluster is created on first start in `/data/postgres` (persisted by the
app) and the server listens on port **5432**.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `superuser_password` | password | `changeme` | Password for the `postgres` superuser. **Change this before exposing the server.** |
| `database` | string | `homeassistant` | A database created on first init (leave empty to skip). |
| `databases` | list | empty | Databases created on every start if missing. |
| `logins` | list | empty | Logins (`username`, `password`) created or updated on every start. |
| `rights` | list | empty | Pairs of `username` and `database`; the login gets full access to that database. |
| `ssl` | list | `auto` | `auto`, `on` or `off`. See [TLS](#tls). |
| `certfile` / `keyfile` | string | `fullchain.pem` / `privkey.pem` | Certificate and key, relative to Home Assistant's `/ssl` folder. |
| `data_directory` | string | empty | Keep the data on an external drive. See [External drive](#external-drive). |
| `migrate_existing_data` | bool | `false` | Copy an existing database to the new Data directory on start. |
| `max_connections` | int | `100` | Maximum concurrent connections. |
| `log_level` | list | `info` | App log verbosity. |

### Databases, logins and rights

Like the MariaDB app, you describe the databases, the logins and which login may
use which database. Everything is applied on every start and is safe to repeat.

```yaml
databases:
  - homeassistant
  - authentik
logins:
  - username: homeassistant
    password: "first-password"
  - username: authentik
    password: "second-password"
rights:
  - username: homeassistant
    database: homeassistant
  - username: authentik
    database: authentik
```

- A login can connect only to the databases it has a right for, for databases
  in the `databases` list. The superuser can reach all of them. Give a login rights
  on several databases with several `rights` entries.
- A right gives the login all privileges on the database and on its `public`
  schema. Tables created by one login are not visible to another login with
  rights on the same database unless you grant them yourself.
- A right is skipped with a warning if the login or the database does not exist.
- Removing an entry does not delete the database or the login.
- The single `database` option from earlier versions still works and applies
  only when a new cluster is created.

> ⚠️ The `superuser_password` is only applied when the cluster is **first
> initialized**. To change it later, connect and run
> `ALTER USER postgres PASSWORD '...';`.

### Example

```yaml
superuser_password: "a-strong-password"
database: homeassistant
max_connections: 100
log_level: info
```

## TLS

By default (`ssl: auto`) the server uses TLS when `fullchain.pem` and
`privkey.pem` exist in Home Assistant's `/ssl` folder, and runs without it when
they do not, so an update never stops the app for lack of a certificate. Use
`on` to make a missing certificate an error, or `off` to never use TLS. For
certificates issued by the Acme.sh app, set `certfile` and `keyfile` to the paths
inside `/ssl`, such as `acme.sh/example.com/fullchain.pem`.

- Clients that use `sslmode=prefer`, the default for `psql` and most drivers,
  start using TLS on their own. Use `sslmode=require` or stricter to insist on it.
- The server still accepts plain connections. To refuse them, change the `host`
  lines in `pg_hba.conf` to `hostssl`.
- The key is copied to memory at start with the ownership PostgreSQL demands and
  is not written to disk. The certificate is read at start, so restart the app
  after it is renewed.
- The PgBouncer app uses TLS to PostgreSQL automatically once it is on.

## External drive

By default the cluster lives in the app's own storage, which is the system disk
(an SD card on a Raspberry Pi). Databases write constantly, so you can keep the
data on an external drive instead.

> **Tested only on Home Assistant Supervised.** The steps below use the
> Supervisor's media folder. Other installation types may mount external
> storage differently and have not been tried.

1. Format the drive with **ext4**, **xfs** or **btrfs**. FAT, exFAT and NTFS
   cannot hold a PostgreSQL cluster because they lack Unix ownership and
   permissions.
2. Mount it on the host under the Supervisor's media folder. Find the
   Supervisor's data folder with
   `docker inspect hassio_supervisor --format '{{range .Mounts}}{{if eq .Destination "/data"}}{{.Source}}{{end}}{{end}}'`;
   the media folder is `media` inside it (often `/usr/share/hassio/media` or
   `/var/lib/homeassistant/media`). For example, mount the drive at
   `<data folder>/media/pgdata`. Add it to `/etc/fstab`
   so it comes back after a reboot.
3. Set **Data directory** to the same path as the app sees it, for example
   `/media/pgdata`, and restart the app. The database is kept in a `postgres`
   subfolder of that folder.

If you already have a database, turn on **Migrate existing data** before the
first start with the new location. The app copies the cluster across, checks the
copy, and leaves the original in place; delete it yourself after checking. An
interrupted copy is discarded and redone on the next start. Without the toggle,
the app refuses to start when it finds an existing database rather than
starting an empty one beside it. The toggle can stay on, because it does
nothing once the new location holds a cluster. If there is no existing
database, a new one is created in the new location.

The app refuses to start when the folder is on the same filesystem as the app's
own storage, which is what an unmounted drive looks like. This stops it from
quietly creating a new database on the system disk.

Data outside the app's own storage is **not included in Home Assistant
backups**. Back it up separately, for example with `pg_dump`.

The app is also given read-write access to the Supervisor media folder, which
is needed to reach the drive.

## Connecting

From another app or container on the Home Assistant network, or from your LAN:

```
host:     <home-assistant-ip>
port:     5432
user:     postgres
password: <superuser_password>
database: <database>
```

Example connection string:

```
postgresql://postgres:<password>@<home-assistant-ip>:5432/homeassistant
```

To use it as the Home Assistant recorder, add to `configuration.yaml`:

```yaml
recorder:
  db_url: postgresql://postgres:<password>@<home-assistant-ip>:5432/homeassistant
```

## Authentication

The server is initialized with `scram-sha-256` password authentication and
accepts network connections (`host all all 0.0.0.0/0 scram-sha-256`). Keep the
app on a trusted network and use a strong password.

## Data & backups

- All cluster data lives in `/data/postgres` and is included in Home Assistant
  snapshots/backups.
- For logical backups use `pg_dump` from a client, e.g.
  `pg_dump postgresql://postgres:<password>@<host>:5432/<db> > backup.sql`.

## Upgrading major versions

PostgreSQL major upgrades (e.g. 18 → 19) require `pg_upgrade` or a
dump/restore — the data directory is **not** automatically migrated. This
app tracks the 18.x series; a new major would be a deliberate, separate step.
