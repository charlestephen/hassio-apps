# Changelog

## 18.6-2

- The database is now kept in a `postgres` subfolder of **Data directory**, so a freshly formatted drive (which contains `lost+found`) works. Fixes the copy refusing an ext4 drive as not empty.

## 18.6-1

- New **Data directory** option to keep the database on an external drive under `/media`, for installs on SD cards. Tested only on Home Assistant Supervised. Refuses to start when the folder is on the same filesystem as the app storage, and copies an existing cluster across when **Migrate existing data** is on (verified copy, original kept, interrupted copies restart).
- The app now maps the Supervisor media folder read-write.

## 18.6

- Upgrading from upstream version 18.4.f -> 18.6

## 18.4.f

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-postgres-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 18.4.e

- Base image is `ghcr.io/hassio-addons/base:stable` (Alpine 3.24). The Alpine 3.24 tree
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
