# Changelog

## 0.5.0-2

- Silence HAProxy 3.4 startup noise from the Tecnativa template: explicit
  `uid 0` / `chroot /`, non-zero `docker-events` timeouts (`connect 10s`,
  `server 24h`), drop unused empty `server-state-file`, and
  `hard-stop-after 5s` so an open `/events` stream cannot hang soft-stop.
- Overlay keeps upstream `docker-entrypoint.sh` (template → `/tmp/haproxy.cfg`).

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

