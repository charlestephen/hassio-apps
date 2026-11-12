# Changelog

## 2.20.24

- Upgrading from upstream version 2.20.23 -> 2.20.24

## 2.20.23

- Upgrading from upstream version 2.19.17-1 -> 2.20.23

> Upstream v2.20.23: https://github.com/semaphoreui/semaphore/releases/tag/v2.20.23
>
> <a href="https://semaphoreui.com/releases/semaphore-v2_20">
> <img width="1536" height="700" alt="image" src="https://github.com/user-attachments/assets/84f5d6b0-7e82-4a29-82c3-52c0114e1db8" />
> </a>
>
> ## What's Changed
> * Semaphore UI one-click deployment on Cloudzy  by @sabased in https://github.com/semaphoreui/semaphore/pull/4148
> * Persist per-user language selection in user options by @fiftin with @Copilot in https://github.com/semaphoreui/semaphore/pull/4149
> * fix/delete user error by @fiftin in https://github.com/semaphoreui/semaphore/pull/4147
> * fix(ui): prevent Enter in CLI args dialog from submitting parent form by @fiftin in https://github.com/semaphoreui/semaphore/pull/4092
> * fix: add missing env tag for SEMAPHORE_RUNNER_EXECUTOR by @jon4hz in https://github.com/semaphoreui/semaphore/pull/4154
> * Sem 212 git clone retry by @befika in https://github.com/semaphoreui/semaphore/pull/4140
> * fix(config): add backward-compatible top-level secrets_path fallback by @NewMayur in https://github.com/semaphoreui/semaphore/pull/4133
> * fix(tasks): preserve output from short shell commands by @rzaitov in https://github.com/semaphoreui/semaphore/pull/4159
> * chore(deps): update dependency core-js to v3.50.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4143
> * chore(deps): update dependency nanoid to v6.0.1 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4119
> * chore(deps): update dependency dayjs to v1.11.23 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4177
> * chore(deps): update dependency axios to v1.20.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4187
> * docs: sync engineering documentation with recent config and feature changes by @cursor[bot] in https://github.com/semaphoreui/semaphore/pull/4179
> * chore(deps): update dependency cron-parser to v5.10.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4189
> * feat(TaskDetails, TaskLogView): link to schedule or integration details and handle deleted origins by @befika in https://github.com/semaphoreui/semaphore/pull/4183
> * feat(git): parallelize submodule fetches with git --jobs flag by @dungeon-master-666 in https://github.com/semaphoreui/semaphore/pull/4172
> * docs: add RepoCloud as a deployment option by @cosark in https://github.com/semaphoreui/semaphore/pull/4170
> * feat(tasks): support and test Ansible forks concurrency by @NewMayur in https://github.com/semaphoreui/semaphore/pull/4166
> * fix/jwt for docker executor by @fiftin in https://github.com/semaphoreui/semaphore/pull/4194
> * feat(runner): add check interval configuration for job polling by @befika in https://github.com/semaphoreui/semaphore/pull/4175
> * refactor(api): function parseInt returns bool instead of error by @fiftin in https://github.com/semaphoreui/semaphore/pull/4195
> * Feat: add delay node  by @LowSwoo in https://github.com/semaphoreui/semaphore/pull/4145
> * fix(web): remove trailing spaces that break the build by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4200
> * docs: workflows guide, runner poll interval, Ansible forks by @cursor[bot] in https://github.com/semaphoreui/semaphore/pull/4199
> * add repository-relative template working directory by @rzaitov in https://github.com/semaphoreui/semaphore/pull/4181
> * fix(tasks): isolate checkouts by effective branch by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4198
> * fix(deps): update module github.com/go-jose/go-jose/v4 to v4.1.5 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4201
> * fix(deps): update module github.com/coreos/go-oidc/v3 to v3.21.0 - autoclosed by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4202
> * Fix Dredd test server startup and port conflicts by @rzaitov in https://github.com/semaphoreui/semaphore/pull/4206
> * feat(api): allow template_name when creating project tasks via API by @befika in https://github.com/semaphoreui/semaphore/pull/4128
> * test(runners): add integration test suite for local, docker, and k8s executor modes by @NewMayur in https://github.com/semaphoreui/semaphore/pull/4208
> * feat(config): support SEMAPHORE_TLS_HTTP_REDIRECT_PORT pointer env var by @NewMayur in https://github.com/semaphoreui/semaphore/pull/4167
> * feat(ui): add YAML format support for Extra Variables in Variable Groups by @thinas1115 in https://github.com/semaphoreui/semaphore/pull/4158
> * feat(ansible): add support for galaxy role and collection arguments i… by @befika in https://github.com/semaphoreui/semaphore/pull/4160
> * chore(deps-dev): bump svgo from 2.8.3 to 2.8.4 in /web by @dependabot[bot] in https://github.com/semaphoreui/semaphore/pull/4217
> * fix(deps): update module github.com/stretchr/testify to v1.12.1 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4205
> * fix(deps): update module github.com/sirupsen/logrus to v1.10.2 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4204
> * feat(templates): hide Dry Run and Diff checkboxes per template by @lucuma13 in https://github.com/semaphoreui/semaphore/pull/4152
> * chore(deps): update dependency openai to v7.13.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4121
> * fix(deps): update module golang.org/x/crypto to v0.57.0 - autoclosed by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4218
> * fix(deps): update dependency js-yaml to v5 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4221
> * fix(deps): update module modernc.org/sqlite to v1.58.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4220
> * fix(deps): update module golang.org/x/oauth2 to v0.37.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4219
> * feat(runners): add server-side debug diagnostics by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4222
> * fix(runner): authenticate unregister requests by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4214
> * chore(deps): update dependency openai to v7.14.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4224
> * feat(integration): initialize Params map if nil in GetTaskDefinition by @befika in https://github.com/semaphoreui/semaphore/pull/4089
> * feat(auth): session duration by @fiftin in https://github.com/semaphoreui/semaphore/pull/4227
> * chore(deps): update dependency openai to v7.15.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4226
> * feat: suppress error notifications per template by @EyJunge1 in https://github.com/semaphoreui/semaphore/pull/4232
> * chore(deps): update dependency cron-parser to v5.10.1 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4237
> * Adding username to task logging by @JRNC in https://github.com/semaphoreui/semaphore/pull/4239
> * chore(deps): update dependency js-yaml to v5.4.2 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4238
> * docs: template alert suppression and server log debugging by @cursor[bot] in https://github.com/semaphoreui/semaphore/pull/4241
> * Gracefully stop and clean up local task process groups by @rzaitov in https://github.com/semaphoreui/semaphore/pull/4228
> * fix(deps): update module modernc.org/sqlite to v1.59.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4242
> * chore(deps): update dependency openai to v7.18.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4245
> * chore(deps): update dependency prettier to v3.9.8 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4244
> * chore(deps): update dependency dotenv to v18 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4248
> * chore(deps): update dependency openai to v7.20.0 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4252
> * feat/gen ssh key by @fiftin in https://github.com/semaphoreui/semaphore/pull/3656
> * chore(tests): replace os.Setenv with t.Setenv by @EyJunge1 in https://github.com/semaphoreui/semaphore/pull/4271
> * fix(ui): make schedule timezone alert dismissible by @EyJunge1 in https://github.com/semaphoreui/semaphore/pull/4267
> * chore(deps): update dependency dotenv to v18.0.3 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4273
> * feat(integrations): add HMAC-SHA512 webhook auth method by @EyJunge1 in https://github.com/semaphoreui/semaphore/pull/4270
> * fix(ui): exclude log timestamps from text selection by @EyJunge1 in https://github.com/semaphoreui/semaphore/pull/4266
> * fix(git): forward proxy environment vars and support auth encoding in bare metal installations by @NewMayur in https://github.com/semaphoreui/semaphore/pull/4197
> * feat(host-config): map ssh hosts and git URLs to project credentials by @befika in https://github.com/semaphoreui/semaphore/pull/4251
> * Feat/refactor workflows by @fiftin in https://github.com/semaphoreui/semaphore/pull/4287
> * feat(audit): add the security audit log by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4291
> * feat(git): enhance galaxyGitEnv for private repository authentication and add tests by @befika in https://github.com/semaphoreui/semaphore/pull/4156
> * feat(audit): record resource and secret events by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4296
> * feat(audit): record task and runner events by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4300
> * feat(workflows): add environment variables about current workflow run by @fiftin in https://github.com/semaphoreui/semaphore/pull/4302
> * feat(audit): add the audit.splunk_hec configuration section by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4309
> * feat(audit): delete audit events older than a retention period by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4313
> * fix(template): offer the files of the selected app in the file picker by @befika in https://github.com/semaphoreui/semaphore/pull/4298
> * chore(deps): update dependency dotenv to v18.0.7 by @renovate[bot] in https://github.com/semaphoreui/semaphore/pull/4283
> * chore(deps-dev): bump compression from 1.8.1 to 1.8.2 in /web by @dependabot[bot] in https://github.com/semaphoreui/semaphore/pull/4331
> * chore(deps-dev): bump joi from 17.13.4 to 17.13.8 in /web by @dependabot[bot] in https://github.com/semaphoreui/semaphore/pull/4330
> * feat(audit): add the audit log screen by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4325
> * feat/workflow artifacts by @fiftin in https://github.com/semaphoreui/semaphore/pull/4334
> * feat(repository): share one checkout between the templates of a monorepo by @befika in https://github.com/semaphoreui/semaphore/pull/4326
> * Fix concurrent static inventory cleanup by @sean0407 in https://github.com/semaphoreui/semaphore/pull/4335
> * fix(tasks): use unsafe only for Jinja2 by @fiftin in https://github.com/semaphoreui/semaphore/pull/4339
> * feat/git shallow clone by @fiftin in https://github.com/semaphoreui/semaphore/pull/4340
> * docs: add Pethost as a deployment option by @sadfun in https://github.com/semaphoreui/semaphore/pull/4342
> * feat(roles): give every role an ID by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4341
> * feat(roles): let members hold several roles by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4343
> * feat(roles): read roles from group mappings by @souryogurt in https://github.com/semaphoreui/semaphore/pull/4347
> * Feat/wf survey vars by @fiftin in https://github.com/semaphoreui/semaphore/pull/4346
> * Feat/features from ex by @fiftin in https://github.com/semaphoreui/semaphore/pull/4348
> …

## 2.19.17-1

- Refuse to start while `cookie_hash`, `cookie_encryption` or `access_key_encryption` still hold the placeholder, instead of panicking on invalid base64.

## 2.19.17

- Roll back from 2.19.18: GitHub released `v2.19.18` but Docker Hub never
  published `semaphoreui/semaphore:v2.19.18`, so the HA image build failed and
  `ghcr.io/.../hassio-addons-semaphore-{arch}:2.19.18` was never pushed
  (Supervisor 404). Stay on upstream Docker tag `v2.19.17` until Hub catches up.
- Previously: upgrading from upstream version 2.19.16 -> 2.19.17.

## 2.19.16

- Upgrading from upstream version 2.19.14 -> 2.19.16

> Upstream v2.19.16: https://github.com/semaphoreui/semaphore/releases/tag/v2.19.16
>
> ## Configurable runner check interval
>
> Runners can now be told how often to ask the server for new jobs. Until now the interval was hard-coded to 1 second, which on installations with many runners produced a noticeable amount of request traffic.
>
> New option in the runner section of the runner config:
>
> ```
> {
>   "runner": {
>     "check_interval_seconds": 5
>   }
> }
> ```
> Or via environment variable:
>
> ```
> SEMAPHORE_RUNNER_CHECK_INTERVAL_SECONDS=5
> ```
>
> Default: 1 second, so existing installations behave exactly as before. Values of 0, negative values, or values too large to represent as a duration fall back to the default.
>
> What changes and what does not. Only the check for new jobs honours the configured interval. The runner's progress report, which also serves as its heartbeat, keeps running once per second. Raising the check interval therefore does not affect when the server marks a runner offline. Jobs will start up to check_interval_seconds later than before, so pick a value that matches how quickly you need new tasks to be picked up.
>
> Affected components: runner (semaphore runner start), config schema. No database migration, no changes to the server or the web interface.

## 2.19.14
- Upgrade Semaphore 2.19.12 -> 2.19.14, Terraform 1.16.2 -> 1.16.4, OpenTofu 1.12.6 -> 1.13.0

- Edit CI workflows to autobuild on upstream release.

## 2.19.12

- Upgrade Semaphore 2.18.12 -> 2.19.12, Terraform 1.15.7 -> 1.16.2,
  OpenTofu 1.12.3 -> 1.12.6.

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
  built on `ghcr.io/hassio-addons/base:stable` (Alpine 3.24, s6-overlay v3,
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
