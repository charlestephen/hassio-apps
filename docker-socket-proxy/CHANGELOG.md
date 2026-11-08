# Changelog

## 0.5.0

- First Home Assistant app release wrapping
  [Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)
  `v0.5.0`. Thin wrapper: options → `0`/`1` env toggles, then `exec` upstream
  `docker-entrypoint.sh`. Upstream tracked via `upstream_repo` + Docker Hub
  image gate.

> Upstream v0.5.0: https://github.com/Tecnativa/docker-socket-proxy/releases/tag/v0.5.0
