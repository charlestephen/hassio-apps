# Home Assistant App: RatioReign

Fetches nothing from the BitTorrent swarm — RatioReign only talks to your
private trackers with believable announce fingerprints and a climbing upload
counter. This app wraps
[charlestephen/ratioreign](https://github.com/charlestephen/ratioreign)
`2.1.0` and **execs the upstream binary** after mapping HA's `/data` volume
into the paths RatioReign expects.

## How it works

1. On first start the wrapper seeds `/data/config.yaml` from the HA options
   (listen address, upload rate bounds, client profile, …).
2. Torrents, archive, and resume state live under `/data` so they survive
   updates. Bundled client profiles stay in the image at `/app/profiles`.
3. Control returns to upstream: `ratioreign -config /app/config/config.yaml`
   (uid `1000`, same as the official image).
4. Use the **Web UI** (port 7070) for day-to-day config — RSS feeds,
   qBittorrent sync, exclusions, torrent table. The UI writes the same YAML.

## Quick start

1. Install **RatioReign** and start it.
2. Open `http://<home-assistant-host>:7070/`.
3. Set `clientProfile` (or enable qBittorrent sync so a matching profile is
   auto-generated).
4. Drop `.torrent` files into the app's data `torrents/` folder, enable RSS,
   and/or point qBittorrent sync at your WebUI.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `listen_addr` | `:7070` | Bind address written into a **new** seed config only. |
| `min_upload_rate_kbs` / `max_upload_rate_kbs` | `30` / `160` | Simulated aggregate upload speed bounds (kB/s). |
| `simultaneous_seed` | `20` | Max torrents announcing as seeding at once. |
| `client_profile` | `qbittorrent-4.6.3` | `*.client` profile name (no extension). |
| `keep_torrent_with_zero_leechers` | `true` | Archive when tracker reports zero leechers if `false`. |
| `upload_ratio_target` | `-1` | Archive at this uploaded/size ratio; `-1` disables. |
| `config_yaml` | *(empty)* | If set, **overwrites** `/data/config.yaml` on every start. Leave empty after first boot so the Web UI owns the file. |

Existing `/data/config.yaml` is never rewritten unless `config_yaml` is set.

### Example (seed options)

```yaml
listen_addr: ":7070"
min_upload_rate_kbs: 30
max_upload_rate_kbs: 160
simultaneous_seed: 20
client_profile: qbittorrent-4.6.3
keep_torrent_with_zero_leechers: true
upload_ratio_target: -1
config_yaml: ""
```

### Data layout

| Path | Purpose |
| --- | --- |
| `/data/config.yaml` | Main config (Web UI + optional HA paste) |
| `/data/torrents/` | Watched folder for `.torrent` files |
| `/data/torrents/archived/` | Finished / archived torrents |
| `/data/state.json` | Persisted per-torrent uploaded totals |
| `/data/profiles/` | Writable profiles (e.g. auto-generated qBittorrent) |

## Endpoints

| Path | Purpose |
| --- | --- |
| `/` | Web UI |
| `/api/torrents` | JSON torrent list |
| `/api/…` | Full JSON API used by the UI (see upstream README) |

## Notes

- Point qBittorrent sync at another HA app with its internal hostname
  (e.g. `http://a0d7b954-qbittorrent:8080`) or a LAN URL.
- Re-check the Web UI after major upstream upgrades; schema notes land in
  [CHANGELOG.md](CHANGELOG.md) via track-upstream.
- Upstream docs:
  [ratioreign](https://github.com/charlestephen/ratioreign).
