# Changelog

## 2.1.0

- First Home Assistant app release wrapping upstream RatioReign `2.1.0`.
- Thin image: official `ghcr.io/charlestephen/ratioreign` + HA options
  wrapper that execs the upstream binary.
- Persist config/torrents/state on `/data`; seed starter `config.yaml` once.
- track-upstream via `upstream_repo` + Docker Hub image gate.

> Upstream v2.1.0: https://github.com/charlestephen/ratioreign/releases/tag/v2.1.0
