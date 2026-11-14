# Home Assistant App: RatioReign

Fetches nothing from the BitTorrent swarm — RatioReign only talks to your
private trackers with believable announce fingerprints and a climbing upload
counter. This app wraps
[charlestephen/ratioreign](https://github.com/charlestephen/ratioreign)
`2.2.1` and **execs the upstream binary** after mapping HA's `/data` volume
into the paths RatioReign expects.

## What it does

| Capability | Detail |
| --- | --- |
| Fake seeding | HTTP tracker announces (`started` / regular / `stopped`) with a simulated upload counter |
| Client fingerprints | Impersonates qBittorrent / Transmission via `*.client` profiles |
| Intake | Drop `.torrent` files, poll RSS feeds, and/or mirror a qBittorrent WebUI list |
| Persistence | Per-torrent uploaded totals survive restarts (`state.json`) |
| Web UI + JSON API | Port **7070** — config, torrent table, qBittorrent test |

It does **not** open peer connections or transfer torrent payload data.

## Authentication (default on)

Upstream **2.2.1** enables HTTP Basic Auth by default for the web UI and
`/api/*`. On first start with an empty password, RatioReign generates one,
writes it into `/data/config.yaml`, and logs it once (Supervisor → Log):

```text
auth enabled with auto-generated password — change it in the web UI
```

| HA option | Maps to | Notes |
| --- | --- | --- |
| `auth_enabled` | `auth.enabled` | Default `true`. |
| `auth_username` | `auth.username` | Default `admin`. |
| `auth_password` | `auth.password` | Leave empty to auto-generate on first seed; set explicitly to pin. |

`/healthz` stays open (no auth) for probes. Change the password later in the
Web UI Configuration panel, or set `auth_password` / `config_yaml` before
first start.

Browser prompts for credentials when you open the Web UI. API examples:

```bash
curl -u admin:'YOUR_PASSWORD' http://homeassistant.local:7070/api/torrents
```

## How it works

1. On first start the wrapper seeds `/data/config.yaml` from the HA options
   (listen address, upload rate bounds, client profile, auth, …).
2. Torrents, archive, and resume state live under `/data` so they survive
   updates. Bundled client profiles stay in the image at `/app/profiles`.
3. Control returns to upstream: `ratioreign -config /app/config/config.yaml`
   (uid `1000`, same as the official image).
4. Use the **Web UI** (port 7070) for day-to-day config — RSS feeds,
   qBittorrent sync, exclusions, torrent table. The UI writes the same YAML
   and restarts the process to apply changes.

## Quick start

1. Install **RatioReign** and start it.
2. Open the Log panel once and copy the generated Basic Auth password (or
   set `auth_password` in options before the first start).
3. Open `http://<home-assistant-host>:7070/` and sign in.
4. Set `clientProfile` (or enable qBittorrent sync so a matching profile is
   auto-generated).
5. Drop `.torrent` files into the app's data `torrents/` folder, enable RSS,
   and/or point qBittorrent sync at your WebUI.

## Configuration

HA options only **seed** a missing `/data/config.yaml` (or overwrite it when
`config_yaml` is set). After first boot, prefer the Web UI.

| Option | Default | Description |
| --- | --- | --- |
| `listen_addr` | `:7070` | Bind address written into a **new** seed config only. |
| `auth_enabled` | `true` | HTTP Basic Auth for UI/API. |
| `auth_username` | `admin` | Basic Auth username. |
| `auth_password` | *(empty)* | Empty → auto-generate on first seed; otherwise used as-is. |
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
auth_enabled: true
auth_username: admin
auth_password: ""
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

| Path | Auth | Purpose |
| --- | --- | --- |
| `/` | Basic | Web UI |
| `/api/torrents` | Basic | JSON torrent list / upload / delete |
| `/api/config` | Basic | Read/write YAML-backed config |
| `/api/qbittorrent/*` | Basic | Sync status + connection test |
| `/healthz` | none | Liveness (`ok`) |

Full JSON API: [upstream README](https://github.com/charlestephen/ratioreign#api).

## qBittorrent sync on Home Assistant

Point sync at another add-on's internal hostname (examples):

- Same host, published WebUI: `http://homeassistant:8080`
- Another HA app slug network name if you use one

If qBittorrent sits behind the **Gluetun** app, see upstream's Gluetun
troubleshooting notes (firewall outbound subnets / `localhost` vs container
DNS). Use **Test connection** in the Web UI.

## Notes

- Re-check the Web UI after major upstream upgrades; schema notes land in
  [CHANGELOG.md](CHANGELOG.md) via track-upstream.
- AppArmor profile `ratioreign` ships with this app (matches `slug`).
- Upstream docs:
  [ratioreign](https://github.com/charlestephen/ratioreign).
