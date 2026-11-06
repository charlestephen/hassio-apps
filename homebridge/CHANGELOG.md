# Changelog

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
