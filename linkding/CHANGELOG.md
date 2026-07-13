# Changelog

## 1.0.2

- Store bookmarks + config in the add-on's dedicated **`addon_config`** dir
  (mounted at `/config`; host `/addon_configs/<slug>_linkding`, reachable via the
  Samba/SSH add-ons) instead of the opaque `/data` volume, keeping the bookmark
  DB out of HA-config backups.

## 1.0.1

- Fix `attempt to write a readonly database` (HTTP 500 on every request). uWSGI
  drops to `www-data`, but the add-on's `/data` symlink defeated the upstream
  image's own `chown -R www-data: /etc/linkding/data` (chown `-R` doesn't follow
  a symlink argument), leaving the SQLite DBs root-owned. The data volume is now
  chowned to `www-data` in cont-init, and the linkding stack runs as `www-data`
  via `s6-setuidgid` so files created later stay writable. (The earlier
  `USER root` change was a no-op: the upstream image already runs as root.)
- Fix add-on store warning `expected str for dictionary value @
  data['network']['9090/tcp']`: the `network:` entry in `translations/en.yaml`
  maps the port to a string, not a `name:` sub-mapping.

## 1.0.0

- Initial release: Linkding bookmark manager on `ghcr.io/sissbruecker/linkding:latest-alpine`,
  wrapped with the HA add-on framework (s6-overlay grafted from the HA Alpine base).
- SQLite by default, persisted to the add-on's `/data` volume.
- Config UI: `superuser_name`/`superuser_password`, `disable_background_tasks`,
  and an `env_vars` list that injects arbitrary environment variables at startup.
- Ingress (HA sidebar) + direct port 9090.
- Dual-arch (amd64 + aarch64); config read via the bundled python3, no RUN steps.
- Run as root so s6-overlay initialises and can write the /data volume (the linkding image defaults to USER www-data).
