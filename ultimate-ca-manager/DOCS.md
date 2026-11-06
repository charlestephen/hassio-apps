# Ultimate CA Manager

Thin Home Assistant wrapper around
[Ultimate CA Manager](https://github.com/NeySlim/ultimate-ca-manager)
(`2.249`). UCM is a web Certificate Authority with ACME, SCEP, EST, OCSP,
CRL/CDP, TSA, SSH CA, and more.

## Quick start

1. Install **Ultimate CA Manager**.
2. Set **FQDN** to the hostname clients will use (e.g. `ca.example.com`).
3. Behind Traefik / a reverse proxy: enable **Behind reverse proxy**, set
   **Trusted proxies** (e.g. `172.30.32.0/23`), and add
   **Extra CORS origins** for the public HTTPS origin.
4. Start the app. Open `https://<ha-host>:8443`.
5. First login: `admin` / `changeme123` — you **must** set a new password
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
Always take a **full** Home Assistant backup (includes `/ssl`) before upgrades;
losing `/ssl/ucm/etc/key_encryption_key` (or `master.key` after UI encryption)
makes encrypted private keys unrecoverable.

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
UCM web UI (stored in the database), not as environment variables. Use
**Extra environment variables** for anything else upstream documents
(`UCM_HTTPS_CERT` / `UCM_HTTPS_KEY` PEM blobs, `HSM_PIN`, …). Mark secrets with
`secret: true`.

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
