# Changelog

## 2.2.1-1

- Fix `icon.png`/`logo.png`: the rounded-square badge sat on an opaque white
  canvas (confirmed via pixel inspection: solid white corners), showing as a
  white box outside the badge's rounded corners in any UI with a non-white
  background. Flood-filled the background transparent from all four corners
  (not a blanket color-key) so the crown/arrow artwork itself is untouched.

## 2.2.1

- Upgrading from upstream version 2.2.0 -> 2.2.1

> Upstream v2.2.1: https://github.com/charlestephen/ratioreign/releases/tag/v2.2.1
>
> ### Added
>
> - Docker Hub overview (`docs/dockerhub.md`) with Docker and Docker Compose
>   instructions, synced to `docker.io/charlestephen/ratioreign` by the
>   Publish to Docker Hub workflow.
>
> ### Removed
>
> - The Slack notification workflow.
>
> ### Security
>
> - The auto-generated admin password is no longer written to the log
>   (clear-text logging of sensitive information). The startup warning now
>   names the config file; read `auth.password` from it, then change it in
>   the web UI. If you started a version that logged it, treat that password
>   as exposed and change it, and clear or rotate any logs that kept it.

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
