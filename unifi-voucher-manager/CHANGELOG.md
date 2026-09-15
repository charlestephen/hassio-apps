# Changelog

Version tracks the upstream etiennecollin/unifi-voucher-manager release.

## 1.0.0-2

- Security: the backend REST API (no auth of its own) is no longer exposed
  to the network by default. `backend_bind_host` now defaults to
  `127.0.0.1` and the `8080/tcp` host port mapping defaults to unset —
  previously both defaulted to open (`0.0.0.0` + a fixed host port).
  Set both explicitly if you need external access to the API.
- Security: the persistent volume mount changed from `type: share`
  (writable access to HA's repo-wide `/share` folder) to `type: data`
  (scoped to this app only).

## 1.0.0-1

- CI: this app's image now builds and publishes automatically via
  **GitHub Actions** on every push, instead of being pushed by hand.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 1.0.0

Initial release.

- Thin HA wrapper around `etiennecollin/unifi-voucher-manager` (Next.js frontend
  + Rust backend).
- Exposes **all** upstream settings as app options: `UNIFI_CONTROLLER_URL`,
  `UNIFI_API_KEY`, `UNIFI_HAS_VALID_CERT`, `UNIFI_SITE_ID`, `GUEST_SUBNETWORK`,
  `WIFI_SSID/PASSWORD/TYPE/HIDDEN`, `ROLLING_VOUCHER_DURATION_MINUTES`,
  `TIMEZONE`, `BACKEND_LOG_LEVEL`, and the frontend/backend bind host/port/url vars.
- Frontend on port 3000, backend API on port 8080 (both published).
