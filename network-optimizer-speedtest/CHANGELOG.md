# Changelog

Version tracks the upstream Ozark-Connect Network Optimizer release.

## 2.0.1-1

- CI: this app's image now builds and publishes automatically via
  **GitHub Actions** on every push, instead of being pushed by hand.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 2.0.1

Initial release.

- Thin HA wrapper around `ghcr.io/ozark-connect/speedtest`.
- Exposes all upstream env vars (`TZ`, `HOST_NAME`, `HOST_IP`,
  `OPENSPEEDTEST_PORT/HOST/HTTPS/HTTPS_PORT`, `REVERSE_PROXIED_HOST_NAME`).
- Web UI on host port 3005 (container 3000).
