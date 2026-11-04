# Changelog

## 2.2.0

- Track upstream RatioReign `2.2.0` (HTTP Basic Auth on by default).
- Seed `auth.enabled` / `auth.username` / `auth.password` from HA options;
  empty password lets upstream generate and log one.
- App icon/logo; expanded DOCS (auth, data layout, qBittorrent notes).

> Upstream v2.2.0: https://github.com/charlestephen/ratioreign/releases/tag/v2.2.0

## 2.1.0

- First Home Assistant app release wrapping upstream RatioReign `2.1.0`.
- Thin image: official `ghcr.io/charlestephen/ratioreign` + HA options
  wrapper that execs the upstream binary.
- Persist config/torrents/state on `/data`; seed starter `config.yaml` once.
- track-upstream via `upstream_repo` + Docker Hub image gate.

> Upstream v2.1.0: https://github.com/charlestephen/ratioreign/releases/tag/v2.1.0
