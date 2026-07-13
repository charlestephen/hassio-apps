# Home Assistant Add-on: Forgejo

[Forgejo] is a lightweight self-hosted Git service — an open-source fork of
Gitea. This add-on runs Forgejo inside Home Assistant with persistent storage,
optional SSH access, and a fully-configurable web UI via HA's Configuration tab.

---

## Configuration Options

### Process Identity

| Option | Type | Default | Description |
|---|---|---|---|
| `USER_UID` | integer | `1000` | UID for the `git` process (≥1000). |
| `USER_GID` | integer | `1000` | GID for the `git` process (≥1000). |
| `TZ` | string | `America/New_York` | IANA timezone name. |

### Server

| Option | Env var | Default | Description |
|---|---|---|---|
| `APP_NAME` | `APP_NAME` | `Forgejo` | Application name shown in the browser title and page header. |
| `DOMAIN` | `DOMAIN` | `homeassistant.local` | Hostname used in SSH clone URLs. Set to your HA hostname or IP. |
| `ROOT_URL` | `ROOT_URL` | `http://homeassistant.local:3080/` | Full public base URL — **must end with `/`**. Critical when running behind a reverse proxy (Nginx Proxy Manager, Traefik, etc.). |
| `HTTP_PORT` | `HTTP_PORT` | `3000` | Internal HTTP port (the container port, not the host-mapped port). |
| `SSH_LISTEN_PORT` | `SSH_LISTEN_PORT` | `22` | Port Forgejo's built-in SSH server listens on inside the container. |
| `SSH_PORT` | `SSH_PORT` | `222` | Port shown in SSH clone URLs (the host-mapped SSH port). |
| `DISABLE_SSH` | `DISABLE_SSH` | `false` | Disable the built-in SSH server entirely. |

### Security

| Option | Env var | Description |
|---|---|---|
| `SECRET_KEY` | `SECRET_KEY` | Secret key used to sign cookies and tokens. **Change this from the default before exposing the instance.** Generate with `openssl rand -hex 32`. |
| `INSTALL_LOCK` | `INSTALL_LOCK` | Prevents the initial setup wizard from appearing. Keep `true`. |

### Database

| Option | Env var | Default | Description |
|---|---|---|---|
| `DB_TYPE` | `DB_TYPE` | `sqlite3` | Database backend: `sqlite3` (built-in, no external service), `mysql`, or `postgres`. For MySQL/PostgreSQL set `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASSWD` via the extra_env pattern if needed. |

### User Registration & Access

| Option | Env var | Default | Description |
|---|---|---|---|
| `DISABLE_REGISTRATION` | `DISABLE_REGISTRATION` | `false` | Disable new user self-registration. Enable after initial setup on a private instance. |
| `REQUIRE_SIGNIN_VIEW` | `REQUIRE_SIGNIN_VIEW` | `false` | Require sign-in to browse any content. Useful for fully private instances. |
| `SHOW_REGISTRATION_BUTTON` | `SHOW_REGISTRATION_BUTTON` | `true` | Show or hide the "Sign Up" link on the login page. |
| `DEFAULT_USER_VISIBILITY` | `DEFAULT_USER_VISIBILITY` | `public` | Default visibility for new user profiles: `public`, `limited`, or `private`. |

### Repository Defaults

| Option | Env var | Default | Description |
|---|---|---|---|
| `LFS_START_SERVER` | `LFS_START_SERVER` | `true` | Enable Git Large File Storage (LFS) support. |
| `DEFAULT_BRANCH` | `DEFAULT_BRANCH` | `main` | Default branch name for new repositories. |
| `DEFAULT_PRIVATE` | `DEFAULT_PRIVATE` | `last` | Default visibility for new repositories: `last` (remember the last choice), `private`, or `public`. |
| `ENABLE_PUSH_CREATE_USER` | `ENABLE_PUSH_CREATE_USER` | `false` | Allow users to create a new repository by pushing to a non-existent one. |
| `ENABLE_PUSH_CREATE_ORG` | `ENABLE_PUSH_CREATE_ORG` | `false` | Allow users to create a new organization repository by pushing. |

### Mailer / SMTP

All mailer options are optional. Set `MAILER_ENABLED: true` and fill in the
SMTP details to enable email notifications (user registration confirmation,
password reset, PR/issue notifications).

| Option | Env var | Default | Description |
|---|---|---|---|
| `MAILER_ENABLED` | `MAILER_ENABLED` | `false` | Enable the built-in mailer. |
| `MAILER_FROM` | `MAILER_FROM` | _(empty)_ | Sender address, e.g. `forgejo@example.com`. |
| `MAILER_SMTP_ADDR` | `MAILER_SMTP_ADDR` | _(empty)_ | SMTP server hostname, e.g. `smtp.gmail.com`. |
| `MAILER_SMTP_PORT` | `MAILER_SMTP_PORT` | `587` | SMTP port. |
| `MAILER_USER` | `MAILER_USER` | _(empty)_ | SMTP authentication username. |
| `MAILER_PASSWD` | `MAILER_PASSWD` | _(empty)_ | SMTP authentication password. |
| `MAILER_PROTOCOL` | `MAILER_PROTOCOL` | `smtp+starttls` | SMTP connection protocol: `smtp` (plain), `smtps` (TLS from start, port 465), `smtp+starttls` (STARTTLS upgrade), `smtp+insecure` (no TLS). |

### Logging

| Option | Env var | Default | Description |
|---|---|---|---|
| `LOG_LEVEL` | `LOG_LEVEL` | `info` | Log verbosity: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, or `none`. |

---

## Ports

| Port (host) | Port (container) | Description |
|---|---|---|
| `3080/tcp` | `3000/tcp` | Forgejo web UI |
| `222/tcp` | `22/tcp` | Forgejo SSH server (for `git clone ssh://...`) |

---

## Data & Storage

| Path | Contents |
|---|---|
| `/data/forgejo.db` | SQLite database (users, issues, PRs, settings) |
| `/data/logs/` | Forgejo log files |
| `/data/ssh/` | Host SSH keys for the built-in SSH server |
| `/config/app.ini` | Generated Forgejo configuration (do not edit directly) |
| `/config/sessions/` | Active web sessions |
| `/config/avatars/` | User avatar images |
| `/config/indexers/` | Bleve search index for issues |
| `/share/forgejo/repositories/` | Git repository data |
| `/share/forgejo/lfs/` | Git LFS object store |
| `/share/forgejo/attachments/` | Issue/PR file attachments |
| `/share/forgejo/repo-avatars/` | Repository avatar images |

---

## Reverse Proxy Setup

When running behind Nginx Proxy Manager or Traefik:

1. Set `DOMAIN` to your public hostname, e.g. `git.example.com`.
2. Set `ROOT_URL` to the full public URL, e.g. `https://git.example.com/`.
3. Ensure your proxy passes the `X-Forwarded-*` headers — Forgejo trusts one
   level of reverse proxy by default (`REVERSE_PROXY_LIMIT = 1`).

---

## Security Recommendations

- **Change `SECRET_KEY`** before first use: `openssl rand -hex 32`.
- **Set `DISABLE_REGISTRATION: true`** once you have created your accounts.
- **Set `REQUIRE_SIGNIN_VIEW: true`** on fully private instances.
- **Disable SSH** (`DISABLE_SSH: true`) if you only need the web UI.

---

## Adding the Repository

1. Go to **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add `https://github.com/charlestephen/hassio-apps`.
3. No registry credentials are needed (images are public on `ghcr.io`) under
   **Settings → Add-ons → ⋮ → Registries**.
