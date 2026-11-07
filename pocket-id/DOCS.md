# Pocket ID

Thin Home Assistant wrapper around the official
[Pocket ID](https://pocket-id.org) image (`2.19.2`). Pocket ID is an OpenID
Connect Certified™ and OAuth 2.0 provider that signs users in with passkeys
only.

## Quick start

1. Install **Pocket ID**.
2. **App URL is required** before start. Set it to the public HTTPS URL users
   (and passkeys) will use, e.g. `https://id.example.com` — no path and **no
   trailing slash**. Passkeys are bound to that domain. The wrapper strips a
   trailing `/` if present; if App URL is empty the add-on exits immediately
   with an error (empty used to default issuer to `http://localhost:1411` and
   look “frozen” when opened by hostname/IP).
3. Behind Traefik / a reverse proxy, set **Trust proxy** to `true` (or your
   proxy CIDRs), or set **Trusted platform header** (e.g. `CF-Connecting-IP`).
4. Start the app. Open the Web UI on port `1411` and create the first admin.

Leave **Encryption key** blank on first start — a key is generated and stored
at `/data/.encryption_key`. Back it up; losing it makes encrypted material
unreadable.

### Internal App URL

Relying parties (Homarr, pgAdmin, …) fetch discovery / token / PAR endpoints
server-side. If those containers cannot reach **App URL** (split DNS, no
hairpin NAT, private CA), set **Internal App URL** to an address they *can*
reach (for example `http://pocket-id:1411` on a shared Docker network). Browsers
keep using **App URL**; the discovery document then advertises the internal
base for token, userinfo, JWKS, introspection, and
[`/api/oidc/par`](https://pocket-id.org/docs/setup/connect-an-app).

## Data

Everything under Pocket ID’s `/app/data` is persisted on the Supervisor `/data`
volume (SQLite DB, uploads, GeoLite DB, encryption key file).

To use PostgreSQL instead of SQLite, set **Database connection string** to a
`postgres://…` URL.

## SMTP

Set **SMTP host**, **port**, **from**, and optionally user/password/TLS in the
app options. Upstream only loads those from the environment when
`UI_CONFIG_DISABLED` is true — filling any SMTP field (or enabling **Disable UI
configuration**) turns that on. Remaining app settings then use env defaults or
**Extra environment variables** (`EMAIL_*`, `LDAP_*`, …).

| Option | Env |
| --- | --- |
| `smtp_host` | `SMTP_HOST` |
| `smtp_port` | `SMTP_PORT` |
| `smtp_from` | `SMTP_FROM` |
| `smtp_user` | `SMTP_USER` |
| `smtp_password` | `SMTP_PASSWORD` |
| `smtp_tls` | `SMTP_TLS` (`none` / `starttls` / `tls`) |
| `smtp_skip_cert_verify` | `SMTP_SKIP_CERT_VERIFY` |

SMTP env vars are exported only when at least one of host / port / from / user /
password is set (the form default `smtp_tls: none` alone does not count).

## Extra settings

LDAP, UI overrides, OpenTelemetry, and other knobs go under **Extra environment
variables** using names from the
[Pocket ID env reference](https://pocket-id.org/docs/configuration/environment-variables).
Mark tokens/passwords with `secret: true`.

## Registering OIDC clients (redirect / callback URLs)

Pocket ID only accepts a `redirect_uri` that **exactly** matches a Callback URL
on the OIDC client (scheme, host, port, path — no silent first-URL capture). A
mismatch on pushed authorization (`POST /api/oidc/par`) returns `400` /
`invalid_request` with `MatchRedirectURIWithClientRedirectURIs` and the login
appears stuck.

1. Read the callback URL the app will send (Homarr / pgAdmin docs below).
2. In Pocket ID → **Administration → OIDC Clients → Add**, paste that URL under
   **Callback URLs** before testing sign-in.
3. Give the relying party a public HTTPS **base / origin** so it does not send
   `http://…` or an internal hostname as `redirect_uri`.
4. Optional: [callback wildcards](https://pocket-id.org/docs/advanced/callback-url-wildcards)
   such as `https://*.example.com/api/auth/callback/oidc` when the host varies.

See also upstream
[common issues](https://pocket-id.org/docs/troubleshooting/common-issues)
(“The redirect_uri is not registered for this client”).

## Clients in this repo

### Homarr

Callback (register **exactly** this on the Pocket ID client):

`https://<homarr-fqdn>/api/auth/callback/oidc`

Enable **PKCE**. In Homarr set **Base URL** to Homarr’s public `https://`
origin (required — otherwise Homarr may PAR with an `http://` or container
URL that is not registered), **Token endpoint auth method** to
`client_secret_post` (Pocket ID does not support `client_secret_basic`),
issuer to this app’s App URL (no trailing slash), scopes
`openid email profile groups`. See Homarr’s DOCS for the full option table.

### pgAdmin

Callback: `https://<pgadmin-fqdn>/oauth2/authorize`. Use discovery metadata
`https://<pocket-id-fqdn>/.well-known/openid-configuration` in pgAdmin’s OAuth2
options (or `config_local.py`). See pgAdmin’s DOCS.

## Notes

- Do **not** put Pocket ID behind Home Assistant Ingress for production —
  passkeys and OIDC redirects need the real App URL hostname.
- Default **PUID** / **PGID** `0` runs as root and skips upstream’s `addgroup`
  (which errors with `gid '0' in use`). Non-zero values still use upstream
  `/app/docker/entrypoint.sh` for user setup + `chown`.
- Pin updates via this repo’s upstream tracker (`pocket-id/pocket-id`); the app
  version matches the upstream release.

## Links

- Upstream: <https://github.com/pocket-id/pocket-id>
- Docs: <https://pocket-id.org/docs>
- Demo: <https://demo.pocket-id.org>
