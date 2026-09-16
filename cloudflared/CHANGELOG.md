# Changelog

## 2026.9.1

- Upgrade cloudflared 2026.7.1 -> 2026.9.1.

## 2026.7.1-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-cloudflared-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 2026.7.1

- Update cloudflared to 2026.7.1.

## 2026.6.1.b

- Icon: replaced the placeholder with the Cloudflare cloud and two tunnel bars.

## 2026.6.1.a

- Initial release: dual-replica Cloudflare Tunnel (HA) on the stock
  `cloudflare/cloudflared` image (pinned `2026.6.1`).
- Two connector replicas (`cloudflared0`, `cloudflared1`) of one remotely-managed
  tunnel; Cloudflare-native load-balancing/failover; automatic nearest +
  second-nearest edge selection.
- Prometheus metrics per replica (`:36400` / `:36401`).
- Token passed via `TUNNEL_TOKEN` env (kept out of process args).
- Added default icon.png / logo.png.
- cloudflared self-updater disabled (`--no-autoupdate`); image version managed by
  Renovate + Forgejo CI.
