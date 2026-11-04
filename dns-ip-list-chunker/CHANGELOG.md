# Changelog

## 1.3.0

- Rename app to **DNS/IP List Chunker** (`dns-ip-list-chunker`); wraps upstream
  `dns-ip-list-chunker` `1.3.0` (track-upstream via `upstream_repo`).
- Fix comment stripping so domains with `--` / mid-token `//` are kept.
- CSV upstream lists; custom inline blocklists and categorized exclusion /
  allowlist textareas (`custom_blocklists`, `exclusion_lists`) via `LISTS_FILE`.
- Optional published allowlist feeds when `output_allowlist` is enabled.
- Docs framed for any DNS server / router that accepts blocklists or allowlists
  (not UniFi-specific).

> Upstream v1.3.0: https://github.com/charlestephen/dns-ip-list-chunker/releases/tag/v1.3.0

## 1.2.1

- (Previously published as UniFi Blocklist Chunker) docs, schema, icon.

## 1.2.0

- Source categories and dual all/category feeds.

## 1.1.0

- `exclusions_urls` wiring.

## 1.0.0

- Initial Home Assistant app.
