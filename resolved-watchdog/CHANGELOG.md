# Changelog

## 1.0.2

- Add `full_access` so Home Assistant shows the Protection-mode (host access) toggle. After installing/updating, open the add-on's Info tab and turn Protection mode OFF to grant the host D-Bus access used to restart systemd-resolved.

## 1.0.1

- aarch64-only: the `host_dbus` recovery needs `dbus-send` (an apk `RUN` step), which segfaults cross-building to amd64 under emulation on the libkrun/podman builders. The add-on targets the aarch64 node anyway, so amd64 is dropped.

## 1.0.0

- Initial release: watchdog that restarts host `systemd-resolved` when it hangs.
- `host_network` probe of the resolver stub (`127.0.0.53`) + `host_dbus`
  `systemd1.RestartUnit` recovery.
- Configurable probe host, interval, timeout, failure threshold, and target unit.
- Non-invasive (restart only; never edits `resolved.conf`), so the install stays
  "supported".
