#!/usr/bin/with-contenv bashio
# ==============================================================================
# Prepare pgAdmin: point it at persisted storage and create the admin account
# ==============================================================================
set -e

readonly DATA_DIR="/data/pgadmin"
readonly USER_CFG="/config/config_local.py"
mkdir -p "${DATA_DIR}/sessions" "${DATA_DIR}/storage"

# pgAdmin configuration (config_local.py), in order of precedence:
#   1. /config/config_local.py  — a full Python config you drop in (wholesale
#      replacement; use this for OIDC / OAUTH2_CONFIG, LDAP, etc.)
#   2. the `config` app option — the same, supplied inline
#   3. the built-in default below — persisted storage in /data/pgadmin
#
# A custom config replaces the whole file, so include the storage settings you
# want to keep (see DOCS.md for a complete OIDC template).
if bashio::fs.file_exists "${USER_CFG}"; then
  bashio::log.info "Using custom pgAdmin config from ${USER_CFG}"
  cp "${USER_CFG}" /pgadmin4/config_local.py
elif bashio::config.has_value 'config'; then
  bashio::log.info "Using inline pgAdmin config from the app options"
  bashio::config 'config' > /pgadmin4/config_local.py
else
  bashio::log.info "Using the built-in default pgAdmin config"
  cat > /pgadmin4/config_local.py <<EOF
SERVER_MODE = True
DATA_DIR = '/data/pgadmin'
LOG_FILE = '/data/pgadmin/pgadmin4.log'
SQLITE_PATH = '/data/pgadmin/pgadmin4.db'
SESSION_DB_PATH = '/data/pgadmin/sessions'
STORAGE_DIR = '/data/pgadmin/storage'
AZURE_CREDENTIAL_CACHE_DIR = '/data/pgadmin/azurecredentialcache'
KERBEROS_CCACHE_DIR = '/data/pgadmin/krbccache'
EOF
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

  passfile_field=""
  if bashio::config.has_value 'postgres_password'; then
    # .pgpass enables passwordless connect: host:port:db:user:password
    printf '%s:%s:*:%s:%s\n' "${pg_host}" "${pg_port}" "${pg_user}" \
      "$(bashio::config 'postgres_password')" > "${pgpass}"
    chmod 600 "${pgpass}"
    passfile_field=$(printf ',\n      "PassFile": "%s"' "${pgpass}")
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
    }
  }
}
EOF

  bashio::log.info "Registering PostgreSQL server '${pg_host}:${pg_port}' for ${admin_email} ..."
  /venv/bin/python /pgadmin4/setup.py load-servers /tmp/servers.json \
    --user "${admin_email}" --replace || bashio::log.warning "Could not register the PostgreSQL server."
  rm -f /tmp/servers.json
fi
