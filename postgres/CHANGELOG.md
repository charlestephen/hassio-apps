# Changelog

## 18.4.f

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-postgres-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 18.4.e

- Upgrade base image from `ghcr.io/hassio-addons/base:20.0.1` to
  `ghcr.io/hassio-addons/base:21.0.0` (Alpine 3.24). The Alpine 3.24 tree
  continues to package `postgresql18` from the same upstream 18.4 point release;
  only the base OS layer (musl, OpenSSL, s6-overlay) is refreshed. Existing data
  clusters in `/data/postgres` are fully compatible — no `pg_upgrade` required.

## 18.4.d

- Bump `homeassistant:` minimum version from `2024.1.0` to `2026.6.0`.

## 18.4.c

- Promote app from `experimental` to `stable`.
- Add `homeassistant: "2024.1.0"` minimum version to satisfy Supervisor
  quality scoring requirements.

## 18.4.b

- Grant the AppArmor profile access to `/etc/s6-overlay` so `s6-rc-compile` can
  read the service database at boot (fixes the `s6-rc-compile … Permission
  denied` error under enforcement).

## 18.4.a

- Run s6-overlay as PID 1 (`init: false`) so the process supervisor owns the
  tree and reaps children correctly.
- Grant the AppArmor profile read access to `/init` and the s6/bashio scripts
  (`ix` → `rix`), fixing "can't open /init: permission denied" under enforcement.

## 18.4

- Initial release.
- PostgreSQL 18.4 on the Home Assistant Alpine base.
- Initializes the cluster in `/data/postgres` on first start and creates the
  configured default database.
- `scram-sha-256` authentication; listens on port 5432 for network clients.
- Ships an AppArmor profile (`apparmor.txt`).
