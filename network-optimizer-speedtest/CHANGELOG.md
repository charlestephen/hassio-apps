# Changelog

## 2.10.7

- First Home Assistant app release wrapping upstream Speed Test `2.10.7`
  (`ghcr.io/ozark-connect/speedtest`).
- Thin image: official `/docker-entrypoint.sh` preserved; HA options → env.
- Publishes host **3005** → container 3000; exposes full host / proxy env so
  result POSTs and canonical redirects follow the assigned URL.
- Upstream brand icon; track-upstream via the NetworkOptimizer GitHub releases.

> Upstream v2.10.7: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.7
