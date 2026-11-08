# Home Assistant App: Linkding

[![Build][build-shield]][build]

Self-hosted [Linkding](https://github.com/sissbruecker/linkding) bookmark
manager, wrapping `ghcr.io/sissbruecker/linkding:latest-alpine` with the HA
app framework.

- **SQLite** by default, persisted to the app's `/data` (backed up with HA).
- **Config UI** for the basics (admin user, background tasks) **plus arbitrary
  env-var injection** — set any `LD_*` variable without a rebuild.
- **Ingress** (HA sidebar) + direct port **9090**.

See [DOCS.md](DOCS.md).

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
