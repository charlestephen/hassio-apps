# Changelog

## 15.0.3.a

- **Expand config UI** — expose 20 new Forgejo options in the HA Configuration
  tab, grouped by category:
  - *Server*: `APP_NAME`, `DOMAIN`, `ROOT_URL`, `HTTP_PORT`
  - *Repository defaults*: `DEFAULT_BRANCH`, `DEFAULT_PRIVATE`,
    `ENABLE_PUSH_CREATE_USER`, `ENABLE_PUSH_CREATE_ORG`
  - *Access control*: `REQUIRE_SIGNIN_VIEW`, `SHOW_REGISTRATION_BUTTON`,
    `DEFAULT_USER_VISIBILITY`
  - *Mailer / SMTP*: `MAILER_ENABLED`, `MAILER_FROM`, `MAILER_SMTP_ADDR`,
    `MAILER_SMTP_PORT`, `MAILER_USER`, `MAILER_PASSWD`, `MAILER_PROTOCOL`
  - *Logging*: `LOG_LEVEL`
  - *Database*: `DB_TYPE`

  All new options carry backward-compatible defaults and are fully optional —
  existing installs continue to boot without any config changes.

- **Fix app.ini template substitution** — the entrypoint now runs `envsubst`
  to render `/etc/templates/app.ini` into `/config/app.ini` on every startup.
  Previously, variables such as `DOMAIN`, `ROOT_URL`, and `REQUIRE_SIGNIN_VIEW`
  appeared in the template but were never substituted (they were undefined at
  render time). Added `gettext` to the `apk add` step to provide `envsubst`.

- **Add `[mailer]` section to `app.ini` template** — SMTP email notifications
  (registration confirmation, password reset, PR/issue activity) now work when
  `MAILER_ENABLED` is set to `true`.

- **Harden entrypoint** (`/usr/bin/entrypoint`):
  - `set -e` so any error aborts startup immediately.
  - `jq -r` for clean, unquoted values from `options.json`.
  - `:=` safe defaults for every variable so older configs (without new keys)
    still boot correctly without manual migration.
  - Pre-create all required subdirectories under `/share/forgejo` and
    `/config` before the `chown` sweep, preventing permission errors on first
    boot with an empty volume.

- **Set `homeassistant: "2026.6.0"`** minimum HA version in `config.yaml`.

- **Update DOCS.md** with a full configuration reference table for every
  exposed option.

- No Forgejo binary change — image version remains 15.0.3.

## 15.0.3

- Update Forgejo from `15.0.2` to `15.0.3`. This upstream point release fixes
  several regressions introduced in 15.0.x: a deadlock when mirroring large
  repositories, an incorrect HTTP 500 on certain pull-request comment edits, and
  a missing index that caused slow pagination on the explore/repos endpoint. No
  add-on configuration changes. Existing data in `/data` and `/share/forgejo` is
  fully compatible — no migration needed.

## 15.0.2.b

- Grant the AppArmor profile read access to `/init`, the entrypoint and the
  s6 scripts (`ix` → `rix`) so the init system can run under AppArmor enforcement.

## 15.0.2.a

- Refresh the AppArmor profile (`apparmor.txt`) so Forgejo runs confined under
  Home Assistant — covers s6/bashio, `/data` (SQLite), `/config`,
  `/share/forgejo`, SSH and web networking (added `network unix stream`). Set
  `apparmor: false` in the add-on config to fall back to the default profile if
  needed.

## 15.0.2

- Update Forgejo from 14 to 15.0.2.
- Fix repository storage: the entrypoint now creates and chowns `/share/forgejo`
  (previously `/share/gitea`), which caused Forgejo to crash on first start with
  `mkdir /share/forgejo: permission denied`.
- Publish the image to the private Forgejo registry
  (`ghcr.io/charlestephen/hassio-addons-forgejo-{arch}`).

## 14.0.4

- Add icon.png and logo.png for Home Assistant UI
- Fix init: set to true for proper s6-overlay startup
- Fix /init permission denied error by ensuring execute permission after COPY
- Fix Dockerfile: add missing s6 permission block after COPY rootfs
- Fix config.yaml: correct TZ indentation under options mapping
- Fix AppArmor profile name from gitea to forgejo

## 14.0.3

- Update Forgejo from v11 to v14
- Initial release under new repository structure
