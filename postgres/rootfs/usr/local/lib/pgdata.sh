# shellcheck shell=bash
# Resolves PGBASE and PGDATA from the data_directory option. Sourced by init and
# run. The cluster lives in a "postgres" subfolder, because a freshly formatted
# drive holds a lost+found folder and initdb needs an empty directory.

resolve_pgdata() {
  local dir
  PGBASE=""
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
  PGBASE="${dir}"
  PGDATA="${dir}/postgres"
}
