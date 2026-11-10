#!/usr/bin/with-contenv bashio
# ==============================================================================
# Prepare pgAdmin: point it at persisted storage and create the admin account
# ==============================================================================
set -e

readonly DATA_DIR="/data/pgadmin"
readonly USER_CFG="/config/config_local.py"
mkdir -p "${DATA_DIR}/sessions" "${DATA_DIR}/storage"

# pgAdmin configuration (config_local.py), in order of precedence:
#   1. /config/config_local.py  — a full Python config you drop in (wholesale)
#   2. the `config` app option — the same, supplied inline
#   3. generated — storage + OIDC (when enabled) + optional config_vars
#   4. built-in storage-only default
#
# A custom config (1/2) replaces the whole file, so include the storage settings
# you want to keep (see DOCS.md).
if bashio::fs.file_exists "${USER_CFG}"; then
  bashio::log.info "Using custom pgAdmin config from ${USER_CFG}"
  cp "${USER_CFG}" /pgadmin4/config_local.py
elif bashio::config.has_value 'config'; then
  bashio::log.info "Using inline pgAdmin config from the app options"
  bashio::config 'config' > /pgadmin4/config_local.py
else
  # Generate via Python so secrets are escaped with repr() (no shell interpolation).
  bashio::log.info "Generating pgAdmin config_local.py from options"
  /venv/bin/python - <<'PY'
import json
import re
from pathlib import Path

opts = json.load(open("/data/options.json", encoding="utf-8"))

lines = [
    "SERVER_MODE = True",
    "DATA_DIR = '/data/pgadmin'",
    "LOG_FILE = '/data/pgadmin/pgadmin4.log'",
    "SQLITE_PATH = '/data/pgadmin/pgadmin4.db'",
    "SESSION_DB_PATH = '/data/pgadmin/sessions'",
    "STORAGE_DIR = '/data/pgadmin/storage'",
    "AZURE_CREDENTIAL_CACHE_DIR = '/data/pgadmin/azurecredentialcache'",
    "KERBEROS_CCACHE_DIR = '/data/pgadmin/krbccache'",
]

if opts.get("oauth2_enabled"):
    client_id = (opts.get("oauth2_client_id") or "").strip()
    client_secret = opts.get("oauth2_client_secret") or ""
    meta = (opts.get("oauth2_server_metadata_url") or "").strip()
    if not client_id or not client_secret or not meta:
        raise SystemExit(
            "oauth2_enabled requires oauth2_client_id, oauth2_client_secret, "
            "and oauth2_server_metadata_url"
        )

    raw_sources = (opts.get("authentication_sources") or "").strip()
    if not raw_sources:
        raw_sources = "oauth2,internal"
    sources = [p.strip() for p in raw_sources.split(",") if p.strip()]

    name = (opts.get("oauth2_name") or "oidc").strip() or "oidc"
    display = (opts.get("oauth2_display_name") or "Login with SSO").strip() or "Login with SSO"
    scope = (opts.get("oauth2_scope") or "openid email profile").strip() or "openid email profile"
    icon = (opts.get("oauth2_icon") or "fa-openid").strip() or "fa-openid"
    color = (opts.get("oauth2_button_color") or "#3253a8").strip() or "#3253a8"
    auto_create = bool(opts.get("oauth2_auto_create_user", True))

    lines.append(f"AUTHENTICATION_SOURCES = {sources!r}")
    lines.append(f"OAUTH2_AUTO_CREATE_USER = {auto_create!r}")
    lines.append(
        "OAUTH2_CONFIG = ["
        + repr(
            {
                "OAUTH2_NAME": name,
                "OAUTH2_DISPLAY_NAME": display,
                "OAUTH2_CLIENT_ID": client_id,
                "OAUTH2_CLIENT_SECRET": client_secret,
                "OAUTH2_SERVER_METADATA_URL": meta,
                "OAUTH2_SCOPE": scope,
                "OAUTH2_ICON": icon,
                "OAUTH2_BUTTON_COLOR": color,
            }
        )
        + "]"
    )

ident = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
for item in opts.get("config_vars") or []:
    name = (item.get("name") or "").strip()
    if not name or not ident.match(name):
        continue
    value = item.get("value")
    if value in ("True", "False", "None") or (
        isinstance(value, str) and value.isdigit()
    ):
        lines.append(f"{name} = {value}")
    elif isinstance(value, bool):
        lines.append(f"{name} = {value!r}")
    elif isinstance(value, int) and not isinstance(value, bool):
        lines.append(f"{name} = {value!r}")
    elif value is None:
        lines.append(f"{name} = None")
    else:
        lines.append(f"{name} = {value!r}")

Path("/pgadmin4/config_local.py").write_text("\n".join(lines) + "\n", encoding="utf-8")
PY
fi

# First run: create the config DB and the initial administrator account.
if ! bashio::fs.file_exists "${DATA_DIR}/pgadmin4.db"; then
  bashio::log.info "Initializing pgAdmin configuration database ..."
  PGADMIN_SETUP_EMAIL="$(bashio::config 'email')" \
  PGADMIN_SETUP_PASSWORD="$(bashio::config 'password')" \
    /venv/bin/python /pgadmin4/setup.py setup-db
  bashio::log.info "pgAdmin initialization complete."
fi

# Auto-register the PostgreSQL app as a managed server (idempotent: --replace
# updates the entry every start).
#
# Apps reach each other by hostname = "<repo>-<slug>" on the HA network. This
# app's own hostname already carries the right "<repo>-" prefix, so when
# postgres_host is left empty we derive the PostgreSQL host from it by swapping
# the "-pgadmin" suffix for "-postgres" (e.g. e6d9f622-pgadmin -> e6d9f622-postgres).
if bashio::config.true 'register_postgres'; then
  pg_host="$(bashio::config 'postgres_host')"
  if ! bashio::var.has_value "${pg_host}"; then
    pg_host="$(hostname | sed 's/-pgadmin$/-postgres/')"
  fi
  pg_port="$(bashio::config 'postgres_port')"
  pg_user="$(bashio::config 'postgres_user')"
  pg_db="$(bashio::config 'postgres_db')"
  admin_email="$(bashio::config 'email')"
  pgpass="${DATA_DIR}/pgpass"

  bouncer_host="$(hostname | sed 's/-pgadmin$/-pgbouncer/')"
  passfile_field=""
  if bashio::config.has_value 'postgres_password'; then
    # .pgpass enables passwordless connect: host:port:db:user:password
    printf '%s:%s:*:%s:%s\n' "${pg_host}" "${pg_port}" "${pg_user}" \
      "$(bashio::config 'postgres_password')" > "${pgpass}"
    if bashio::config.true 'register_pgbouncer'; then
      printf '%s:6432:*:%s:%s\n' "${bouncer_host}" "${pg_user}" \
        "$(bashio::config 'postgres_password')" >> "${pgpass}"
    fi
    chmod 600 "${pgpass}"
    passfile_field=$(printf ',\n      "PassFile": "%s"' "${pgpass}")
  fi

  bouncer_entry=""
  if bashio::config.true 'register_pgbouncer'; then
    bouncer_entry=$(printf ',\n    "2": {\n      "Name": "Home Assistant PgBouncer",\n      "Group": "Servers",\n      "Host": "%s",\n      "Port": 6432,\n      "Username": "%s",\n      "MaintenanceDB": "%s",\n      "SSLMode": "prefer"%s\n    }' \
      "${bouncer_host}" "${pg_user}" "${pg_db}" "${passfile_field}")
  fi

  cat > /tmp/servers.json <<EOF
{
  "Servers": {
    "1": {
      "Name": "Home Assistant PostgreSQL",
      "Group": "Servers",
      "Host": "${pg_host}",
      "Port": ${pg_port},
      "Username": "${pg_user}",
      "MaintenanceDB": "${pg_db}",
      "SSLMode": "prefer"${passfile_field}
    }${bouncer_entry}
  }
}
EOF

  bashio::log.info "Registering PostgreSQL server '${pg_host}:${pg_port}' for ${admin_email} ..."
  /venv/bin/python /pgadmin4/setup.py load-servers /tmp/servers.json \
    --user "${admin_email}" --replace || bashio::log.warning "Could not register the PostgreSQL server."
  rm -f /tmp/servers.json
fi
