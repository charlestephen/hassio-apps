# Home Assistant App: UniFi Blocklist Chunker

Wraps [unifi-blocklist-chunker](https://github.com/charlestephen/unifi-blocklist-chunker)
`0.1.0`: fetch any number of upstream DNS/IP blocklists, merge and deduplicate
them, and re-serve **domain**, **IPv4**, and **IPv6** plain-text chunks sized
for the UniFi Network Controller.

## Quick start

1. Install the app and open **Configuration**.
2. Replace the example `blocklist_urls` with your real list URLs (one per line
   in the UI).
3. Set `admin_token` to a long random secret if you want the management UI /
   exclusion API (recommended).
4. Optionally paste domains/IPs/CIDRs into `exclusions` to seed removals
   (exact-match only).
5. Start the app. Open `http://<home-assistant-host>:8080/` for the chunk URL
   index and paste each URL into UniFi's external blocklist fields.

## Configuration

| Option | Default | Maps to | Description |
| --- | --- | --- | --- |
| `blocklist_urls` | example.com placeholders | `BLOCKLIST_URLS` | Upstream list URLs (txt/JSON/YAML/TOML). Required. |
| `chunk_size` | `100000` | `CHUNK_SIZE` | Max entries per chunk file. |
| `refresh_interval` | `6h` | `REFRESH_INTERVAL` | Go duration between re-fetches (`0` = manual only). |
| `base_url` | *(empty)* | `BASE_URL` | Public origin for generated chunk links. Leave empty behind Traefik so `X-Forwarded-*` headers are used. |
| `admin_token` | *(empty)* | `ADMIN_TOKEN` | Password for `/manage` and exclusion API. Empty disables those endpoints (`503`). |
| `exclusions` | `[]` | seed → `EXCLUSIONS_FILE` | Domains / IPs / CIDRs to exclude. Merged add-only into `/data/exclusions.json` on every start; does not wipe entries added via `/manage`. |

Exclusions are persisted on the app's `/data` volume. Full environment-variable
reference: upstream [README](https://github.com/charlestephen/unifi-blocklist-chunker#configuration-environment).

## Endpoints

| Path | Purpose |
| --- | --- |
| `/` | Plain-text index of all chunk URLs (paste into UniFi) |
| `/lists/dns-<n>.txt` | Domain chunk |
| `/lists/ipv4-<n>.txt` | IPv4/CIDR chunk |
| `/lists/ipv6-<n>.txt` | IPv6/CIDR chunk |
| `/stats` | JSON counts + URLs |
| `/search?q=` | Look up a domain/IP (public) |
| `/manage` | Browser UI to search / remove / restore (needs `admin_token`) |
| `/healthz` | Liveness |

## Management UI behind a reverse proxy

Point Traefik (or any TLS-terminating proxy) at the published host port
(default **8080**). Leave `base_url` empty so `/` emits `https://…` chunk
links from `X-Forwarded-Proto` / `X-Forwarded-Host`.

Then open:

- `https://<public-host>/` — chunk URL index for UniFi
- `https://<public-host>/manage` — interactive search & exclude UI

Browser auth for `/manage` is HTTP Basic: **any username**, password =
`admin_token`. API clients can instead send `Authorization: Bearer <token>`.

Removals are exact-match exclusions: they apply immediately, survive
refreshes and app restarts, and never edit upstream lists. Search may report
a broader `covered_by` entry (parent domain / containing CIDR) for context,
but remove only affects the exact entry you exclude.

## Notes

- Upstream image is tracked automatically via `upstream_repo` /
  `upstream_version.txt` (and Renovate on the Dockerfile pin).
- A failed upstream URL is skipped; other sources still apply.
- Chunk count grows and shrinks with unique-entry count vs `chunk_size` —
  re-check `/` after large list changes and update UniFi if needed.
