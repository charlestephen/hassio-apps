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
| `max_connections` | int | `100` | Maximum concurrent connections. |
| `log_level` | list | `info` | App log verbosity. |

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
