# Home Assistant App: Resolved Watchdog

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Auto-restarts the host's `systemd-resolved` when it hangs, so a node that
resolves through its **own on-node DNS** self-heals instead of wedging.

- Probes the host resolver stub (`127.0.0.53`) on a schedule.
- After N consecutive failures, restarts `systemd-resolved` over the host
  system D-Bus (`host_dbus`).
- Only restarts the unit — never reconfigures it — so the install stays supported.

Built for the circular-dependency hang documented in the host-network DNS
runbook. See [DOCS.md](DOCS.md).

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fresolved-watchdog%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/resolved-watchdog
