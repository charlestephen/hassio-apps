# Changelog

## 1.0.2-2

- CI: add build.yaml (no functional change) so GitHub's generic
  discover-and-build workflow, which requires both config.yaml and
  build.yaml, actually picks this app up and builds/publishes it.

## 1.0.2-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-resolved-watchdog-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 1.0.2

- Add `full_access` so Home Assistant shows the Protection-mode (host access) toggle. After installing/updating, open the app's Info tab and turn Protection mode OFF to grant the host D-Bus access used to restart systemd-resolved.

## 1.0.1

- aarch64-only: the `host_dbus` recovery needs `dbus-send` (an apk `RUN` step), which segfaults cross-building to amd64 under emulation on the libkrun/podman builders. The app targets the aarch64 node anyway, so amd64 is dropped.

## 1.0.0

- Initial release: watchdog that restarts host `systemd-resolved` when it hangs.
- `host_network` probe of the resolver stub (`127.0.0.53`) + `host_dbus`
  `systemd1.RestartUnit` recovery.
- Configurable probe host, interval, timeout, failure threshold, and target unit.
- Non-invasive (restart only; never edits `resolved.conf`), so the install stays
  "supported".
