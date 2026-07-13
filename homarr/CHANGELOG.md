# Changelog

All notable changes to the Homarr add-on are documented here.
The version tracks the upstream Homarr release it is built from
(with a `-N` suffix for add-on-only revisions between upstream releases).

## 1.70.0-1

- Fix: database could not be created when running as a non-root user. The
  wrapper now runs as root before Homarr drops privileges and chowns both
  HA's `/data` and Homarr's `/appdata` volume to the configured `PUID:PGID`,
  so any user/group set in the options works. Homarr's own entrypoint only
  chowns `/app` and nginx dirs, which left the data volumes root-owned.

## 1.70.0

Initial release.

- Thin Home Assistant wrapper around the official
  `ghcr.io/homarr-labs/homarr:1.70.0` image (multi-arch: `aarch64`, `amd64`).
- Homarr's own entrypoint (redis + nginx + Next.js) is preserved; the add-on
  only injects configuration as environment variables.
- SQLite database is persisted to the add-on `/data` volume
  (`DB_URL=/data/db/db.sqlite`) so it survives updates and restarts.
- `SECRET_ENCRYPTION_KEY` is auto-generated once and persisted to `/data`
  when left blank, so encrypted secrets remain readable across restarts.
- Full environment-variable surface exposed as add-on options, including:
  - Authentication: `AUTH_PROVIDERS`, session expiry, cookie prefix, logout URL.
  - **OIDC/SSO**: issuer, client id/secret/name, scope overwrite, groups
    attribute, auto-login, local group management, force-userinfo, account
    linking, token endpoint auth method, name attribute overwrite.
  - **LDAP**: URI, base, bind DN/password, attribute and group mappings,
    search scope, extra filter args.
  - Optional external database and external Redis.
  - Docker integration (remote hosts) and outbound proxy settings.
