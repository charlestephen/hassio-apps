# Home Assistant App: Network Optimizer

[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Self-hosted UniFi network optimization, monitoring (NMS), security audit, Wi-Fi
health, and speed-test orchestration. Thin Home Assistant wrapper around
[`ghcr.io/ozark-connect/network-optimizer`][image] `2.10.7` (upstream
`/entrypoint.sh` preserved). Source:
[Ozark-Connect/NetworkOptimizer][upstream].

Install the companion **[Network Optimizer Speed Test](../network-optimizer-speedtest/)**
app as well. Set `host_name` / `host_ip` or `reverse_proxied_host_name` so the
UI, CORS, and speed-test result posts follow the URL you actually use. See
[DOCS.md](DOCS.md).

Initial admin password is printed once in the app **Log** tab.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v2.10.7-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/network-optimizer
[upstream]: https://github.com/Ozark-Connect/NetworkOptimizer
[image]: https://ghcr.io/ozark-connect/network-optimizer
