# Changelog

## 1.2.1

- Document source categories, dual all/category feeds, and comment stripping
  in README and DOCS.
- Accept category-tagged blocklist entries in the config schema
  (`threat:https://…`); plain `url` validation rejected the tag prefix.
- UI translation copy for category-tagged blocklist URLs.

## 1.2.0

- Upgrading from upstream version 1.1.0 -> 1.2.0
- Source categories via `category:https://…` on blocklist URLs; global all
  feed plus `/lists/<category>/…` chunk URLs.
- Line-comment stripping (`#`, `//`, `--`, `;`) with CIDR-safe parsing.
- Search reports `category`; `/stats` includes a `categories` array.

> Upstream v1.2.0: https://github.com/charlestephen/unifi-blocklist-chunker/releases/tag/v1.2.0
>
> - Source categories: tag each BLOCKLIST_URLS entry as category:https://…
> - Dual feeds: global /lists/{dns,ipv4,ipv6}-N.txt plus per-category URLs
> - First-wins category assignment; comment stripping for txt/JSON/YAML/TOML

## 1.1.0

- Upgrading from upstream version 1.0.1 -> 1.1.0
- Wire `exclusions_urls` config into upstream `EXCLUSIONS_URLS`.

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
