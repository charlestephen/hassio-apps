#!/usr/bin/with-contenv bashio
# ==============================================================================
# Initialize the PostgreSQL cluster on first run
# ==============================================================================
set -e

readonly PGDATA="/data/postgres"

# The unix socket directory lives on tmpfs (/run), so recreate it every start.
mkdir -p /run/postgresql
chown postgres:postgres /run/postgresql

mkdir -p "${PGDATA}"
chown postgres:postgres /data "${PGDATA}"
chmod 700 "${PGDATA}"

if bashio::fs.file_exists "${PGDATA}/PG_VERSION"; then
  bashio::log.info "Existing PostgreSQL data directory found in ${PGDATA}."
  exit 0
fi

bashio::log.info "Initializing a new PostgreSQL 18 cluster in ${PGDATA} ..."
printf '%s' "$(bashio::config 'superuser_password')" > /tmp/pgpw
su-exec postgres initdb -D "${PGDATA}" \
  --username=postgres --pwfile=/tmp/pgpw \
  --auth-host=scram-sha-256 --auth-local=trust --encoding=UTF8 >/dev/null
rm -f /tmp/pgpw

# Listen on all interfaces; require password auth from the network.
echo "listen_addresses = '*'" >> "${PGDATA}/postgresql.conf"
{
  echo "host all all 0.0.0.0/0 scram-sha-256"
  echo "host all all ::/0      scram-sha-256"
} >> "${PGDATA}/pg_hba.conf"

# Create the configured default database via a temporary, socket-only server.
database="$(bashio::config 'database')"
if bashio::var.has_value "${database}"; then
  bashio::log.info "Creating database '${database}' ..."
  su-exec postgres pg_ctl -D "${PGDATA}" -o "-c listen_addresses='' -p 5432" -w start
  su-exec postgres createdb "${database}" || bashio::log.warning "Database '${database}' may already exist."
  su-exec postgres pg_ctl -D "${PGDATA}" -m fast -w stop
fi

bashio::log.info "PostgreSQL initialization complete."
