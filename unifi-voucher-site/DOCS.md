# Home Assistant App: UniFi Voucher Site

## Setup

1. On your UniFi OS Console, create an **API key** (integrations tab).
2. Install and open the app's **Configuration** tab.
3. Set **UniFi IP**, **UniFi port**, **UniFi API token**, and your guest **SSID**.
4. Start the app and open it via the Home Assistant sidebar (ingress).

## Authentication

- **Internal** (default): you must set **Internal password** and **Internal
  bearer token** before starting — both ship as `CHANGE_ME` placeholders with
  no safe default, and the app will not stop you from running with them
  unchanged.
- **OIDC / SSO**: set **Enable OIDC/SSO**, then **OIDC issuer base URL**,
  **OIDC app base URL** (this site's public URL), **OIDC client ID/secret**.
  Use **OIDC redirect login** to skip the local login page, and **OIDC restrict
  visibility** to limit access by email domain.
- **Disable all auth** removes web + API authentication entirely — only use on a
  trusted, isolated network.

## Services, printing, kiosk, SMTP

Enable the **web UI** and/or **REST API**, configure **Printers** (`pdf` or
ESC/POS IPs) and layout, **SMTP** for emailed vouchers, and **Kiosk** mode for
self-service guest voucher generation. See each option's help text.

## Credits

UniFi Voucher Site by [Glenn de Haan](https://github.com/glenndehaan/unifi-voucher-site).
