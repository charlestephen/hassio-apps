# Changelog

## 2.19.3

- Upgrading from upstream version 2.19.2-4 -> 2.19.3

> Upstream v2.19.3: https://github.com/pocket-id/pocket-id/releases/tag/v2.19.3
>
> > [!NOTE]  
> > This is only a patch release. Get ready for Pocket ID v3 with a completely redesigned UI. You can share your feedback about the new UI in [this discussion](https://github.com/pocket-id/pocket-id/discussions/1888).
> > 
> > If you are using automated updates make sure that you don't use the `latest` image tag, pin it to a major version instead e.g `v2`. This prevents you from potentially updating to a version that has breaking changes.
>
>
> ### Bug Fixes
>
> - require a JSON body to approve a device authorization ([d6a0563](https://github.com/pocket-id/pocket-id/commit/d6a056355a3238b0d0c624d4788e8118dafed7f6) by @stonith404)
>
> ### Other
>
> - update vulnerable dependencies ([3a82995](https://github.com/pocket-id/pocket-id/commit/3a829955067567e6dbb30befa56f3070c977a0f7) by @stonith404)
>
> **Full Changelog**: https://github.com/pocket-id/pocket-id/compare/v2.19.2...v2.19.3

## 2.19.2-4

- Require **App URL**: the wrapper exits with a clear error if it is empty
  (or not `http(s)://…`). Empty previously left issuer as
  `http://localhost:1411`, which made OIDC / passkey login look frozen when
  the UI was opened on any other host.

## 2.19.2-3

- Fix OIDC PAR `invalid_request` / `MatchRedirectURIWithClientRedirectURIs`
  guidance: document exact Callback URL registration, Homarr **Base URL**, and
  strip a trailing slash from **App URL**.
- Add **Internal App URL** (`INTERNAL_APP_URL`) for split-DNS token/PAR
  discovery.
- When **PUID**/**PGID** are `0`, exec `/app/pocket-id` directly to avoid
  upstream `addgroup: gid '0' in use`.
- Export `SMTP_*` only when SMTP fields are actually set (ignore default
  `smtp_tls: none` alone).

## 2.19.2-2

- Document Homarr and pgAdmin as OIDC clients (Homarr needs
  `client_secret_post`).

## 2.19.2-1

- Add SMTP options (`smtp_host` / `port` / `from` / `user` / `password` /
  `tls` / `skip_cert_verify`) and **Disable UI configuration**. Pocket ID only
  applies `SMTP_*` from the environment when `UI_CONFIG_DISABLED` is set; the
  wrapper turns that on automatically if any SMTP field is filled.

## 2.19.2

- First Home Assistant app release wrapping [Pocket ID](https://github.com/pocket-id/pocket-id)
  `v2.19.2`. Thin wrapper: options → env, `/data` persistence, `exec` upstream
  entrypoint. Upstream tracked via `upstream_repo` + Docker Hub image gate.

> Upstream v2.19.2: https://github.com/pocket-id/pocket-id/releases/tag/v2.19.2
