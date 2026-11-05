# Changelog

## 1.4.0

- Wrap upstream `dns-ip-list-chunker` `1.4.0`.
- New option **Allowlist also excludes** (`allowlist_also_excludes`, default
  `false` → `ALLOWLIST_ALSO_EXCLUDES`): when on, Output allowlist entries are
  also stripped from exported block feeds. Default keeps them in the blocklist
  so allow feeds can be applied only to some clients.
- README “Add to my Home Assistant” button points at this app + repository.

> Upstream v1.4.0: https://github.com/charlestephen/dns-ip-list-chunker/releases/tag/v1.4.0

## 1.3.1

- Expand README, DOCS, and UI translations to prior depth: how-it-works,
  endpoints (including `/allowlists/…`), exclusions semantics, reverse-proxy
  notes, and full configuration examples.
- Fix `output_allowlist` mapping: unset/`false` no longer coerced to `true`
  via jq `//`.

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
