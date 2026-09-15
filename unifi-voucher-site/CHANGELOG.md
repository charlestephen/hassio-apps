# Changelog

Version tracks the upstream glenndehaan/unifi-voucher-site release.

## 8.11.0-2

- Security: replaced the shipped default internal auth credentials
  (`0000` password, all-zero bearer token) with `CHANGE_ME` placeholders.
  The old defaults were real, guessable values that would work if a user
  never changed them, unlike this repo's other secret options which either
  auto-generate or use an obviously-fake `CHANGE_ME_*` placeholder.

## 8.11.0-1

- CI: this app's image now builds and publishes automatically via
  **GitHub Actions** on every push, instead of being pushed by hand.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 8.11.0

Initial release.

- Thin HA wrapper around `glenndehaan/unifi-voucher-site`, served via ingress.
- Exposes the **full** upstream environment surface as app options,
  including the parts commonly omitted:
  - **Internal auth**: `AUTH_INTERNAL_ENABLED`, `AUTH_INTERNAL_PASSWORD`,
    `AUTH_INTERNAL_BEARER_TOKEN`.
  - **OIDC/SSO**: `AUTH_OIDC_ENABLED`, `AUTH_OIDC_ISSUER_BASE_URL`,
    `AUTH_OIDC_APP_BASE_URL`, `AUTH_OIDC_CLIENT_ID`, `AUTH_OIDC_CLIENT_SECRET`,
    `AUTH_OIDC_REDIRECT_LOGIN`, `AUTH_OIDC_RESTRICT_VISIBILITY`.
  - `AUTH_DISABLE`, `SERVICE_WEB`, `SERVICE_API`, `BIND_ADDRESS`.
  - Plus UniFi connection, voucher, printer, SMTP, kiosk, translation, and
    cleanup-task variables.
