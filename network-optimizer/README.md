# Home Assistant App: UniFi Network Optimizer

Runs the [Ozark-Connect Network Optimizer](https://github.com/Ozark-Connect/NetworkOptimizer)
for UniFi as a Home Assistant app — Wi-Fi/channel optimization, security
audits, ISP health monitoring, and centralized WAN/LAN speed testing.

A thin wrapper around the upstream `ghcr.io/ozark-connect/network-optimizer`
image; the application itself is unmodified. Every documented environment
variable is exposed in the app Configuration UI. Uses host networking and
the Web UI on port `8042`. On first start, the auto-generated admin password is
printed in the app **Log** tab.

> **Also install the companion [Network Optimizer Speedtest](../network-optimizer-speedtest/)
> app** for full speed-test functionality.

## Credits

- **Network Optimizer** application by **[Ozark-Connect](https://github.com/Ozark-Connect/NetworkOptimizer)**.
- Home Assistant app approach inspired by **[LOOHP/home-assistant-apps](https://github.com/LOOHP/home-assistant-apps)**.

This app is an independent packaging and is not affiliated with or endorsed
by the upstream authors.

See [DOCS.md](DOCS.md) for configuration.
