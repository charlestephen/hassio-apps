# Home Assistant App: UniFi Blocklist Chunker

Fetches any number of upstream IP and DNS blocklists, merges and deduplicates
them, and re-serves them as plain-text chunks sized for the UniFi Network
Controller (which rejects oversized external blocklists). This app wraps
[unifi-blocklist-chunker](https://github.com/charlestephen/unifi-blocklist-chunker)
`1.2.0`.

## How it works

1. Every URL in **Blocklist URLs** is fetched on startup and then periodically
   (**Refresh interval**). Optional category tag: `category:https://…`
   (untagged → `default`). Formats: **txt**, **JSON**, **YAML**, **TOML**.
   Line comments (`#`, `//`, `--`, `;`) are stripped; CIDRs stay intact.
2. Entries are normalized and classified as **domains**, **IPv4**, or
   **IPv6** (IPv4-mapped IPv6 like `::ffff:a.b.c.d` counts as IPv4).
3. Deduplicated entries join the global **all** feed and exactly **one**
   category (first source wins). Each feed is sorted and split into domain /
   IPv4 / IPv6 chunks of at most **Chunk size** entries.
4. A failed source is skipped; other sources still apply. A refresh that yields
   zero entries keeps the previous snapshot.

## Quick start

1. Install the app and open **Configuration**.
2. Replace the example `blocklist_urls` with your real list URLs (optionally
   `threat:https://…` style category tags).
3. Set `admin_token` to a long random secret (recommended for `/manage`).
4. Optionally add domains/IPs/CIDRs under `exclusions` (exact-match seed).
5. Start the app. Open `http://<home-assistant-host>:8080/` and paste each
   chunk URL into UniFi's external blocklist fields (all-feed and/or
   per-category).

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `blocklist_urls` | example placeholders | Upstream list URLs. Optional `category:https://…` tag. **Required.** |
| `chunk_size` | `100000` | Max entries per chunk. UniFi commonly caps around 100000. |
| `refresh_interval` | `6h` | Go duration between re-fetches. `0` = manual only. |
| `base_url` | *(empty)* | Public origin for chunk links. Leave empty behind Traefik (`X-Forwarded-*`). |
| `admin_token` | *(empty)* | Secret for `/manage` and exclusion API. Empty → admin endpoints `503`. |
| `exclusions` | `[]` | Seed exclusions (exact match). Merged add-only into `/data`; `/manage` entries survive. |
| `exclusions_urls` | `[]` | Remote exclusion list URLs. Re-fetched on every refresh; unioned with persistent exclusions. |

### Example

```yaml
blocklist_urls:
  - "threat:https://example.com/threat.txt"
  - "dns-blocklisting:https://raw.githubusercontent.com/example/lists/main/dns.txt"
  - "https://example.com/ip-blocklist.json"
chunk_size: 100000
refresh_interval: "6h"
base_url: ""
admin_token: "replace-with-a-long-random-secret"
exclusions:
  - "legit.example.com"
  - "203.0.113.10"
exclusions_urls:
  - "https://lists.example.com/excluded.txt"
```

## Endpoints

| Path | Purpose |
| --- | --- |
| `/` | Index of **all** chunk URLs, then per-category URLs |
| `/lists/dns-<n>.txt` | Global domain chunk |
| `/lists/ipv4-<n>.txt` | Global IPv4/CIDR chunk |
| `/lists/ipv6-<n>.txt` | Global IPv6/CIDR chunk |
| `/lists/<category>/dns-<n>.txt` | Category domain chunk (also `ipv4` / `ipv6`) |
| `/stats` | JSON counts + URLs + `categories` |
| `/search?q=` | Look up a domain/IP (public); includes `category` |
| `/manage` | Browser UI to search / remove / restore (needs `admin_token`) |
| `/healthz` | Liveness |
| `/exclusions` | Exclusion API (admin auth) |

## Search and exclusions

Exclusions never edit upstream data. Matching is **exact only** (search may
still report a broader `covered_by` parent domain or containing CIDR). Changes
via `/manage` or the API apply immediately, persist on `/data`, and are
re-applied on every refresh. Remote `exclusions_urls` are re-fetched each
refresh.

Browser auth for `/manage`: HTTP Basic — **any username**, password =
`admin_token`. API clients may send `Authorization: Bearer <token>`.

## Reverse proxy

Point Traefik (or similar) at host port **8080**. Leave `base_url` empty so
`/` emits `https://…` links from forwarding headers.

- `https://<public-host>/` — UniFi chunk index  
- `https://<public-host>/manage` — search & exclude UI  

## Notes

- Re-check `/` after large list changes; update UniFi if the set of chunk URLs
  changed.
- Upstream docs:
  [unifi-blocklist-chunker](https://github.com/charlestephen/unifi-blocklist-chunker).
