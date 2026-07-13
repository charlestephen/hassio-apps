# Home Assistant Add-on: pgAdmin

## Overview

pgAdmin 4 is the standard web UI for administering PostgreSQL — browse and edit
data, run queries, manage roles and databases, and monitor activity. It pairs
with the **PostgreSQL** add-on in this repository.

It runs in multi-user (server) mode behind gunicorn and stores its
configuration database and per-user storage in `/data/pgadmin` (persisted by the
add-on).

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `email` | email | `admin@example.com` | Login email for the initial administrator account. |
| `password` | password | `changeme` | Password for the initial administrator. **Change this.** |
| `log_level` | list | `info` | Add-on log verbosity. |
| `config` | string | _(empty)_ | A full pgAdmin `config_local.py` to use instead of the default (wholesale replacement — see below). |

> The administrator account is created from `email`/`password` only on **first
> start** (when the config database is created). To change it later, do so from
> within pgAdmin (Users / Change Password).

### Example

```yaml
email: you@example.com
password: "a-strong-password"
log_level: info
```

## Custom configuration (OIDC / OAuth2, LDAP, ...)

pgAdmin is configured through a Python `config_local.py`. This add-on lets you
**replace it wholesale** so you can enable authentication sources like OIDC.

Precedence (highest first):

1. **`/config/config_local.py`** — drop a complete file into the add-on config
   directory (`/addon_configs/<slug>_pgadmin/config_local.py`). Best for large
   configs. Used verbatim.
2. **`config` option** — paste the same Python config on the Configuration page.
3. **built-in default** — persisted storage only.

A custom config replaces the *entire* file, so keep the storage settings you
want. A complete OIDC template:

```python
# --- keep these so data stays in /data (persisted) ---
SERVER_MODE = True
DATA_DIR = '/data/pgadmin'
LOG_FILE = '/data/pgadmin/pgadmin4.log'
SQLITE_PATH = '/data/pgadmin/pgadmin4.db'
SESSION_DB_PATH = '/data/pgadmin/sessions'
STORAGE_DIR = '/data/pgadmin/storage'

# --- OIDC / OAuth2 ---
AUTHENTICATION_SOURCES = ['oauth2', 'internal']
OAUTH2_AUTO_CREATE_USER = True
OAUTH2_CONFIG = [
    {
        'OAUTH2_NAME': 'oidc',
        'OAUTH2_DISPLAY_NAME': 'Login with SSO',
        'OAUTH2_CLIENT_ID': 'pgadmin',
        'OAUTH2_CLIENT_SECRET': 'your-client-secret',
        'OAUTH2_TOKEN_URL': 'https://idp.example.com/token',
        'OAUTH2_AUTHORIZATION_URL': 'https://idp.example.com/authorize',
        'OAUTH2_API_BASE_URL': 'https://idp.example.com/',
        'OAUTH2_USERINFO_ENDPOINT': 'userinfo',
        'OAUTH2_SERVER_METADATA_URL': 'https://idp.example.com/.well-known/openid-configuration',
        'OAUTH2_SCOPE': 'openid email profile',
        'OAUTH2_ICON': 'fa-openid',
        'OAUTH2_BUTTON_COLOR': '#3253a8',
    },
]
```

The internal admin (from `email`/`password`) is still created, so you keep a
local fallback alongside SSO. The redirect URI to register with your IdP is
`http://<home-assistant-ip>:5050/oauth2/authorize`.

## Access

Open the web UI from the **Open Web UI** button, or at:

```
http://<home-assistant-ip>:5050/
```

Log in with the `email` / `password` configured above.

## Connecting to the PostgreSQL add-on

By default this add-on **auto-registers** the PostgreSQL add-on as a server, so
"Home Assistant PostgreSQL" appears in the tree the first time you log in — just
expand it. Add-ons reach each other by the hostname `<repo>-<slug>`; the host is
derived automatically from this add-on's own hostname (so you don't need to know
the repository prefix), and a `.pgpass` is written so the connection needs no
password prompt.

Control it with these options:

| Option | Default | Description |
|--------|---------|-------------|
| `register_postgres` | `true` | Auto-register the PostgreSQL server. Set `false` to manage servers manually. |
| `postgres_host` | _(empty → auto)_ | Override the host. Empty derives `<repo>-postgres` from this add-on's hostname. |
| `postgres_port` | `5432` | PostgreSQL port. |
| `postgres_user` | `postgres` | Username. |
| `postgres_password` | `changeme` | Used for passwordless connect (matches the PostgreSQL add-on's `superuser_password`). Leave empty to be prompted. |
| `postgres_db` | `homeassistant` | Maintenance database. |

> Keep `postgres_password` in sync with the PostgreSQL add-on's
> `superuser_password`. The registration is refreshed on every start.

To register manually instead, set `register_postgres: false` and use
**Add New Server** with Host `<repo>-postgres` (or your Home Assistant IP),
Port `5432`, Username `postgres`, and the PostgreSQL add-on's password.

## Data

The pgAdmin configuration database, session data and user storage live in
`/data/pgadmin` and are included in Home Assistant snapshots/backups.
