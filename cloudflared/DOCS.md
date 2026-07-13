# Home Assistant Add-on: Cloudflared

Runs the official [`cloudflared`](https://hub.docker.com/r/cloudflare/cloudflared)
connector as **two replicas of one remotely-managed Cloudflare tunnel** for high
availability. Cloudflare load-balances across the connectors and fails over
automatically — no Cloudflare Load Balancer product required.

## Setup

1. In the **Cloudflare Zero Trust dashboard** → **Networks → Tunnels**, create a
   tunnel (or open an existing one) with the **Cloudflared** connector type.
2. Copy the **connector token** — the long value in the
   `cloudflared service install <TOKEN>` / `... run <TOKEN>` command the
   dashboard shows.
3. In this add-on's **Configuration** tab, paste it into **Tunnel token**, save.
4. Start the add-on. Two connectors — `cloudflared0` and `cloudflared1` — will
   register on the tunnel's page.
5. Configure your **public hostnames / routes** in the dashboard. Routing is
   dashboard-managed; this add-on only runs the connectors.

## High availability

Both replicas run the *same* tunnel token, so Cloudflare treats them as redundant
connectors of one tunnel and balances/fails over between them. Each replica also
opens connections to the two nearest Cloudflare data centers automatically
(closest + second-closest), giving edge-level redundancy.

> Both replicas run on this one node, so this protects against a connector crash
> and colo/edge issues — not against the node itself going down. For cross-host
> HA, run another replica on a second machine with the same token.

## Options

| Option | Description |
| --- | --- |
| `tunnel_token` | Connector token of your remotely-managed tunnel (masked in the UI). Both replicas use it. |
| `log_level` | `debug` / `info` / `warn` / `error` (default `info`). |

## Metrics

Each replica exposes cloudflared's Prometheus endpoint:

- `cloudflared0` → `http://<home-assistant-host>:36400/metrics` (and `/ready`)
- `cloudflared1` → `http://<home-assistant-host>:36401/metrics`

Point a VictoriaMetrics / vmagent scrape job at those two targets.

## Networking

Runs on **bridge** networking. cloudflared only makes outbound connections, so it
can reach `homeassistant` (via CoreDNS) and LAN origins via NAT. If you need to
tunnel to a service bound only to the host's loopback, set `host_network: true`
in `config.yaml`.

## Auto-update

The cloudflared binary is pinned in the image (`CLOUDFLARED_VERSION`) and tracked
by Renovate; a new upstream release triggers a rebuild + version bump like your
other add-ons. cloudflared's own self-updater is disabled (`--no-autoupdate`)
because the image is immutable.
