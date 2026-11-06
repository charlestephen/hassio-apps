# Changelog

## 3.7.17

- First release in this repository wrapping Traefik `v3.7.17` (binary from
  GitHub Releases on the HA base image).
- File-based dynamic config, optional Let's Encrypt, custom static config
  override, Ingress dashboard via nginx.
- Dynamic/custom paths default to `/homeassistant/traefik/` (`homeassistant_config`
  mount — same HA config directory the upstream addon used as `/config`).
- Version tracked via `upstream_repo: traefik/traefik`.

> Upstream v3.7.17: https://github.com/traefik/traefik/releases/tag/v3.7.17
