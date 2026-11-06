# Home Assistant App: pgAdmin

## Overview

pgAdmin 4 is the standard web UI for administering PostgreSQL — browse and edit
data, run queries, manage roles and databases, and monitor activity. It pairs
with the **PostgreSQL** app in this repository. This app tracks upstream pgAdmin `9.19`.

It runs in multi-user (server) mode behind gunicorn and stores its
configuration database and per-user storage in `/data/pgadmin` (persisted by the
app). Optional `config_local.py` lives under the app config mount (`/config` →
host `/app_configs/<slug>_pgadmin`). On upgrade from the old `addon_config`
layout, any leftover host folder under `/addon_configs/…_pgadmin` is copied into
`/config` once, then removed.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `email` | email | `admin@example.com` | Login email for the initial administrator account. |
| `password` | password | `changeme` | Password for the initial administrator. **Change this.** |
| `log_level` | list | `info` | App log verbosity. |
| `config` | string | _(empty)_ | A full pgAdmin `config_local.py` to use instead of the default (wholesale replacement — highest option precedence). |
| `oauth2_enabled` | bool | `false` | Generate OAuth2 / OIDC settings into `config_local.py`. |
| `oauth2_name` | string | `oidc` | Internal provider name. |
| `oauth2_display_name` | string | `Login with SSO` | Button label on the login page. |
| `oauth2_client_id` | string | _(empty)_ | IdP client ID (required when OAuth2 is on). |
| `oauth2_client_secret` | password | _(empty)_ | IdP client secret (required when OAuth2 is on). |
| `oauth2_server_metadata_url` | string | _(empty)_ | OpenID discovery URL (required when OAuth2 is on). |
| `oauth2_scope` | string | `openid email profile` | OAuth2 scopes. |
| `oauth2_icon` | string | `fa-openid` | Font Awesome icon class for the button. |
| `oauth2_button_color` | string | `#3253a8` | Button color. |
| `oauth2_auto_create_user` | bool | `true` | Create a pgAdmin user on first SSO login. |
| `authentication_sources` | string | _(empty → `oauth2,internal`)_ | Comma-separated sources when OAuth2 is on. |
| `config_vars` | list | `[]` | Extra `config_local.py` assignments (`name` / `value` / optional `secret`). |

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

pgAdmin is configured through a Python `config_local.py`. Precedence (highest
first):

1. **`/config/config_local.py`** — drop a complete file into the app config
   directory (`/app_configs/<slug>_pgadmin/config_local.py`). Used verbatim.
2. **`config` option** — paste the same Python config on the Configuration page.
3. **Generated options** — storage paths plus `oauth2_*` / `config_vars` when set.
4. **Built-in default** — persisted storage only.

### Pocket ID (recommended UI options)

In Pocket ID create a client with redirect
`https://<pgadmin-fqdn>/oauth2/authorize` (or `http://…` if you are not on TLS).
Then set:

| Option | Value |
|--------|--------|
| `oauth2_enabled` | `true` |
| `oauth2_client_id` | Pocket ID client id |
| `oauth2_client_secret` | Pocket ID client secret |
| `oauth2_server_metadata_url` | `https://<pocket-id-fqdn>/.well-known/openid-configuration` |
| `oauth2_scope` | `openid email profile` |

The internal admin (from `email`/`password`) remains available when
`authentication_sources` includes `internal` (the default).

### Wholesale file / `config` template

A custom file or `config` option replaces the *entire* `config_local.py`, so keep
the storage settings you want:

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
        'OAUTH2_SERVER_METADATA_URL': 'https://idp.example.com/.well-known/openid-configuration',
        'OAUTH2_SCOPE': 'openid email profile',
        'OAUTH2_ICON': 'fa-openid',
        'OAUTH2_BUTTON_COLOR': '#3253a8',
    },
]
```

## Access

Open the web UI from the **Open Web UI** button, or at:

```
http://<home-assistant-ip>:5050/
```

Log in with the `email` / `password` configured above (or SSO when enabled).

## Connecting to the PostgreSQL app

By default this app **auto-registers** the PostgreSQL app as a server, so
"Home Assistant PostgreSQL" appears in the tree the first time you log in — just
expand it. Apps reach each other by the hostname `<repo>-<slug>`; the host is
derived automatically from this app's own hostname (so you don't need to know
the repository prefix), and a `.pgpass` is written so the connection needs no
password prompt.

Control it with these options:

| Option | Default | Description |
|--------|---------|-------------|
| `register_postgres` | `true` | Auto-register the PostgreSQL server. Set `false` to manage servers manually. |
| `postgres_host` | _(empty → auto)_ | Override the host. Empty derives `<repo>-postgres` from this app's hostname. |
| `postgres_port` | `5432` | PostgreSQL port. |
| `postgres_user` | `postgres` | Username. |
| `postgres_password` | `changeme` | Used for passwordless connect (matches the PostgreSQL app's `superuser_password`). Leave empty to be prompted. |
| `postgres_db` | `homeassistant` | Maintenance database. |

> Keep `postgres_password` in sync with the PostgreSQL app's
> `superuser_password`. The registration is refreshed on every start.

To register manually instead, set `register_postgres: false` and use
**Add New Server** with Host `<repo>-postgres` (or your Home Assistant IP),
Port `5432`, Username `postgres`, and the PostgreSQL app's password.

## Data

The pgAdmin configuration database, session data and user storage live in
`/data/pgadmin` and are included in Home Assistant snapshots/backups.
`config_local.py` (if any) lives under `/config` (app config).
