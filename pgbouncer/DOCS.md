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
| Enable TLS / Certificate file / Private key file | Turn on TLS for clients with a certificate from Home Assistant's `/ssl` folder. See [TLS](#tls). |
| TLS mode | `allow`, `prefer` or `require`. |
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

## TLS

Turn on **Enable TLS** and give the certificate and key as file names inside
Home Assistant's `/ssl` folder, for example `fullchain.pem` and `privkey.pem`, or
a path such as `acme.sh/example.com/fullchain.pem` for certificates issued by the
Acme.sh app. Clients then connect with `sslmode=require` or stricter.

- **TLS mode** `require` refuses clients that do not use TLS. `prefer` and
  `allow` accept both.
- The certificate is read when the app starts. Restart the app after it is
  renewed.
- This secures the connection between clients and PgBouncer. The connection from
  PgBouncer to PostgreSQL uses TLS whenever the PostgreSQL server offers it,
  which the PostgreSQL app in this repository does when it has a certificate in
  `/ssl`.
- Use a certificate whose name matches the address clients connect to if they
  verify it (`sslmode=verify-full`).

## How logins are checked

PgBouncer never stores your users' passwords. For each login it asks PostgreSQL
for the stored password hash, through the `public.pgbouncer_get_auth` function
that this app creates. The `pgbouncer_auth` role can run only that function: it
is not a superuser, cannot read `pg_shadow` itself, and cannot create objects.
PgBouncer verifies the client's SCRAM proof against the stored hash and then
connects to PostgreSQL as the same user without ever seeing the password.

- Logins must have a SCRAM-SHA-256 password. PostgreSQL has used it by default
  since version 14. A login whose password was set as legacy MD5 cannot sign in
  through PgBouncer; set its password again with
  `password_encryption = 'scram-sha-256'`.
- The `pgbouncer_auth` password is generated once, kept in
  `/data/.auth_password`, and written into PgBouncer's private user list so it
  can sign in to PostgreSQL.

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
