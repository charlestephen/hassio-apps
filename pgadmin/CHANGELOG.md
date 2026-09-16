# Changelog

## 9.17

- Upgrade pgAdmin 9.15.0 -> 9.17.

## 9.15.0.g

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-pgadmin-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 9.15.0.f

- Upgrade base image from `ghcr.io/hassio-addons/base:20.0.1` to
  `ghcr.io/hassio-addons/base:21.0.0` (Alpine 3.24). The pgAdmin runtime ships
  its own Python 3.14 virtualenv and is not directly affected by the Alpine
  upgrade; this refreshes the system-level musl, OpenSSL, and s6-overlay layers
  only.

## 9.15.0.e

- Bump `homeassistant:` minimum version from `2024.1.0` to `2026.6.0`.

## 9.15.0.d

- Promote app from `experimental` to `stable`.
- Add `homeassistant: "2024.1.0"` minimum version to satisfy Supervisor
  quality scoring requirements.

## 9.15.0.c

- Auto-register the PostgreSQL app as a managed server. The host is derived
  from this app's own hostname (`<repo>-pgadmin` → `<repo>-postgres`) so it
  works without knowing the repository prefix; a `.pgpass` enables passwordless
  connect. Configure via the `postgres_*` options or disable with
  `register_postgres: false`.

## 9.15.0.b

- Allow wholesale replacement of pgAdmin's `config_local.py` via a
  `/config/config_local.py` file or the new `config` option — enables OIDC /
  OAuth2, LDAP and other authentication sources (see DOCS for an OIDC template).
- Grant the AppArmor profile access to `/etc/s6-overlay` (fixes the
  `s6-rc-compile … Permission denied` boot error under enforcement) and `/config`.

## 9.15.0.a

- Run s6-overlay as PID 1 (`init: false`) so the process supervisor owns the
  tree and reaps children correctly.
- Grant the AppArmor profile read access to `/init` and the s6/bashio scripts
  (`ix` → `rix`), fixing "can't open /init: permission denied" under enforcement.

## 9.15.0

- Initial release.
- pgAdmin 4 (9.15.0) served via gunicorn on port 5050.
- Bundles pgAdmin's own Python 3.14 runtime and virtualenv from the official
  image on the Home Assistant Alpine base.
- Configuration database and user storage persisted in `/data/pgadmin`.
- Initial administrator created from the `email`/`password` options on first run.
- Ships an AppArmor profile (`apparmor.txt`).
