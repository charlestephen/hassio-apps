# Home Assistant App: UniFi Network Optimizer Speedtest

Companion [OpenSpeedTest](https://github.com/Ozark-Connect/NetworkOptimizer)
server for the **UniFi Network Optimizer** app, providing WAN/LAN speed-test
capability. Thin wrapper around `ghcr.io/ozark-connect/speedtest`; all upstream
environment variables are exposed in the Configuration UI. Web UI on host port
`3005` (container `3000`), matching the optimizer's default `OPENSPEEDTEST_PORT`.

Install alongside the main **UniFi Network Optimizer** app.

## Credits

Speedtest image by [Ozark-Connect](https://github.com/Ozark-Connect/NetworkOptimizer);
app approach inspired by [LOOHP/home-assistant-apps](https://github.com/LOOHP/home-assistant-apps).
Independent packaging, not affiliated with the upstream authors.
