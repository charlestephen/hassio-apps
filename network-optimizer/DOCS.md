# Home Assistant App: Network Optimizer

Self-hosted optimization, monitoring, and security tooling for UniFi networks.
This app wraps
[`ghcr.io/ozark-connect/network-optimizer`](https://ghcr.io/ozark-connect/network-optimizer)
`2.11.1` ([Ozark-Connect/NetworkOptimizer](https://github.com/Ozark-Connect/NetworkOptimizer))
and **execs upstream** `/entrypoint.sh` after mapping HA `/data` into the
paths the image expects and exporting compose-parity environment variables.

Also install **[Network Optimizer Speed Test](../network-optimizer-speedtest/)**
— client / LAN speed tests post results back to this app.

## Why this wrapper (URL correctness)

The community LOOHP add-on runs the image with almost no options. Upstream
builds canonical URLs, CORS allow-lists, OIDC/SAML callback URLs, and
speed-test result endpoints from:

| Env | Role |
| --- | --- |
| `REVERSE_PROXIED_HOST_NAME` | HTTPS public hostname (Traefik / NPM / Caddy) |
| `REVERSE_PROXIED_PORT` | Non-443 front-end port, if any |
| `HOST_NAME` / `HOST_IP` | Direct HTTP access (no TLS proxy) |
| `OPENSPEEDTEST_*` | Where the UI points browsers for OpenSpeedTest |

If those are empty, the app assumes `http://<container>:8042` and **will not
follow** the URL you assign in your reverse proxy. This app exposes every
compose variable so you can set them.

### Recommended setups

**A. Behind HTTPS reverse proxy (recommended)**

```yaml
reverse_proxied_host_name: optimizer.lan.example.com
# reverse_proxied_port: ""          # leave blank for 443
trusted_proxies: "172.30.32.0/23"   # HA Docker / supervisor range as needed
openspeedtest_host: speedtest.lan.example.com
openspeedtest_https: true
openspeedtest_https_port: "443"
openspeedtest_port: "3005"
```

Point Traefik/NPM at the HA host on port **8042** for the app and **3005**
for the speed-test app (or their published host ports).

**B. Direct HTTP on the LAN**

```yaml
host_name: homeassistant.local
# or: host_ip: 203.0.113.10
openspeedtest_port: "3005"
openspeedtest_host: homeassistant.local
openspeedtest_https: false
```

## How it works

1. Options from `/data/options.json` become Network Optimizer env vars.
2. `/data/{data,ssh-keys,logs}` are symlinked to `/app/{data,ssh-keys,logs}`
   so SQLite, license, and keys survive updates. The wrapper also `chown`s
   those real volume dirs to upstream’s `app` user (symlink targets are not
   covered by upstream’s `chown -R /app/data`).
3. Control returns to upstream `/entrypoint.sh` → `gosu app dotnet NetworkOptimizer.Web.dll`.
4. **Host networking** matches upstream compose so traceroute / path analysis /
   LAN probes see the real host network namespace.

## Quick start

1. Install **Network Optimizer** and **Network Optimizer Speed Test**.
2. Set URL options (see above) to match how you will open the UI.
3. Start both apps. Open the Optimizer **Log** tab for the one-time admin
   password (do not use `docker logs` on HA OS).
4. Open `http://<ha-host>:8042/` (or your HTTPS hostname) and sign in as
   `admin`.
5. Configure UniFi connection + monitoring in the Web UI.

## Configuration

| Option | Default | Env | Description |
| --- | --- | --- | --- |
| `tz` | `America/New_York` | `TZ` | Container timezone. |
| `app_password` | *(empty)* | `APP_PASSWORD` | Optional seed for initial admin password; leave empty to let upstream generate + log one. |
| `bind_localhost_only` | `false` | `BIND_LOCALHOST_ONLY` | `true` binds `localhost:8042` only (same-host reverse proxy). Keep `false` on HA so LAN / Supervisor can reach it. |
| `host_ip` | *(empty)* | `HOST_IP` | LAN IP used for CORS / speed-test posts when not behind HTTPS. |
| `host_name` | *(empty)* | `HOST_NAME` | DNS name for direct HTTP access. |
| `reverse_proxied_host_name` | *(empty)* | `REVERSE_PROXIED_HOST_NAME` | Public HTTPS hostname — **set this when you assign a URL**. |
| `reverse_proxied_port` | *(empty)* | `REVERSE_PROXIED_PORT` | Front-end port if not 443. |
| `trusted_proxies` | *(empty)* | `TRUSTED_PROXIES` | CIDRs/IPs allowed to send `X-Forwarded-*`. |
| `trusted_proxy_hops` | *(empty)* | `TRUSTED_PROXY_HOPS` | Max forwarded hops to trust. |
| `trust_cf_connecting_ip` | `false` | `TRUST_CF_CONNECTING_IP` | Trust Cloudflare `CF-Connecting-IP`. |
| `openspeedtest_port` | `3005` | `OPENSPEEDTEST_PORT` | Host port of the speed-test app (must match that app’s published port). |
| `openspeedtest_host` | *(empty)* | `OPENSPEEDTEST_HOST` | Hostname browsers use for the speed test (defaults to `HOST_NAME` upstream). |
| `openspeedtest_https` | `false` | `OPENSPEEDTEST_HTTPS` | Speed test is reached via HTTPS. |
| `openspeedtest_https_port` | `443` | `OPENSPEEDTEST_HTTPS_PORT` | HTTPS port for the speed test. |
| `iperf3_server_enabled` | `false` | `Iperf3Server__Enabled` | Accept inbound iperf3 on **5201**. |
| `log_level` | `Information` | `Logging__LogLevel__Default` | .NET default log level. |
| `app_log_level` | `Information` | `Logging__LogLevel__NetworkOptimizer` | App-namespace log level. |
| `demo_mode_mappings` | *(empty)* | `DEMO_MODE_MAPPINGS` | Upstream demo mode mapping string. |
| `extra_env` | *(empty)* | *(any)* | Multiline `KEY=VALUE` for additional ASP.NET / app settings. |

### Example (direct LAN)

```yaml
tz: America/New_York
host_name: homeassistant.local
openspeedtest_port: "3005"
openspeedtest_host: homeassistant.local
iperf3_server_enabled: false
```

### Data layout

| Path | Purpose |
| --- | --- |
| `/data/data/` | SQLite DB, configs, license (`/app/data`) |
| `/data/ssh-keys/` | Optional SSH keys for agent / AP deploy |
| `/data/logs/` | Application logs |

## Ports (host network)

With `host_network: true`, the process binds on the HA host itself:

| Port | Purpose |
| --- | --- |
| `8042/tcp` | Web UI + API (`/api/health`) |
| `5201/tcp` | iperf3 server when enabled |

## Protection mode / privileges

- **Host network** — required for accurate path / traceroute behavior (upstream
  default).
- **`NET_RAW`** — ICMP traceroute (`cap_net_raw` on upstream `traceroute`).
- Leave Protection mode on unless Supervisor blocks something you need; this
  app does not mount the Docker socket.

## Companion speed test

Configure the same `host_*` / `reverse_proxied_*` values on
[network-optimizer-speedtest](../network-optimizer-speedtest/) so result POSTs
hit this app’s `/api/public/speedtest/results` over the correct scheme/host.

## Notes

- Personal use ≤3 sites is free per upstream licensing; commercial / more
  sites need a key (Settings → Application → Licensing). Activation talks to
  `licensing.ozarkconnect.net` over HTTPS.
- Full upstream deployment guide:
  [docker/DEPLOYMENT.md](https://github.com/Ozark-Connect/NetworkOptimizer/blob/main/docker/DEPLOYMENT.md).
- track-upstream follows GitHub releases (`vX.Y.Z` → image tag `X.Y.Z` on GHCR).
- AppArmor profile name: `network_optimizer` (matches `slug`).
