# charlestephen's Hassio Apps

## About

My Home Assistant Apps repository.

The app images are published to the **GitHub Container Registry** at
`ghcr.io`. Home Assistant pulls a prebuilt, per-architecture image for
each app (`ghcr.io/charlestephen/hassio-addons-<addon>-{arch}`), so
the Supervisor does **not** build them locally.

## Installation

Add this repository to your Home Assistant instance with one click:

[![Open your Home Assistant instance and show the add apps repository dialog with this repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_apps_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fcharlestephen%2Fhassio-apps)

Or add it manually:

1. Go to **Settings → Apps → App Store → ⋮ → Repositories** and add:

   ```
   https://github.com/charlestephen/hassio-apps
   ```

2. Install the apps you want from the store. The images are public on
   `ghcr.io`, so no registry credentials are required.


## Available apps

[//]: # "ADDONLIST_START"

### &#10003; [Grafana Alloy](alloy/)

- Ships the logs of every host container to Loki (the supported Promtail
  successor). Bring your own Alloy config, or use the built-in Docker → Loki
  default.

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

### &#10003; [Linkding](linkding/)

- Self-hosted bookmark manager (SQLite by default), with basic config plus
  arbitrary environment-variable injection from the UI. Ingress + port 9090.

### &#10003; [pgAdmin](pgadmin/)

- pgAdmin 4 web UI to administer and query the PostgreSQL app.

### &#10003; [PostgreSQL](postgres/)

- PostgreSQL 18 database server — usable as the Home Assistant recorder backend
  or a database for other services on the network.

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

### &#10003; [Traefik Manager](traefik-manager/)

- Clean, self-hosted web UI for managing Traefik routes, middlewares,
  certificates and logs, without editing YAML by hand.

### &#10003; [Traefik Manager Agent](traefik-manager-agent/)

- Remote-host companion for Traefik Manager, letting it manage a Traefik
  instance running elsewhere on the network.

[//]: # "ADDONLIST_END"

[instructions]: https://home-assistant.io/hassio/installing_third_party_addons
