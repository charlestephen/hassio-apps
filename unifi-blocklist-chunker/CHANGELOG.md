# Changelog

## 1.0.1

- Fix published image name: HA was pulling
  `hassio-addons-unifi_blocklist_chunker-{arch}` (slug underscores) but CI
  pushes `hassio-addons-unifi-blocklist-chunker-{arch}` (directory hyphens),
  which GHCR surfaced as 403/DENIED.

## 1.0.0

- First stable Home Assistant app release, wrapping upstream
  [unifi-blocklist-chunker](https://github.com/charlestephen/unifi-blocklist-chunker)
  `1.0.0`.
- Expanded README/DOCS with how-it-works, endpoints, exclusions semantics,
  reverse-proxy notes, and a configuration example.

## 0.1.0

- Initial Home Assistant app wrapping upstream `0.1.0`.
- Config UI for blocklist URLs, chunk size, refresh interval, public base URL,
  admin token, and seed exclusions.
- Persisted exclusions on `/data`; `/manage` UI documented for reverse-proxy
  use.
- AppArmor profile, upstream version tracking, and Renovate pin.
