# Ultimate CA Manager

Thin Home Assistant wrapper around
[Ultimate CA Manager](https://github.com/NeySlim/ultimate-ca-manager)
(`2.252`). UCM is a web Certificate Authority with ACME, SCEP, EST, OCSP,
CRL/CDP, TSA, SSH CA, and more.

## Quick start

1. Install **Ultimate CA Manager**.
2. Set **FQDN** to the hostname clients will use (e.g. `ca.example.com`).
3. Optionally set **HTTPS certificate file** and **HTTPS private key file** to
   paths under `/ssl` (e.g. an Acme.sh fullchain + key) so the UI uses a real
   cert from first start instead of a self-signed one. Both must be set
   together; files are copied into UCM data on each start.
4. Behind Traefik / a reverse proxy: enable **Behind reverse proxy**, set
   **Trusted proxies** (e.g. `172.30.32.0/23`), and add
   **Extra CORS origins** for the public HTTPS origin.
5. Start the app. Open `https://<ha-host>:8443`.
6. First login: `admin` / `changeme123` — you **must** set a new password
   before anything else works.

Leave **Session secret key** and **Key encryption key** blank on first start —
both are generated and stored under `/ssl/ucm/etc/`.

## Where secrets live

Upstream keeps two durable volumes. This app places both under the Home
Assistant SSL share (writable):

| Role | Inside container | On disk |
| --- | --- | --- |
| SQLite DB, CA/cert files, SoftHSM tokens, backups | `/opt/ucm/data` | `/ssl/ucm/data/` |
| `master.key` / encryption material | `/etc/ucm` | `/ssl/ucm/etc/` |

`/data/ucm` is a **symlink** to `/ssl/ucm` so addon backups see the same tree.
Upstream’s image declares Docker VOLUMEs at `/opt/ucm/data` and `/etc/ucm`;
this app **bind-mounts** `/ssl/ucm/...` over those paths (needs `SYS_ADMIN` —
turn **Protection mode** off for this app if Supervisor prompts) and runs as
**root**. If a bind is denied, it seeds the upstream volumes from `/ssl` and
syncs back. Start diagnostics also go to `/data/ucm-addon.log`. Always take a
**full** Home Assistant backup (includes `/ssl`) before upgrades; losing
`/ssl/ucm/etc/key_encryption_key` (or `master.key` after UI encryption) makes
encrypted private keys unrecoverable.

With `KEY_ENCRYPTION_KEY` set (default here), UCM encrypts CA and certificate
private keys at rest and does not keep plaintext key files under
`data/private/`. See upstream
[SECURITY.md](https://github.com/NeySlim/ultimate-ca-manager/blob/main/docs/SECURITY.md).

## Ports

| Port | Use |
| --- | --- |
| `8443/tcp` | HTTPS web UI + management API |
| `8080/tcp` | HTTP PKI endpoints (CRL/CDP, OCSP, ACME HTTP-01) |
| `8053/tcp` + `8053/udp` | Optional ACME DNS UPDATE — disabled unless **DNS UPDATE port** is set; keep internal |

## Extra settings

SMTP, ACME client CAs, SSO, and most application settings are configured in the
UCM web UI (stored in the database), not as environment variables. Prefer
**HTTPS certificate/key file** for TLS from `/ssl`; use **Extra environment
variables** for anything else upstream documents (`HSM_PIN`, …). Mark secrets
with `secret: true`.

## Notes

- This wrapper tracks the **standard** image (`neyslim/ultimate-ca-manager`),
  not the `-fips` variant.
- Version tracks upstream via `upstream_repo: NeySlim/ultimate-ca-manager`.
- Do not publish the DNS UPDATE listener to the internet.

## Links

- Upstream: <https://github.com/NeySlim/ultimate-ca-manager>
- Docker install: <https://github.com/NeySlim/ultimate-ca-manager/blob/main/docs/installation/docker.md>
- Admin guide: <https://github.com/NeySlim/ultimate-ca-manager/blob/main/docs/ADMIN_GUIDE.md>
- Security: <https://github.com/NeySlim/ultimate-ca-manager/blob/main/docs/SECURITY.md>

## Database

By default a new install uses the **PostgreSQL** app from this repository: set
**PostgreSQL admin password** to its superuser password and UCM creates its own
database and login on start. Without that password, or if the install already
has a SQLite database, UCM keeps using SQLite.

| Database | Behaviour |
|----------|-----------|
| `auto` (default) | PostgreSQL on a new install when the admin password is set; otherwise SQLite. An install that already had a SQLite database keeps it. The choice is made once and remembered in `/data/.database_backend`. |
| `postgres` | Always PostgreSQL. The app stops with a message if the admin password is missing. |
| `sqlite` | Always SQLite. |

The PKI store in the host's `/ssl/ucm` folder survives uninstalling the app, so
reinstalling finds an earlier SQLite database there and keeps using it. To start
over on PostgreSQL, set **Database** to `postgres` (the old data is left
untouched in `/ssl/ucm`).

A **Database URL** overrides everything above. Switching an install that
already holds a CA from SQLite to PostgreSQL starts with an empty database; the
data is not migrated. The login password is generated and kept in
`/data/.postgres_password` unless you set one. Back up the PostgreSQL database
with the PostgreSQL app; it is not part of this app's backup.
