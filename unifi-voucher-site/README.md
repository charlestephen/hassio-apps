# Home Assistant App: UniFi Voucher Site

Web-based generation and administration of UniFi guest network vouchers, with
QR codes, printing, kiosk mode, SMTP delivery, internal authentication, and
**OIDC/SSO**.

A thin wrapper around [glenndehaan/unifi-voucher-site](https://github.com/glenndehaan/unifi-voucher-site).
This packaging exposes the **complete** environment surface in the HA
Configuration UI — including the internal-auth (`AUTH_INTERNAL_PASSWORD`,
bearer token) and all OIDC variables (`AUTH_OIDC_*`) — not just the basics.
Served through Home Assistant ingress (port 3000).

## Credits

UniFi Voucher Site by **[Glenn de Haan](https://github.com/glenndehaan/unifi-voucher-site)**.
Independent packaging, not affiliated with or endorsed by the upstream author.

See [DOCS.md](DOCS.md) for configuration.
