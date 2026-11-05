# Home Assistant App: DNS/IP List Chunker

Fetches any number of upstream IP and DNS blocklists (plus optional inline
custom lists), merges and deduplicates them, and re-serves them as plain-text
chunks sized for DNS servers and routers that reject oversized external
blocklists or allowlists. This app wraps
[dns-ip-list-chunker](https://github.com/charlestephen/dns-ip-list-chunker)
`1.4.0`.

Formerly **UniFi Blocklist Chunker** — same engine, generic naming. Works with
UniFi, Technitium, Pi-hole-style subscribers, NextDNS-compatible URL feeds, or
any device that accepts a plain-text URL of domains / IPs / CIDRs.

## How it works

1. Every URL in **Blocklist URLs** is fetched on startup and then periodically
   (**Refresh interval**). Optional category tag: `category:https://…`
   (untagged → `default`). You can also add **Custom blocklists** (named
   inline textareas). Formats: **txt**, **hosts**, **adblock**, **JSON**,
   **YAML**, **TOML**, **CSV**. Line comments (`#`, `//`, `--`, `;`) strip only
   at line start or after whitespace so labels like `xn--…` and
   `o--o.example` survive; CIDRs keep a single `/`.
2. Entries are normalized (lowercased, wildcards/schemes/hosts prefixes
   stripped, CIDRs masked) and classified as **domains**, **IPv4**, or
   **IPv6** (IPv4-mapped IPv6 like `::ffff:a.b.c.d` counts as IPv4).
3. Deduplicated entries join the global **all** feed and exactly **one**
   category (first source wins). Each feed is sorted and split into domain /
   IPv4 / IPv6 chunks of at most **Chunk size** entries.
4. Pure **Exclusion / allow lists** (no Output allowlist) and **Exclusion list
   URLs** withhold matching entries from block feeds. Lists with **Output
   allowlist** publish `/allowlists/<category>/…`; those entries stay in the
   blocklist unless **Allowlist also excludes** is enabled. `/manage` changes
   persist on `/data` and re-apply every refresh.
5. A failed source is skipped; other sources still apply. A refresh that yields
   zero entries keeps the previous snapshot.

## Quick start

1. Install the app and open **Configuration**.
2. Replace the example `blocklist_urls` with your real list URLs (optionally
   `threat:https://…` style category tags), and/or add **Custom blocklists**
   with multiline `entries`.
3. Set `admin_token` to a long random secret (recommended for `/manage`).
4. Optionally add **Exclusion / allow lists** (paste domains/IPs/CIDRs one per
   line; enable **Output allowlist** when you want subscribe-able allowlist
   feeds) and/or remote `exclusions_urls`.
5. Start the app. Open `http://<home-assistant-host>:8080/` and paste each
   chunk URL into your DNS server or router (block feeds under `/lists/…`,
   allowlist feeds under `/allowlists/…`).

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `blocklist_urls` | example placeholders | Upstream list URLs. Optional `category:https://…` tag. Required unless you use custom blocklists. |
| `custom_blocklists` | `[]` | Named inline block lists: `name`, optional `category`, multiline `entries` (domains / IPs / CIDRs). |
| `chunk_size` | `100000` | Max entries per chunk. Many controllers (including UniFi) cap around 100000. |
| `refresh_interval` | `6h` | Go duration between re-fetches. `0` = manual only (`POST /refresh`). |
| `base_url` | *(empty)* | Public origin for chunk links. Leave empty behind Traefik (`X-Forwarded-*`). |
| `admin_token` | *(empty)* | Secret for `/manage` and exclusion API. Empty → admin endpoints `503`. |
| `exclusions_urls` | `[]` | Remote exclusion list URLs. Re-fetched on every refresh; unioned with persistent `/manage` exclusions and inline exclusion lists. |
| `exclusion_lists` | `[]` | Named inline exclude/allow lists: `name`, optional `category`, multiline `entries`, optional `output_allowlist` (publish `/allowlists/<category>/…`). |
| `allowlist_also_excludes` | `false` | When `true`, Output allowlist entries are also stripped from exported block feeds. Leave off to apply allow feeds only to some clients. |

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

## Endpoints

| Path | Purpose |
| --- | --- |
| `/` | Index of **all** block chunk URLs, then per-category block URLs, then allowlists |
| `/lists/dns-<n>.txt` | Global domain chunk |
| `/lists/ipv4-<n>.txt` | Global IPv4/CIDR chunk |
| `/lists/ipv6-<n>.txt` | Global IPv6/CIDR chunk |
| `/lists/<category>/dns-<n>.txt` | Category domain chunk (also `ipv4` / `ipv6`) |
| `/allowlists/<category>/dns-<n>.txt` | Allowlist domain chunk when `output_allowlist` is enabled (also `ipv4` / `ipv6`) |
| `/stats` | JSON counts + URLs + `categories` + `allowlists` |
| `/search?q=` | Look up a domain/IP (public); includes `category` |
| `/manage` | Browser UI to search / remove / restore (needs `admin_token`) |
| `/healthz` | Liveness |
| `/exclusions` | Exclusion API (admin auth) |
| `POST /refresh` | Trigger an immediate re-fetch |

## Search and exclusions

Exclusions never edit upstream data. Matching is **exact only** (search may
still report a broader `covered_by` parent domain or containing CIDR). Changes
via `/manage` or the API apply immediately, persist on `/data`, and are
re-applied on every refresh. Remote `exclusions_urls` and inline
`exclusion_lists` are unioned with that persistent store each refresh.

When **Output allowlist** is enabled, those entries are published as chunked
allowlist URLs under `/allowlists/<category>/…`. They are stripped from block
feeds only if **Allowlist also excludes** is on (default off).

Browser auth for `/manage`: HTTP Basic — **any username**, password =
`admin_token`. API clients may send `Authorization: Bearer <token>`.

## Reverse proxy

Point Traefik (or similar) at host port **8080**. Leave `base_url` empty so
`/` emits `https://…` links from forwarding headers.

- `https://<public-host>/` — chunk URL index for your DNS/router
- `https://<public-host>/manage` — search & exclude UI
- `https://<public-host>/stats` — JSON counts

## Notes

- Re-check `/` after large list changes; update your DNS/router if the set of
  chunk URLs changed.
- Provide at least one `blocklist_urls` entry **or** one non-empty
  `custom_blocklists` entry, or the app will refuse to start.
- Upstream docs:
  [dns-ip-list-chunker](https://github.com/charlestephen/dns-ip-list-chunker).
