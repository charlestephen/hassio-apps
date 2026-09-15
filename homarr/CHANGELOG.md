# Changelog

All notable changes to the Homarr app are documented here.
The version tracks the upstream Homarr release it is built from
(with a `-N` suffix for app-only revisions between upstream releases).

## 1.70.0-2

- **Revert a bad prior edit**: an earlier commit (labeled "FIXED") had
  quietly switched the registry from the private Forgejo registry to a
  public GHCR path, downgraded the required Home Assistant version, and
  flipped `init` to `true` (which fights Homarr's own entrypoint). All
  three are reverted back to the working configuration.
- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-homarr-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

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
- Homarr's own entrypoint (redis + nginx + Next.js) is preserved; the app
  only injects configuration as environment variables.
- SQLite database is persisted to the app `/data` volume
  (`DB_URL=/data/db/db.sqlite`) so it survives updates and restarts.
- `SECRET_ENCRYPTION_KEY` is auto-generated once and persisted to `/data`
  when left blank, so encrypted secrets remain readable across restarts.
- Full environment-variable surface exposed as app options, including:
  - Authentication: `AUTH_PROVIDERS`, session expiry, cookie prefix, logout URL.
  - **OIDC/SSO**: issuer, client id/secret/name, scope overwrite, groups
    attribute, auto-login, local group management, force-userinfo, account
    linking, token endpoint auth method, name attribute overwrite.
  - **LDAP**: URI, base, bind DN/password, attribute and group mappings,
    search scope, extra filter args.
  - Optional external database and external Redis.
  - Docker integration (remote hosts) and outbound proxy settings.
