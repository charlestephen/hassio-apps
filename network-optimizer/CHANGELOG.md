# Changelog

Version tracks the upstream Ozark-Connect Network Optimizer release.

## 2.0.1-1

- CI: this app's image now builds and publishes automatically via
  **GitHub Actions** on every push, instead of being pushed by hand.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 2.0.1

Initial release.

- Thin Home Assistant wrapper around `ghcr.io/ozark-connect/network-optimizer`.
- Converts the previous static packaging into a proper wrapper so **all**
  upstream environment variables are configurable from the HA UI:
  `TZ`, `BIND_LOCALHOST_ONLY`, `APP_PASSWORD`, `HOST_IP`, `HOST_NAME`,
  `REVERSE_PROXIED_HOST_NAME`, `IPERF3_SERVER_ENABLED`, `OPENSPEEDTEST_PORT/HOST/HTTPS/HTTPS_PORT`,
  `LOG_LEVEL`, `APP_LOG_LEVEL`, `DEMO_MODE_MAPPINGS`.
- Persists `/app/data`, `/app/logs`, `/app/ssh-keys` under the app `/data`
  volume so state survives restarts and updates.
- Host networking + Web UI on port 8042.
