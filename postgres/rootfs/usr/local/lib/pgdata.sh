# shellcheck shell=bash
# Resolves PGDATA from the data_directory option. Sourced by init and run.

resolve_pgdata() {
  local dir
  dir="$(bashio::config 'data_directory')"
  if ! bashio::var.has_value "${dir}"; then
    PGDATA="/data/postgres"
    return
  fi
  dir="${dir%/}"
  case "${dir}" in
    *..*) bashio::log.fatal "data_directory must not contain '..' (got ${dir})."; bashio::exit.nok ;;
    /media/?*) ;;
    *) bashio::log.fatal "data_directory must be inside /media (got ${dir})."; bashio::exit.nok ;;
  esac
  PGDATA="${dir}"
}
