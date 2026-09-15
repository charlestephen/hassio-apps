# Home Assistant App: UniFi Voucher Manager

Modern web app for managing UniFi WiFi vouchers — a Next.js frontend with a Rust
backend — including QR codes and rolling vouchers.

A thin wrapper around the standalone
[etiennecollin/unifi-voucher-manager](https://github.com/etiennecollin/unifi-voucher-manager)
container, packaged as a Home Assistant app. **All** environment
variables/settings are exposed in the Configuration UI. The frontend is on port
**3000** and the backend API on port **8080** (both published).

## Credits

UniFi Voucher Manager by **[Étienne Collin](https://github.com/etiennecollin/unifi-voucher-manager)**.
Independent packaging, not affiliated with or endorsed by the upstream author.

See [DOCS.md](DOCS.md) for configuration.
