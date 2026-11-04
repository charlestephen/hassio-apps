# Changelog

## 3.41.3

- First Home Assistant app release wrapping upstream Gluetun `v3.41.3`
  (`qmcgaw/gluetun`).
- Thin image: official entrypoint preserved; HA options → env →
  `exec /gluetun-entrypoint`.
- `/dev/net/tun` + `NET_ADMIN`; HTTP proxy / Shadowsocks / control ports
  published.
- track-upstream via `upstream_repo` + Docker Hub image gate
  (`qmcgaw/gluetun`).
- Gluetun dashboard icon; expanded DOCS (verify curls, WireGuard, persistence).

> Upstream v3.41.3: https://github.com/qdm12/gluetun/releases/tag/v3.41.3
