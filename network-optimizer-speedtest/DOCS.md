# Home Assistant App: Network Optimizer Speed Test

Customized [OpenSpeedTest](https://openspeedtest.com/) that posts results to
Network Optimizer’s public API. This app wraps
[`ghcr.io/ozark-connect/speedtest`](https://ghcr.io/ozark-connect/speedtest)
`2.11.0` and **execs upstream** `/docker-entrypoint.sh` after exporting the
same host / proxy environment variables as the main app.

Install **[Network Optimizer](../network-optimizer/)** first (or together).

## URL correctness

Upstream injects `SAVE_DATA_URL` into `config.js` from, in order:

1. `REVERSE_PROXIED_HOST_NAME` (+ optional `REVERSE_PROXIED_PORT`) → `https://…/api/public/speedtest/results`
2. else `HOST_NAME` → `http://HOST_NAME:8042/api/public/…`
3. else `HOST_IP` → `http://HOST_IP:8042/api/public/…`
4. else a dynamic browser-origin fallback (often wrong on HA)

It also installs a **canonical host redirect** when `OPENSPEEDTEST_HOST` /
`HOST_NAME` / `HOST_IP` is set, so mobile browsers don’t cache the wrong
origin.

Set the **same** values you use on Network Optimizer. Example behind HTTPS:

```yaml
reverse_proxied_host_name: optimizer.lan.example.com
openspeedtest_host: speedtest.lan.example.com
openspeedtest_https: true
openspeedtest_https_port: "443"
openspeedtest_port: "3005"
```

Direct LAN:

```yaml
host_name: homeassistant.local
openspeedtest_host: homeassistant.local
openspeedtest_port: "3005"
openspeedtest_https: false
```

`openspeedtest_port` must match this app’s **host** port mapping (default
`3005`).

## How it works

1. Options → env (`HOST_*`, `REVERSE_PROXIED_*`, `OPENSPEEDTEST_*`, …).
2. Upstream entrypoint rewrites `config.js`, optionally adds nginx redirect
   rules, then starts nginx on container port **3000**.
3. Supervisor publishes **3005/tcp** → 3000.

## Configuration

| Option | Default | Env | Description |
| --- | --- | --- | --- |
| `tz` | `America/New_York` | `TZ` | Timezone. |
| `host_ip` / `host_name` | *(empty)* | `HOST_IP` / `HOST_NAME` | Direct HTTP identity for result posts + redirects. |
| `reverse_proxied_host_name` | *(empty)* | `REVERSE_PROXIED_HOST_NAME` | HTTPS hostname of **Network Optimizer** (result API). |
| `reverse_proxied_port` | *(empty)* | `REVERSE_PROXIED_PORT` | Non-443 optimizer front-end port. |
| `trusted_proxies` / `trusted_proxy_hops` / `trust_cf_connecting_ip` | | same names | Proxy trust (parity with main app). |
| `openspeedtest_port` | `3005` | `OPENSPEEDTEST_PORT` | Host port clients use (must match published port). |
| `openspeedtest_host` | *(empty)* | `OPENSPEEDTEST_HOST` | Canonical speed-test hostname. |
| `openspeedtest_https` | `false` | `OPENSPEEDTEST_HTTPS` | Clients reach the speed test via HTTPS. |
| `openspeedtest_https_port` | `443` | `OPENSPEEDTEST_HTTPS_PORT` | HTTPS port. |
| `external_server_id` | *(empty)* | `EXTERNAL_SERVER_ID` | WAN external speed-test server id (advanced). |
| `extra_env` | *(empty)* | *(any)* | Multiline `KEY=VALUE`. |

## Ports

| Container | Host (default) | Purpose |
| --- | --- | --- |
| `3000/tcp` | `3005` | Speed test Web UI |

## Notes

- Keep TCP buffer / BBR tuning on the **host** if you care about long-RTT
  single-stream accuracy (upstream DEPLOYMENT.md).
- AppArmor profile name: `network_optimizer_speedtest` (matches `slug`).
- Upstream deployment notes:
  [Speed Test section](https://github.com/Ozark-Connect/NetworkOptimizer/blob/main/docker/DEPLOYMENT.md).
