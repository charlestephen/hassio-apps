# Changelog

## 0.5.0-1

- Do not publish `2375` on the host by default (`2375/tcp: null` — hassio
  network only).
- Default `containers` / `images` / `info` / `networks` / `volumes` to off
  (opt-in); keep upstream-safe `ping` / `events` / `version` on.
- Pin base image by digest; drop `EXPOSE 2375/tcp`.
- Docs: `DOCKER_HOST` via Supervisor DNS only.

## 0.5.0

- First Home Assistant app release wrapping
  [Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)
  `v0.5.0`. Thin wrapper: options → `0`/`1` env toggles, then `exec` upstream
  `docker-entrypoint.sh`. Upstream tracked via `upstream_repo` + Docker Hub
  image gate.

> Upstream v0.5.0: https://github.com/Tecnativa/docker-socket-proxy/releases/tag/v0.5.0

