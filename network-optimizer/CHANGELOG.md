# Changelog

## 2.10.7-1

- Fix `UnauthorizedAccessException` on `/app/data/keys`: chown the real HA
  `/data/{data,ssh-keys,logs}` dirs for upstream’s `app` user. Upstream’s
  `chown -R /app/data` does not follow our persistence symlinks.

## 2.10.7

- First Home Assistant app release wrapping upstream Network Optimizer
  `2.10.7` (`ghcr.io/ozark-connect/network-optimizer`).
- Thin image: official `/entrypoint.sh` preserved; HA options → env.
- Host networking + `NET_RAW` for traceroute / path analysis (upstream
  compose parity).
- Full compose env surface, including `HOST_*` / `REVERSE_PROXIED_*` so
  assigned public URLs work (unlike the minimal LOOHP community add-on).
- Upstream brand icon/logo; track-upstream via GitHub releases.

> Upstream v2.10.7: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.7
