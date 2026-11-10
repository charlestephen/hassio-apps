# PgBouncer

A connection pooler for PostgreSQL, built from the upstream
[PgBouncer](https://www.pgbouncer.org) source (`1.26.1`). Clients connect to
PgBouncer instead of PostgreSQL, and PgBouncer shares a small number of server
connections between them. This helps when many apps open many connections.

## Quick start

1. Install and start the **PostgreSQL** app from this repository.
2. Install **PgBouncer** and set **PostgreSQL admin password** to the PostgreSQL
   app's superuser password.
3. Start it. Connect your clients to the PgBouncer app on port `6432` with the
   same user name and password they use for PostgreSQL.

You do not list users or databases. PgBouncer finds the PostgreSQL app on its
own and checks every login against the server's password hashes, so the logins
you create in the PostgreSQL app work through PgBouncer straight away, and so do
their rights.

## How it connects

The PostgreSQL app is found from this app's own hostname, so it works with the
repository prefix Home Assistant gave your install. The admin password is used
once per start to create a role named `pgbouncer_auth` and a function
`public.pgbouncer_get_auth` in the `postgres` database. The role can only run
that function, which returns the stored password hash of one user. Its own
password is generated and kept in `/data/.auth_password`.

## Options

| Option | Meaning |
|--------|---------|
| PostgreSQL host / port | Leave the host empty to find the PostgreSQL app. |
| PostgreSQL admin user / password | Needed to create the authentication role. The password is required. |
| Databases | Empty exposes every database. List names to expose only those, each with an optional pool mode. |
| Pool mode | `transaction` (default), `session` or `statement`. |
| Maximum client connections | Clients allowed at once. |
| Default pool size | Server connections per database and login pair. |
| Admin console password | Enables the `pgbouncer` admin database for the user `pgbouncer`. |
| Log connections | Log each connect and disconnect. Off by default. |
| Extra settings | Further PgBouncer settings, written as `name = value`. |

## Pool modes

In `transaction` mode a server connection is handed back after every
transaction, which pools best but means session state such as `LISTEN`,
advisory locks and server-side cursors does not carry over between
transactions. Use `session` mode, or connect straight to PostgreSQL, for clients
that need those. PgBouncer 1.21 and later supports prepared statements in
transaction mode.

## Using it with other apps

- **pgAdmin**: turn on **Register PgBouncer** in the pgAdmin app to add a second
  server entry that uses the same login.
- **Authentik**: turn on **Use PgBouncer** in the Authentik app. It points
  Authentik at PgBouncer, turns off server-side cursors, and keeps a direct
  connection to PostgreSQL for the parts that cannot go through a
  transaction-mode pooler.

## Admin console

Set **Admin console password**, then connect to the database `pgbouncer` as the
user `pgbouncer`:

```
psql -h <home-assistant-ip> -p 6432 -U pgbouncer pgbouncer -c "SHOW POOLS"
```

## Ports

| Port | Use |
|------|-----|
| `6432/tcp` | PgBouncer (PostgreSQL protocol) |
