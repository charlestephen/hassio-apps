# Home Assistant Add-on: Cloudflared

Dual-replica [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
for high availability, built on the stock `cloudflare/cloudflared` image.

- Runs **two connector replicas** (`cloudflared0`, `cloudflared1`) of one
  remotely-managed tunnel — Cloudflare-native load-balancing & failover.
- Paste your **connector token** into the Home Assistant UI; routing is managed
  in the Cloudflare Zero Trust dashboard.
- **Prometheus metrics** per replica (`:36400`, `:36401`) for VictoriaMetrics.
- **Auto-updates** with upstream cloudflared (Renovate + Forgejo CI);
  cloudflared's own self-updater is disabled.

See [DOCS.md](DOCS.md) for setup.
