# Changelog

## 2026-11-02-3

- Persist like upstream Docker: Supervisor `data` mounts at `/homebridge`
  (`map.path`). Drops the `/data/homebridge` bind-mount and `SYS_ADMIN`
  (fixes state reset when the bind did not stick across HA restarts).
- Migrates nested `homebridge/homebridge/` from the -1/-2 layout on start.

## 2026-11-02-2

- Mount `/ssl` and add **HTTPS certificate/key file** options so Config UI
  TLS can be set from `/ssl/...` before first boot (written into
  `config.json`).
- Fix mDNS: default `enable_avahi` to off and set `host_dbus: true`. With
  host networking, in-container Avahi collides with the host
  (“another mdns processor on the same host”); HAP should use host Avahi
  over D-Bus instead.

## 2026-11-02-1

- Fix start crash: upstream `VOLUME /homebridge` cannot be `rm`/`symlink`’d
  (`Device or resource busy`). Persist on HA at `/data/homebridge` and
  bind-mount that over upstream’s path (`SYS_ADMIN`; turn Protection mode
  off if Supervisor prompts).

## 2026-11-02

- First Home Assistant app release wrapping official
  [`homebridge/homebridge:2026-11-02`](https://github.com/homebridge/docker-homebridge).
- Host networking, `/data` → `/homebridge`, `exec /init`. Options: `tz`,
  `enable_avahi`, `env_vars`. Upstream tracked via dated stable tags.

> Upstream 2026-11-02: https://github.com/homebridge/docker-homebridge/releases
