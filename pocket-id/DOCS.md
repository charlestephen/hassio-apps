# Pocket ID

Thin Home Assistant wrapper around the official
[Pocket ID](https://pocket-id.org) image (`2.19.2`). Pocket ID is an OpenID
Connect Certified™ and OAuth 2.0 provider that signs users in with passkeys
only.

## Quick start

1. Install **Pocket ID**.
2. Set **App URL** to the public HTTPS URL users (and passkeys) will use, e.g.
   `https://id.example.com` — no path. Passkeys are bound to that domain.
3. Behind Traefik / a reverse proxy, set **Trust proxy** to `true` (or your
   proxy CIDRs), or set **Trusted platform header** (e.g. `CF-Connecting-IP`).
4. Start the app. Open the Web UI on port `1411` and create the first admin.

Leave **Encryption key** blank on first start — a key is generated and stored
at `/data/.encryption_key`. Back it up; losing it makes encrypted material
unreadable.

## Data

Everything under Pocket ID’s `/app/data` is persisted on the Supervisor `/data`
volume (SQLite DB, uploads, GeoLite DB, encryption key file).

To use PostgreSQL instead of SQLite, set **Database connection string** to a
`postgres://…` URL.

## Extra settings

SMTP, LDAP, UI-config overrides, OpenTelemetry, and other knobs are not
duplicated in the form. Add them under **Extra environment variables** using
the names from the
[Pocket ID env reference](https://pocket-id.org/docs/configuration/environment-variables).
Mark tokens/passwords with `secret: true`.

## Notes

- Do **not** put Pocket ID behind Home Assistant Ingress for production —
  passkeys and OIDC redirects need the real App URL hostname.
- Pin updates via this repo’s upstream tracker (`pocket-id/pocket-id`); the app
  version matches the upstream release.

## Links

- Upstream: <https://github.com/pocket-id/pocket-id>
- Docs: <https://pocket-id.org/docs>
- Demo: <https://demo.pocket-id.org>
