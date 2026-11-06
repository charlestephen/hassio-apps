# Changelog

## 3.7.17-1

- Fix wrong default config directory. `3.7.17` mapped dynamic/custom paths to
  `/config/traefik/`, which is the app’s own config mount — not the Home
  Assistant configuration directory. Defaults are now `/homeassistant/traefik/`
  (`homeassistant_config`), i.e. `traefik/` next to `configuration.yaml` on
  disk. If you already put files under `/config/traefik/`, move them to
  `homeassistant/traefik/` (or set `dynamic_configuration_path` /
  `custom_config.config_file` explicitly).

## 3.7.17

- First release in this repository wrapping Traefik `v3.7.17` (binary from
  GitHub Releases on the HA base image).
- File-based dynamic config, optional Let's Encrypt, custom static config
  override, Ingress dashboard via nginx.
- Version tracked via `upstream_repo: traefik/traefik`.

> Upstream v3.7.17: https://github.com/traefik/traefik/releases/tag/v3.7.17
