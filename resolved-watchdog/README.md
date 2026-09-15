# Home Assistant App: Resolved Watchdog

Auto-restarts the host's `systemd-resolved` when it hangs, so a node that
resolves through its **own on-node DNS** self-heals instead of wedging.

- Probes the host resolver stub (`127.0.0.53`) on a schedule.
- After N consecutive failures, restarts `systemd-resolved` over the host
  system D-Bus (`host_dbus`).
- Only restarts the unit — never reconfigures it — so the install stays supported.

Built for the circular-dependency hang documented in the host-network DNS
runbook. See [DOCS.md](DOCS.md).
