# Home Assistant Add-on: Semaphore

Semaphore UI is a modern open-source web interface for Ansible, Terraform,
OpenTofu, and other DevOps automation tools. This add-on runs Semaphore as
a supervised Home Assistant add-on with persistent state.

The image bundles the toolchains Semaphore's task templates call, so Ansible
(with Python 3), Terraform, and OpenTofu templates all work out of the box —
no extra installs. Versions are pinned in `build.yaml`.

---

## First-Time Setup

1. **Generate security keys** before starting. In a terminal run:
   ```bash
   head -c32 /dev/urandom | base64   # for cookie_hash and access_key_encryption
   head -c16 /dev/urandom | base64   # for cookie_encryption
   ```
   Paste the results into the corresponding fields in the Configuration tab.

2. **Set a strong admin password** — change `admin_password` from `changeme`.

3. **Start the add-on** — the admin account is created on first boot only.

4. **Open the Web UI** at `http://<home-assistant-ip>:3000`.

5. **Add your first project** → create an Inventory, a Key Store entry (for SSH
   keys), and a Repository, then create a Task Template pointing at a playbook.

---

## Configuration Options

### Security — Encryption Keys

| Option | Env var | Description |
|---|---|---|
| `cookie_hash` | `SEMAPHORE_COOKIE_HASH` | 32-byte base64 key for signing session cookies. **Must be changed.** |
| `cookie_encryption` | `SEMAPHORE_COOKIE_ENCRYPTION` | 16-byte base64 key for encrypting session cookies. **Must be changed.** |
| `access_key_encryption` | `SEMAPHORE_ACCESS_KEY_ENCRYPTION` | 32-byte base64 key for encrypting SSH keys and passwords stored in the database. **Must be changed.** |

Generate with `head -c32 /dev/urandom | base64` (use `c16` for cookie_encryption).

### Admin Account

Created on first boot only (when the SQLite database does not exist yet).

| Option | Env var | Default |
|---|---|---|
| `admin_username` | `SEMAPHORE_ADMIN` | `admin` |
| `admin_password` | `SEMAPHORE_ADMIN_PASSWORD` | `changeme` |
| `admin_name` | `SEMAPHORE_ADMIN_NAME` | `Administrator` |
| `admin_email` | `SEMAPHORE_ADMIN_EMAIL` | `admin@localhost` |

### Server

| Option | Env var | Default | Description |
|---|---|---|---|
| `web_root` | `SEMAPHORE_WEB_ROOT` | _(empty)_ | Public base URL, e.g. `https://semaphore.home/` — required when running behind a reverse proxy at a subpath. |
| `schedule_timezone` | `SEMAPHORE_SCHEDULE_TIMEZONE` | _(UTC)_ | Timezone for cron schedules, e.g. `America/New_York`. |
| `max_parallel_tasks` | `SEMAPHORE_MAX_PARALLEL_TASKS` | `0` (unlimited) | Maximum concurrent running tasks across all projects. |
| `max_task_duration_sec` | `MAX_TASK_DURATION_SEC` | `0` (unlimited) | Kill tasks that run longer than this many seconds. |
| `max_tasks_per_template` | `SEMAPHORE_MAX_TASKS_PER_TEMPLATE` | `30` | Number of recent task runs kept per template. |
| `git_client` | `SEMAPHORE_GIT_CLIENT` | `cmd_git` | Git client: `cmd_git` (uses the system `git` binary) or `go_git` (pure-Go, no binary dependency). |
| `password_login_disabled` | `SEMAPHORE_PASSWORD_LOGIN_DISABLED` | `false` | Disable username/password login (LDAP-only or SSO mode). |
| `non_admin_can_create_project` | `SEMAPHORE_NON_ADMIN_CAN_CREATE_PROJECT` | `false` | Allow regular users to create new projects. |

### Security — Two-Factor Authentication (TOTP)

| Option | Env var | Default | Description |
|---|---|---|---|
| `totp_enabled` | `SEMAPHORE_TOTP_ENABLED` | `false` | Enable TOTP two-factor authentication. |
| `totp_allow_recovery` | `SEMAPHORE_TOTP_ALLOW_RECOVERY` | `false` | Allow users to reset TOTP using a recovery code. |
| `totp_issuer` | `SEMAPHORE_TOTP_ISSUER` | `Semaphore` | Issuer name shown in authenticator apps. |

### Email / SMTP Alerts

| Option | Env var | Description |
|---|---|---|
| `email_alert` | `SEMAPHORE_EMAIL_ALERT` | Enable email notifications for task results. |
| `email_sender` | `SEMAPHORE_EMAIL_SENDER` | From address for outgoing emails. |
| `email_host` | `SEMAPHORE_EMAIL_HOST` | SMTP server hostname. |
| `email_port` | `SEMAPHORE_EMAIL_PORT` | SMTP port (default: 25). |
| `email_username` | `SEMAPHORE_EMAIL_USERNAME` | SMTP authentication username. |
| `email_password` | `SEMAPHORE_EMAIL_PASSWORD` | SMTP authentication password. |
| `email_secure` | `SEMAPHORE_EMAIL_SECURE` | Enable STARTTLS upgrade. |
| `email_tls` | `SEMAPHORE_EMAIL_TLS` | Use SSL/TLS from the start (port 465 style). |

### LDAP Authentication

| Option | Env var | Description |
|---|---|---|
| `ldap_enable` | `SEMAPHORE_LDAP_ENABLE` | Enable LDAP/AD authentication. |
| `ldap_server` | `SEMAPHORE_LDAP_SERVER` | LDAP server address, e.g. `ldap.company.com:389`. |
| `ldap_bind_dn` | `SEMAPHORE_LDAP_BIND_DN` | Bind DN for directory searches. |
| `ldap_bind_password` | `SEMAPHORE_LDAP_BIND_PASSWORD` | Password for the bind DN. |
| `ldap_search_dn` | `SEMAPHORE_LDAP_SEARCH_DN` | Base DN for user searches. |
| `ldap_search_filter` | `SEMAPHORE_LDAP_SEARCH_FILTER` | LDAP search filter, e.g. `(uid=%s)`. |
| `ldap_needtls` | `SEMAPHORE_LDAP_NEEDTLS` | Require TLS for the LDAP connection. |
| `ldap_mapping_dn` | `SEMAPHORE_LDAP_MAPPING_DN` | Attribute used as the user DN (default: `dn`). |
| `ldap_mapping_mail` | `SEMAPHORE_LDAP_MAPPING_MAIL` | Attribute containing the email address (default: `mail`). |
| `ldap_mapping_uid` | `SEMAPHORE_LDAP_MAPPING_UID` | Attribute containing the username (default: `uid`). |
| `ldap_mapping_cn` | `SEMAPHORE_LDAP_MAPPING_CN` | Attribute containing the display name (default: `cn`). |

### Messenger Alerts

| Option | Env var | Description |
|---|---|---|
| `telegram_alert` | `SEMAPHORE_TELEGRAM_ALERT` | Enable Telegram notifications. |
| `telegram_chat` | `SEMAPHORE_TELEGRAM_CHAT` | Telegram chat ID. |
| `telegram_token` | `SEMAPHORE_TELEGRAM_TOKEN` | Telegram bot token. |
| `slack_alert` | `SEMAPHORE_SLACK_ALERT` | Enable Slack notifications. |
| `slack_url` | `SEMAPHORE_SLACK_URL` | Slack incoming webhook URL. |
| `rocketchat_alert` | `SEMAPHORE_ROCKETCHAT_ALERT` | Enable Rocket.Chat notifications. |
| `rocketchat_url` | `SEMAPHORE_ROCKETCHAT_URL` | Rocket.Chat webhook URL. |
| `microsoft_teams_alert` | `SEMAPHORE_MICROSOFT_TEAMS_ALERT` | Enable Microsoft Teams notifications. |
| `microsoft_teams_url` | `SEMAPHORE_MICROSOFT_TEAMS_URL` | Microsoft Teams webhook URL. |

### Ansible

| Option | Env var | Default | Description |
|---|---|---|---|
| `ansible_host_key_checking` | `ANSIBLE_HOST_KEY_CHECKING` | `false` | Set to `true` to enforce SSH host-key verification (recommended for production). Default `false` for initial convenience. |

### Logging

| Option | Env var | Description |
|---|---|---|
| `log_level` | `SEMAPHORE_LOG_LEVEL` | Server log verbosity: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`. Set to `debug` to troubleshoot login/auth, then back to `info`. |

### OIDC / SSO Login

Adds a "Sign in with…" button backed by an OpenID Connect provider (Authelia,
Keycloak, Authentik, Google, …). The provider must expose OIDC discovery at
`<provider_url>/.well-known/openid-configuration`.

| Option | Description |
|---|---|
| `oidc_enable` | Turn OIDC login on. |
| `oidc_provider_id` | Short id used in the callback path (`/api/auth/oidc/<id>/redirect`), e.g. `authelia`. |
| `oidc_display_name` | Text on the login button. |
| `oidc_icon` / `oidc_color` / `oidc_order` | Optional button appearance: MDI icon, color, and position on the login screen. |
| `oidc_provider_url` | Issuer URL (used for auto-discovery). |
| `oidc_client_id` / `oidc_client_secret` | Credentials for the Semaphore client at your provider (secret is masked). |
| `oidc_redirect_url` | Full callback URL — must match the provider registration (see below). |
| `oidc_username_claim` / `oidc_email_claim` / `oidc_name_claim` | ID-token claims mapped to Semaphore's username / email / display name. |
| `oidc_scopes` | Space-separated scopes (default `openid profile email`). |

**Setup:**

1. At your OIDC provider, register a client with redirect URI
   `https://<your-semaphore-url>/api/auth/oidc/<oidc_provider_id>/redirect`.
2. Put that same URL in `oidc_redirect_url`, set `oidc_provider_url`,
   `oidc_client_id`, `oidc_client_secret`, and enable `oidc_enable`.
3. Set `web_root` to your public Semaphore URL so callbacks resolve correctly
   behind a reverse proxy.
4. Restart the add-on; the button appears on the login screen.

> The whole provider map is passed to Semaphore as JSON via
> `SEMAPHORE_OIDC_PROVIDERS`; this add-on exposes a single provider through the
> flat options above.

---

## Data & Storage

| Path | Contents |
|---|---|
| `/data/semaphore/semaphore.sqlite` | SQLite database (projects, users, tasks, encrypted keys) |
| `/data/semaphore/tmp/` | Task working directory (cloned repos, generated inventory) |
| `/share/semaphore/playbooks/` | Convenient location for local playbooks accessible from HA Share |
| `/share/semaphore/inventory/` | Convenient location for static inventory files |

---

## Reverse Proxy

When putting Semaphore behind Nginx Proxy Manager or Traefik, set `web_root`
to the full public URL (e.g. `https://semaphore.home/`). Semaphore uses this
value to generate absolute links in emails and UI.

---

## Troubleshooting

- **Admin password forgotten**: Stop the add-on, delete `/data/semaphore/semaphore.sqlite`,
  update `admin_password` in the Configuration tab, restart. All data is lost.
- **Tasks stuck "running"**: Check `max_task_duration_sec` and look at the
  task log in the UI for SSH or inventory errors.
- **Can't SSH to hosts**: Set `ansible_host_key_checking: false` or add host
  keys to `/root/.ssh/known_hosts` inside the container.
