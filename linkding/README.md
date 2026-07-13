# Home Assistant Add-on: Linkding

Self-hosted [Linkding](https://github.com/sissbruecker/linkding) bookmark
manager, wrapping `ghcr.io/sissbruecker/linkding:latest-alpine` with the HA
add-on framework.

- **SQLite** by default, persisted to the add-on's `/data` (backed up with HA).
- **Config UI** for the basics (admin user, background tasks) **plus arbitrary
  env-var injection** — set any `LD_*` variable without a rebuild.
- **Ingress** (HA sidebar) + direct port **9090**.

See [DOCS.md](DOCS.md).
