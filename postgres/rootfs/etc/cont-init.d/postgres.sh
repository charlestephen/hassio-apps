#!/usr/bin/with-contenv bashio
# ==============================================================================
# Initialize the PostgreSQL cluster on first run
# ==============================================================================
set -e

# shellcheck source=/dev/null
source /usr/local/lib/pgdata.sh
resolve_pgdata
readonly PGBASE PGDATA
readonly DEFAULT_PGDATA="/data/postgres"

# The unix socket directory lives on tmpfs (/run), so recreate it every start.
mkdir -p /run/postgresql
chown postgres:postgres /run/postgresql

if [[ "${PGDATA}" != "${DEFAULT_PGDATA}" ]]; then
  # An unmounted drive leaves an empty folder on the system disk. Refuse to
  # start there, or a new cluster would be created on the wrong disk.
  base_existed=true
  [[ -d "${PGBASE}" ]] || base_existed=false
  mkdir -p "${PGBASE}"
  if [[ "$(stat -c %d /data)" == "$(stat -c %d "${PGBASE}")" ]]; then
    # Remove only a folder created just now; an existing one may be waiting for a mount.
    if [[ "${base_existed}" == "false" ]]; then rmdir "${PGBASE}" 2>/dev/null || true; fi
    bashio::log.fatal "${PGBASE} is on the same filesystem as the app data."
    bashio::log.fatal "Mount the drive at <Supervisor data folder>/media/${PGBASE#/media/} on the host, then restart this app."
    bashio::log.fatal "The Supervisor data folder is often /var/lib/homeassistant or /usr/share/hassio; the app documentation shows how to find it."
    bashio::exit.nok
  fi
  case "$(stat -f -c %T "${PGBASE}")" in
    msdos|vfat|exfat|fuseblk|ntfs|cifs|smb|smb2|v9fs)
      bashio::log.fatal "${PGBASE} is on a filesystem without Unix ownership and permissions."
      bashio::log.fatal "Use ext4, xfs or btrfs for the PostgreSQL data."
      bashio::exit.nok
      ;;
  esac
  mkdir -p "${PGDATA}"
  # An existing cluster in the app storage is only copied when asked to.
  marker="${PGDATA}/.migration-in-progress"
  if bashio::fs.file_exists "${marker}" \
      || { ! bashio::fs.file_exists "${PGDATA}/PG_VERSION" \
           && bashio::fs.file_exists "${DEFAULT_PGDATA}/PG_VERSION"; }; then
    if bashio::config.true 'migrate_existing_data'; then
      migrate-pgdata "${DEFAULT_PGDATA}" "${PGDATA}" || bashio::exit.nok
    else
      bashio::log.fatal "An existing database was found in ${DEFAULT_PGDATA}, or a copy to ${PGDATA} is unfinished."
      bashio::log.fatal "Turn on 'Migrate existing data' to copy it, or uninstall the app to start empty."
      bashio::exit.nok
    fi
  fi
  chown postgres:postgres "${PGDATA}"
  if [[ "$(stat -c %U "${PGDATA}")" != "postgres" ]]; then
    bashio::log.fatal "Could not give ownership of ${PGDATA} to postgres."
    bashio::exit.nok
  fi
else
  mkdir -p "${PGDATA}"
  chown postgres:postgres "${PGDATA}"
fi
chown postgres:postgres /data
chmod 700 "${PGDATA}"

# --- TLS ----------------------------------------------------------------------
# PostgreSQL refuses a key that others can read, and /ssl is read-only, so the
# files are copied to /run (memory only) owned by postgres. The server reads the
# resulting arguments from /run/postgresql/ssl_args when it starts.
SSL_ARGS_FILE="/run/postgresql/ssl_args"
: > "${SSL_ARGS_FILE}"
ssl_choice="$(bashio::config 'ssl')"
if [[ "${ssl_choice}" != "off" ]]; then
  certfile="$(bashio::config 'certfile')"
  keyfile="$(bashio::config 'keyfile')"
  ssl_ok=true
  for f in "${certfile}" "${keyfile}"; do
    case "${f}" in
      ''|/*|*..*) bashio::log.fatal "The certificate and key names must be relative paths inside /ssl."; bashio::exit.nok ;;
    esac
    if [[ ! -r "/ssl/${f}" ]]; then ssl_ok=false; fi
  done
  if [[ "${ssl_ok}" == "true" ]]; then
    mkdir -p /run/postgresql-ssl
    cp "/ssl/${certfile}" /run/postgresql-ssl/server.crt
    cp "/ssl/${keyfile}" /run/postgresql-ssl/server.key
    chown -R postgres:postgres /run/postgresql-ssl
    chmod 644 /run/postgresql-ssl/server.crt
    chmod 600 /run/postgresql-ssl/server.key
    printf '%s' "-c ssl=on -c ssl_cert_file=/run/postgresql-ssl/server.crt -c ssl_key_file=/run/postgresql-ssl/server.key" > "${SSL_ARGS_FILE}"
    bashio::log.info "TLS is on, using /ssl/${certfile}."
  elif [[ "${ssl_choice}" == "on" ]]; then
    bashio::log.fatal "TLS is set to on but /ssl/${certfile} or /ssl/${keyfile} was not found."
    bashio::exit.nok
  else
    bashio::log.info "No certificate found in /ssl (looked for ${certfile} and ${keyfile}); TLS is off."
  fi
fi

first_run=""
if bashio::fs.file_exists "${PGDATA}/PG_VERSION"; then
  bashio::log.info "Existing PostgreSQL data directory found in ${PGDATA}."
else
  first_run="first-run"
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
fi

provision-postgres "${PGDATA}" "${first_run}"
bashio::log.info "PostgreSQL initialization complete."
