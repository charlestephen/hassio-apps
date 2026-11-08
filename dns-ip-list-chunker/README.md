# Home Assistant App: DNS/IP List Chunker

[![Build][build-shield]][build]
[![Release][release-shield]][release]
[![Open your Home Assistant instance and show the dashboard of an app.][ha-badge]][ha-link]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Fetches any number of upstream IP and DNS blocklists (plus optional inline
custom lists), merges and deduplicates them, and re-serves them as plain-text
chunks sized for DNS servers and routers that reject oversized external
blocklists or allowlists. Powered by
[charlestephen/dns-ip-list-chunker][upstream] `1.4.0`.

Formerly **UniFi Blocklist Chunker** — same engine, generic naming. Paste list
URLs (and/or custom textareas) in the config UI, open `/` for chunk links to
paste into UniFi, Technitium, or any URL-based DNS/router blocklist or
allowlist field, and use `/manage` (behind a reverse proxy) to search and
exclude entries on the fly.

## How it works

1. Every URL in **Blocklist URLs** is fetched on startup and then periodically
   (**Refresh interval**). Optional category tags: `category:https://…`
   (untagged → `default`). **Custom blocklists** add named inline sources.
   Formats: **txt** (plain, hosts, adblock), **JSON**, **YAML**, **TOML**,
   **CSV**. Line comments (`#`, `//`, `--`, `;`) strip only at line start or
   after whitespace so `xn--…` / `o--o.example` survive; CIDRs like
   `10.0.0.0/8` are preserved.
2. Entries are normalized (lowercased, wildcards/schemes/hosts prefixes
   stripped, CIDRs masked) and classified as **domains**, **IPv4**, or
   **IPv6** (IPv4-mapped IPv6 addresses like `::ffff:a.b.c.d` count as IPv4).
3. Entries are deduplicated across all sources. Each unique entry belongs to
   **one** category (first source wins) and also appears in the global **all**
   feed. Feeds are sorted and split into domain / IPv4 / IPv6 chunks of at most
   **Chunk size** entries.
4. **Exclusion / allow lists** without **Output allowlist**, plus **Exclusion
   list URLs** and `/manage`, withhold matches from block feeds. With **Output
   allowlist** enabled, entries publish `/allowlists/<category>/…` and stay in
   the blocklist unless **Allowlist also excludes** is on (so allow feeds can
   target only some clients). `/manage` exclusions persist on `/data`.
5. A failed source never takes the service down: other sources still apply,
   and a refresh yielding zero entries keeps the previous snapshot.

## Endpoints

| Endpoint | Description |
| --- | --- |
| `GET /` | Plain-text index of **all** block chunk URLs, then per-category, then allowlists |
| `GET /lists/dns-<n>.txt` | Global domain chunk `n` (1-based) |
| `GET /lists/ipv4-<n>.txt` | Global IPv4/CIDR chunk `n` |
| `GET /lists/ipv6-<n>.txt` | Global IPv6/CIDR chunk `n` |
| `GET /lists/<category>/dns-<n>.txt` | Category domain chunk (same for `ipv4` / `ipv6`) |
| `GET /allowlists/<category>/dns-<n>.txt` | Allowlist chunk when `output_allowlist` is enabled |
| `GET /stats` | JSON: global counts/URLs plus `categories` and `allowlists` |
| `GET /healthz` | `ok` once any snapshot is loaded, else 503 |
| `POST /refresh` | Trigger an immediate re-fetch |
| `GET /search?q=<entry>` | Lookup; includes `category` when known |
| `GET /manage` | Browser UI for search/remove/restore (needs **Admin token**) |
| `GET` / `POST` / `DELETE /exclusions` | Exclusion API (admin auth) |

Chunk URLs carry no secrets and are safe to paste into DNS/router external
list fields; one URL per chunk is needed, and the number of URLs changes as
upstream lists grow or shrink.

## Search and exclusions

Exclusions are layered over the upstream lists — upstream data is never
edited. Matching is **exact only**: excluding `example.com` does not affect
`sub.example.com`, and excluding `1.2.3.4` does not affect a served
`1.2.0.0/16` (search reports that broader entry as `covered_by` so the effect
is visible before acting). Excluding an entry that no upstream list currently
contains is allowed and blocks it if a source adds it later.

Exclusions apply immediately (chunks are rebuilt without a refetch), are
re-applied on every refresh, and are persisted on the app's `/data` volume so
they survive restarts. Restoring an entry re-serves it immediately if an
upstream list still contains it.

**Admin token** gates `/manage` and the exclusion API (Bearer token or HTTP
Basic password — any username). When unset, those endpoints return `503`
(fail-closed). `/search`, chunk URLs, and `/stats` remain public.

Use **Exclusion / allow lists** for named multiline fill boxes (and optional
published allowlist feeds). Optional **Exclusion list URLs** are re-fetched
each refresh and unioned with the persistent `/manage` file.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `blocklist_urls` | example placeholders | Upstream list URLs (txt/JSON/YAML/TOML/CSV). Optional `category:https://…` tag. Required unless custom blocklists are set. |
| `custom_blocklists` | `[]` | Named inline block lists (`name`, optional `category`, multiline `entries`). |
| `chunk_size` | `100000` | Max entries per served chunk. Many controllers cap around 100000. |
| `refresh_interval` | `6h` | Go duration between re-fetches (`30m`, `6h`, …). `0` disables periodic refresh. |
| `base_url` | *(empty)* | Public origin for generated chunk links (e.g. `https://lists.example.com`). Leave empty behind Traefik so `X-Forwarded-*` headers are used. |
| `admin_token` | *(empty)* | Secret for `/manage` and exclusion API. Empty disables admin endpoints. |
| `exclusions_urls` | `[]` | Remote exclusion list URLs (same formats as blocklists). Re-fetched each refresh. |
| `exclusion_lists` | `[]` | Named inline exclude/allow lists; set `output_allowlist: true` to publish `/allowlists/<category>/…`. |
| `allowlist_also_excludes` | `false` | When `true`, Output allowlist entries are also stripped from exported block feeds. |

### Example

```yaml
blocklist_urls:
  - "threat:https://example.com/threat.txt"
  - "dns-blocklisting:https://raw.githubusercontent.com/example/lists/main/dns.txt"
  - "https://example.com/ip-blocklist.json"
custom_blocklists:
  - name: corp-extra
    category: custom
    entries: |
      ads.example.com
      203.0.113.0/24
chunk_size: 100000
refresh_interval: "6h"
base_url: ""
admin_token: "replace-with-a-long-random-secret"
exclusions_urls:
  - "https://lists.example.com/excluded.txt"
exclusion_lists:
  - name: family-allow
    category: allow-family
    output_allowlist: true
    entries: |
      school.edu
      10.0.0.0/8
allowlist_also_excludes: false
```

Then:

1. Start the app.
2. Open `http://<home-assistant-host>:8080/` (or your reverse-proxy URL) and
   copy **all**-feed and/or per-category `dns-` / `ipv4-` / `ipv6-` chunk
   links into your DNS/router blocklist fields (one URL per field). Copy
   `/allowlists/…` links into allowlist fields when configured.
3. Optionally open `/manage` (Basic auth: any username, password =
   `admin_token`) to search and remove false positives on the fly.

## Reverse proxy

Behind Traefik (or any TLS-terminating proxy), publish host port **8080** and
leave **Public base URL** empty so generated links pick up
`X-Forwarded-Proto` / `X-Forwarded-Host` / `X-Forwarded-Prefix`.

- `https://<public-host>/` — chunk URL index
- `https://<public-host>/manage` — search & exclude UI
- `https://<public-host>/stats` — JSON counts

## Notes

- A failed upstream URL is skipped; other sources still apply.
- Re-check `/` after large list changes — chunk count can grow or shrink; update
  your DNS/router if the set of URLs changed.
- Full upstream reference:
  [dns-ip-list-chunker](https://github.com/charlestephen/dns-ip-list-chunker).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v1.4.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/dns-ip-list-chunker
[upstream]: https://github.com/charlestephen/dns-ip-list-chunker
[ha-badge]: https://my.home-assistant.io/badges/supervisor_addon.svg
[ha-link]: https://my.home-assistant.io/redirect/supervisor_addon/?addon=dns_ip_list_chunker&repository_url=https%3A%2F%2Fgithub.com%2Fcharlestephen%2Fhassio-apps

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
