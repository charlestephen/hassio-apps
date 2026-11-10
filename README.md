# charlestephen's Hassio Apps

[![Build][build-shield]][build]
[![Dockerfile lint][hadolint-shield]][hadolint]

## About

My Home Assistant Apps repository.

The app images are published to the **GitHub Container Registry** at
`ghcr.io`. Home Assistant pulls a prebuilt, per-architecture image for
each app (`ghcr.io/charlestephen/hassio-addons-<addon>-{arch}`), so
the Supervisor does **not** build them locally.

## Installation

Add this repository to your Home Assistant instance with one click:

[![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fcharlestephen%2Fhassio-apps)

Or add it manually:

1. Go to **Settings → Apps → App Store → ⋮ → Repositories** and add:

   ```
   https://github.com/charlestephen/hassio-apps
   ```

2. Install the apps you want from the store. The images are public on
   `ghcr.io`, so no registry credentials are required.


## Available apps

[//]: # "ADDONLIST_START"

### &#10003; [Acme.sh](acme-sh/)

- Issue and renew certificates with acme.sh and run deploy hooks (including
  UniFi OS). Each certificate lives in `/ssl/acme.sh/<domain>`. The client
  upgrades itself.

### &#10003; [Grafana Alloy](alloy/)

- Ships the logs of every host container to Loki (the supported Promtail
  successor). Bring your own Alloy config, or use the built-in Docker → Loki
  default.

### &#10003; [Authentik](authentik/)

- Identity provider (OpenID Connect, OAuth 2.0, SAML, LDAP). Thin wrapper on
  `ghcr.io/goauthentik/server` running server and worker in one process, using
  the PostgreSQL app for its database.

### &#10003; [Cloudflared](cloudflared/)

- Dual-replica Cloudflare Tunnel for high availability - two connectors of one
  remotely-managed tunnel, with Prometheus metrics. Built on the stock
  cloudflared image.

### &#10003; [Error Pages](error_pages/)

- Customizable, themed HTTP error pages (404/500/…) for your reverse proxy to
  serve.

### &#10003; [Forgejo](forgejo/)

- A self-hosted Git forge for code hosting, review, team collaboration, package
  registry, and CI/CD.

### &#10003; [Gluetun](gluetun/)

- Multi-provider VPN client (OpenVPN / WireGuard) with HTTP and Shadowsocks
  proxies. Thin wrapper on the official `qmcgaw/gluetun` image.

### &#10003; [Network Optimizer](network-optimizer/)

- UniFi network optimization, monitoring, security audit, and Wi-Fi health.
  Thin wrapper on `ghcr.io/ozark-connect/network-optimizer`. Pair with the
  Speed Test app; set `reverse_proxied_host_name` / `host_name` so assigned
  URLs work.

### &#10003; [Network Optimizer Speed Test](network-optimizer-speedtest/)

- OpenSpeedTest frontend that posts results to Network Optimizer. Thin wrapper
  on `ghcr.io/ozark-connect/speedtest`.

### &#10003; [Linkding](linkding/)

- Self-hosted bookmark manager (SQLite by default), with basic config plus
  arbitrary environment-variable injection from the UI. Ingress + port 9090.

### &#10003; [OTLP Collector](otlp-collector/)

- OpenTelemetry Collector Contrib — OTLP logs/traces/metrics hub, Docker stats,
  optional Prometheus scrape; export to Tempo / Loki / Prometheus. Pair with
  Alloy for Docker container log tailing.

### &#10003; [PatchMon](patchmon/)

- Linux patch management and monitoring. Official server image with a private
  Valkey cache, using the PostgreSQL app for its database.

### &#10003; [pgAdmin](pgadmin/)

- pgAdmin 4 web UI to administer and query the PostgreSQL app.

### &#10003; [PgBouncer](pgbouncer/)

- Connection pooler for PostgreSQL, built from the upstream source. Finds the
  PostgreSQL app on its own and reuses its logins.

### &#10003; [Pocket ID](pocket-id/)

- OpenID Connect Certified™ / OAuth 2.0 provider with passkey-only sign-in.
  Thin wrapper on `pocketid/pocket-id`; version tracks upstream releases.

### &#10003; [PostgreSQL](postgres/)

- PostgreSQL 18 database server — usable as the Home Assistant recorder backend
  or a database for other services on the network.

### &#10003; [RatioReign](ratioreign/)

- Headless BitTorrent ratio-farming daemon (tracker announces + simulated
  upload). Thin wrapper on `ghcr.io/charlestephen/ratioreign`.

### &#10003; [Resolved Watchdog](resolved-watchdog/)

- Auto-restarts the host's `systemd-resolved` when it hangs, so a node that
  resolves through its own on-node DNS self-heals instead of wedging.

### &#10003; [Semaphore](semaphore/)

- Modern web UI for Ansible, Terraform, OpenTofu, and other DevOps automation.

### &#10003; [Tang](tang/)

- A Tang server for Network Bound Disk Encryption (NBDE) — automatic LUKS2
  unlocking for machines on the network.

### &#10003; [Technitium DNS](technitium/)

- An authoritative + recursive DNS server with a web management UI, DNSSEC, and
  DNS-over-TLS / DNS-over-HTTPS.

### &#10003; [DNS/IP List Chunker](dns-ip-list-chunker/)

- Merge upstream DNS/IP blocklists into UniFi-sized domain, IPv4, and IPv6
  chunks. Config UI for list URLs and exclusions; `/manage` UI for on-the-fly
  removals behind a reverse proxy.

### &#10003; [Docker Socket Proxy](docker-socket-proxy/)

- Filtered TCP proxy for the host Docker socket
  ([Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)).
  Other apps set `DOCKER_HOST=tcp://dd815a57-docker-socket-proxy:2375` instead of mounting
  the socket. Version tracks upstream releases.

### &#10003; [Hawser Agent for Dockhand](dockhand-hawser/)

- Runs the [Hawser](https://github.com/Finsys/hawser) agent so
  [Dockhand](https://dockhand.pro) can manage this Home Assistant Docker host
  (Edge or Standard mode). Version tracks upstream Hawser releases.

### &#10003; [Homebridge](homebridge/)

- Official `homebridge/homebridge` image with host networking for HomeKit.
  Config UI on port 8581; version tracks dated docker-homebridge tags.

### &#10003; [Homarr](homarr/)

- [Homarr](https://homarr.dev) dashboard for your homelab with widgets,
  integrations and SSO/OIDC. Web UI on port 7575; version tracks upstream
  Homarr releases.

### &#10003; [Traefik](traefik/)

- [Traefik](https://traefik.io/) reverse proxy with file-based dynamic config,
  optional Let's Encrypt, and dashboard Ingress. Version tracks upstream
  Traefik releases.

### &#10003; [Ultimate CA Manager](ultimate-ca-manager/)

- Self-hosted Certificate Authority (ACME, SCEP, EST, OCSP, CRL, TSA, SSH CA).
  Thin wrapper on `neyslim/ultimate-ca-manager`; PKI under `/ssl/ucm/`. Version
  tracks upstream releases.

### &#10003; [Traefik Manager](traefik-manager/)

- Clean, self-hosted web UI for managing Traefik routes, middlewares,
  certificates and logs, without editing YAML by hand.

### &#10003; [Traefik Manager Agent](traefik-manager-agent/)

- Remote-host companion for Traefik Manager, letting it manage a Traefik
  instance running elsewhere on the network.

[//]: # "ADDONLIST_END"

[instructions]: https://home-assistant.io/hassio/installing_third_party_addons

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[hadolint-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/hadolint.yml/badge.svg?branch=main
[hadolint]: https://github.com/charlestephen/hassio-apps/actions/workflows/hadolint.yml?query=branch%3Amain
