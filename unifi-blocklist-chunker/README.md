# Home Assistant App: UniFi Blocklist Chunker

[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Fetches any number of upstream IP and DNS blocklists, merges and deduplicates
them, and re-serves them as plain-text chunks sized for the UniFi Network
Controller (which rejects oversized external blocklists). Powered by
[charlestephen/unifi-blocklist-chunker][upstream] `1.0.0`.

Paste list URLs in the config UI, open `/` for chunk links to paste into UniFi,
and use `/manage` (behind a reverse proxy) to search and exclude entries on the
fly.

## How it works

1. Every URL in **Blocklist URLs** is fetched on startup and then periodically
   (**Refresh interval**). Formats are detected by file extension, content type,
   or content sniffing: **txt** (plain, hosts-file, and adblock-style lines),
   **JSON** (array of strings, or any object containing string arrays),
   **YAML**, and **TOML**.
2. Entries are normalized (lowercased, wildcards/schemes/hosts prefixes
   stripped, CIDRs masked) and classified as **domains**, **IPv4**, or
   **IPv6** (IPv4-mapped IPv6 addresses like `::ffff:a.b.c.d` count as IPv4).
3. Entries are deduplicated **across all source lists** per class, sorted, and
   split into separate domain / IPv4 / IPv6 chunk streams of at most
   **Chunk size** entries each. Domains sort by label from the TLD leftward
   (`cloudflare.com` before `google.com` before `mail.google.com`; `.com`
   before `.nyc`). IPv4 and IPv6 sort numerically (128-bit for IPv6, so
   `2006::1` before `2006:0:1::1` before `2006:1::1`; compressed forms like
   `2006:0::1` normalize to `2006::1`). Chunk count is purely a function of
   unique-entry count vs. chunk size — there are no fixed endpoints.
4. A failed source never takes the service down: other sources still apply,
   and a refresh yielding zero entries keeps the previous snapshot.

## Endpoints

| Endpoint | Description |
| --- | --- |
| `GET /` | Plain-text index of all chunk URLs (generated from the request's public origin) — paste these into UniFi |
| `GET /lists/dns-<n>.txt` | Domain chunk `n` (1-based), one entry per line |
| `GET /lists/ipv4-<n>.txt` | IPv4/CIDR chunk `n` (1-based), one entry per line |
| `GET /lists/ipv6-<n>.txt` | IPv6/CIDR chunk `n` (1-based), one entry per line |
| `GET /stats` | JSON: entry/chunk counts, source health, chunk URLs, exclusion counts |
| `GET /healthz` | `ok` once any snapshot is loaded, else 503 |
| `POST /refresh` | Trigger an immediate re-fetch |
| `GET /search?q=<entry>` | JSON: whether a domain/IP/CIDR is served, in which chunk, whether it is excluded, and any broader served entry covering it |
| `GET /manage` | Browser UI for search/remove/restore (needs **Admin token**) |
| `GET` / `POST` / `DELETE /exclusions` | Exclusion API (admin auth) |

Chunk URLs carry no secrets and are safe to paste into UniFi's external
blocklist fields; one URL per chunk is needed, and the number of URLs changes
as upstream lists grow or shrink.

## Search and exclusions

Exclusions are an allowlist layered over the upstream lists — upstream data
is never edited. Matching is **exact only**: excluding `example.com` does not
affect `sub.example.com`, and excluding `1.2.3.4` does not affect a served
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

You can seed exclusions from the config UI (**Seed exclusions**); they are
merged add-only into `/data/exclusions.json` on start and do not wipe entries
added later via `/manage`.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `blocklist_urls` | example placeholders | Upstream list URLs (txt/JSON/YAML/TOML). **Required.** |
| `chunk_size` | `100000` | Max entries per served chunk. UniFi commonly caps around 100000. |
| `refresh_interval` | `6h` | Go duration between re-fetches (`30m`, `6h`, …). `0` disables periodic refresh. |
| `base_url` | *(empty)* | Public origin for generated chunk links (e.g. `https://lists.example.com`). Leave empty behind Traefik so `X-Forwarded-*` headers are used. |
| `admin_token` | *(empty)* | Secret for `/manage` and exclusion API. Empty disables admin endpoints. |
| `exclusions` | `[]` | Domains / IPs / CIDRs to seed as exclusions (exact match). |

### Example

```yaml
blocklist_urls:
  - "https://raw.githubusercontent.com/example/lists/main/dns.txt"
  - "https://example.com/ip-blocklist.json"
chunk_size: 100000
refresh_interval: "6h"
base_url: ""
admin_token: "replace-with-a-long-random-secret"
exclusions:
  - "legit.example.com"
  - "203.0.113.10"
```

Then:

1. Start the app.
2. Open `http://<home-assistant-host>:8080/` (or your reverse-proxy URL) and
   copy every `dns-` / `ipv4-` / `ipv6-` chunk link into UniFi → Settings →
   Security → external blocklists (one URL per field).
3. Optionally open `/manage` (Basic auth: any username, password =
   `admin_token`) to search and remove false positives on the fly.

## Reverse proxy

Behind Traefik (or any TLS-terminating proxy), publish host port **8080** and
leave **Public base URL** empty so generated links pick up
`X-Forwarded-Proto` / `X-Forwarded-Host` / `X-Forwarded-Prefix`.

- `https://<public-host>/` — chunk URL index for UniFi  
- `https://<public-host>/manage` — search & exclude UI  
- `https://<public-host>/stats` — JSON counts  

## Notes

- A failed upstream URL is skipped; other sources still apply.
- Re-check `/` after large list changes — chunk count can grow or shrink; update
  UniFi if the set of URLs changed.
- Full upstream reference:
  [unifi-blocklist-chunker](https://github.com/charlestephen/unifi-blocklist-chunker).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v1.1.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/unifi-blocklist-chunker
[upstream]: https://github.com/charlestephen/unifi-blocklist-chunker
