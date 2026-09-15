# Changelog

All notable changes to the Traefik Manager app are documented here.
The version tracks the upstream Traefik Manager release it is built from.

## 1.13.5

Initial release.

- Thin Home Assistant wrapper around the official
  `ghcr.io/chr0nzz/traefik-manager:1.13.5` image (multi-arch: `aarch64`,
  `amd64`).
- Upstream's own gunicorn process is preserved; the app only injects
  configuration as environment variables before exec'ing it.
- `manager.yml`, the dynamic config, and backups are persisted under this
  app's `/data` volume by default, so they survive updates and reinstalls.
- Full environment-variable surface exposed as app options, including:
  - Connection to the Traefik API (URL, basic auth, TLS verification).
  - Config file paths (dynamic config, static config, ACME JSON, access log,
    plugins directory).
  - Authentication (admin password, session/cookie settings, proxy hop
    trust).
  - Automatic Traefik restart after a static-config change (`proxy`,
    `poison-pill`, or `socket` method).
  - **OIDC/SSO** login with email/group allow-lists.
  - **CrowdSec** integration (LAPI URL, bouncer key, machine credentials,
    mTLS).
  - GeoIP database path, agent API rate limit, sub-path serving, log level.
