# CharleStephen's Home Assistant Apps

## About

A public collection of Home Assistant add-ons. Prebuilt, per-architecture images
are published to the GitHub Container Registry (`ghcr.io`) and pulled directly by
the Home Assistant Supervisor — it does not build them locally.

## Installation

1. In Home Assistant, open **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
   and add:

   ```
   https://github.com/charlestephen/hassio-apps
   ```

2. Install the add-on you want from the store. The images are **public** on
   `ghcr.io`, so no registry credentials are required.

## Available add-ons

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

- pgAdmin 4 web UI to administer and query the PostgreSQL add-on.

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

[//]: # "ADDONLIST_END"

[instructions]: https://home-assistant.io/hassio/installing_third_party_addons
