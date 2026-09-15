# Changelog

## 2.18.12.e

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-semaphore-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 2.18.12.d

- **Terraform 1.15.7 and OpenTofu 1.12.3 included**, so Semaphore's
  Terraform / OpenTofu task templates now work out of the box (Semaphore runs
  `init` automatically before each run). `terraform` is copied from the
  official `hashicorp/terraform` multi-arch image; `tofu` is fetched from the
  GitHub release zip because OpenTofu's official image deliberately fails
  downstream builds (opentofu/opentofu#1931).
- Both versions are pinned in `build.yaml` and tracked by Renovate.

## 2.18.12.c

- **Log level** exposed in the config UI: `log_level` → `SEMAPHORE_LOG_LEVEL`,
  a dropdown (`trace`/`debug`/`info`/`warn`/`error`/`fatal`/`panic`), defaulting
  to `debug` to help troubleshoot login.
- **OIDC / SSO login** exposed in the config UI. The app assembles the
  `oidc_providers` map from these options and passes it to Semaphore as JSON via
  `SEMAPHORE_OIDC_PROVIDERS` (auto-discovery via the issuer URL):
  `oidc_enable`, `oidc_provider_id`, `oidc_display_name`, `oidc_icon`,
  `oidc_color`, `oidc_order`, `oidc_provider_url`, `oidc_client_id`,
  `oidc_client_secret`, `oidc_redirect_url`, `oidc_username_claim`,
  `oidc_email_claim`, `oidc_name_claim`, `oidc_scopes`.
- **Secrets masked** (`password`-typed in the UI): `oidc_client_secret` and the
  Slack / Rocket.Chat / Microsoft Teams webhook URLs. The run script also stops
  echoing any `*_URL` secret into the (now verbose) logs.
- Added `translations/en.yaml` with labels/descriptions for all new options.

## 2.18.12.b

- **Fix startup crash** `panic: unknown store type` (`NewTerraformStore`). Bolt
  is deprecated in Semaphore 2.18 and the pro edition's Terraform state store
  rejects it, so the server crashed on every launch. Switch the database to
  **SQLite** (`SEMAPHORE_DB_DIALECT=sqlite`, path via `SEMAPHORE_DB_HOST`), the
  recommended embedded replacement — still a single file under `/data/semaphore`,
  no external service. Fresh installs only; there was no working Bolt data to
  migrate (every prior start panicked before serving).

## 2.18.12.a

- Icon: stop-aspect railway semaphore signal.

## 2.18.12

- **Initial release** of the Semaphore UI app.
- Ships **Semaphore UI v2.18.12** (released 2026-06-08) via a multi-stage
  build: binary copied from `semaphoreui/semaphore:v2.18.12`; final image
  built on `ghcr.io/hassio-addons/base:21.0.0` (Alpine 3.24, s6-overlay v3,
  bashio).

- **Bundled automation toolchain** installed from Alpine 3.24 packages:
  - `ansible 14.0.0` / `ansible-core 2.21.0` — run playbooks out of the box
  - `git 2.54` — repository checkout for Semaphore projects
  - `openssh-client 10.3` — SSH connections to managed hosts
  - `sshpass` — password-based SSH authentication in Ansible inventory
  - `rsync` — required by the Ansible `synchronize` module
  - `python3 3.14`, `py3-requests`, `py3-jinja2` — common Ansible runtime deps

- **Full environment variable coverage** in the HA Configuration UI (70+
  options across 9 categories):
  - *Security keys* (`cookie_hash`, `cookie_encryption`,
    `access_key_encryption`) — must be changed before first use
  - *Admin account* (`admin_username`, `admin_password`, `admin_name`,
    `admin_email`) — seeds the database on first boot only
  - *Server* (`web_root`, `schedule_timezone`, `max_parallel_tasks`,
    `max_task_duration_sec`, `max_tasks_per_template`, `git_client`,
    `password_login_disabled`, `non_admin_can_create_project`)
  - *Two-factor auth / TOTP* (`totp_enabled`, `totp_allow_recovery`,
    `totp_issuer`)
  - *SMTP email alerts* (`email_alert`, `email_sender`, `email_host`,
    `email_port`, `email_username`, `email_password`, `email_secure`,
    `email_tls`)
  - *LDAP authentication* (`ldap_enable`, `ldap_server`, `ldap_bind_dn`,
    `ldap_bind_password`, `ldap_search_dn`, `ldap_search_filter`,
    `ldap_needtls`, plus four attribute-mapping fields)
  - *Messenger alerts* — Telegram, Slack, Rocket.Chat, Microsoft Teams
  - *Ansible* (`ansible_host_key_checking`)

- **Embedded database**: uses BoltDB (`bolt` dialect) — a single-file
  key/value store with no external MySQL or PostgreSQL service required.
  State persists in `/data/semaphore/semaphore.boltdb`.

- **Shared directories** `/share/semaphore/playbooks` and
  `/share/semaphore/inventory` created on first boot as a convenient landing
  zone for user-managed files accessible from the HA `/share` mount.

- **Startup warnings** logged when `cookie_hash` / `cookie_encryption` /
  `access_key_encryption` still hold the `CHANGE_ME_*` placeholder defaults,
  or when `admin_password` is still `changeme`.

- **s6-overlay v3 service pipeline** (`init: false`):
  - `init-semaphore` (oneshot) — creates data directories, validates config.
  - `semaphore` (longrun) — exports all `SEMAPHORE_*` env vars from app
    options, then `exec`s the Semaphore binary supervised by s6.

- **Renovate tracking** — `renovate.json5` updated with a custom regex rule
  for `semaphoreui/semaphore` Docker tags so Renovate PRs are opened
  automatically when a new Semaphore release is published.

- **Forgejo CI workflow** (`.forgejo/workflows/build_semaphore.yml`) builds
  and pushes `hassio-addons-semaphore-{aarch64,amd64}` on every push to
  `semaphore/**`; reads `SEMAPHORE_VERSION` from `build.yaml` so Renovate
  bumps propagate to CI without manual edits.
