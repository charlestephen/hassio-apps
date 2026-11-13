# Changelog

## 1.6.0

- Wrap upstream `dns-ip-list-chunker` `1.6.0`.
- AdGuard syntax: `$important` blocks, other `$` modifiers drop the rule, cosmetic
  rules (`site##.ad`) are ignored instead of blocking the site, and `@@` allow rules
  count in **Exclusion / allow lists** and **Exclusion list URLs**.
- `1.2.3.4`, `1.2.3.4/32` and `::ffff:1.2.3.4` deduplicate to one entry.
- **Exclusion / allow lists** accept a `url` (any supported format) with or without
  inline `entries`.
- **Exclusion list URLs** and `/manage` entries are published as the `remote` and
  `manual` allowlists, and all allowlists are merged at `/allowlists/dns-<n>.txt`
  (also `ipv4` / `ipv6`).

## 1.5.0

- Wrap upstream `dns-ip-list-chunker` `1.5.0`: refreshes use roughly a sixth of the
  CPU and a fraction of the memory, and a refresh where no list changed upstream does no
  work at all (conditional requests). Served lists are identical to 1.4.0.
- `POST /refresh` answers `409` while a refresh is already running; chunk responses now
  carry content-hash `ETag`s and honour `If-None-Match`.

## 1.4.0-4

- Default host port is now `8180` (was `8080`, which Traefik, Error Pages and Ultimate CA
  Manager also use, so the app could not start next to them). The port is still changeable
  under **Network**; the container still listens on `8080`.
- Add a Supervisor watchdog on `/healthz` so a hung process is restarted.

## 1.4.0-3

- Rebuild as Docker schema2 manifests (`oci-mediatypes=false`). `--provenance=false`
  alone still published OCI image manifests that GHCR returns as 404 to classic
  Docker Accept headers; Supervisor install stayed "won't download".

## 1.4.0-2

- Rebuild without Buildx provenance/SBOM attestations so GHCR tags are plain
  image manifests again. HA Supervisor could not resolve the OCI index
  (`unknown/unknown` attestation) and failed to download the add-on image.

## 1.4.0-1

- Slim image: drop `hassio-addons/base` + s6/bashio for Alpine 3.24 thin wrap
  (jq maps options → env/lists, then exec upstream binary).

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
