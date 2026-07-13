# Changelog

## 4.2.2.a

- Upgrade base image from `ghcr.io/hassio-addons/base:20.0.1` to
  `ghcr.io/hassio-addons/base:21.0.0` (Alpine 3.24). The error-pages binary is
  statically linked and unaffected; only the base OS layer changes.

## 4.2.2

- Update upstream `error-pages` binary from `4.2.1` to `4.2.2`. This is a
  bug-fix release: corrects the default behaviour of `--send-same-http-code` when
  no explicit status code is supplied by the reverse proxy, and updates bundled
  templates for several themes. No configuration changes required.

## 4.2.1

- Initial release.
- error-pages 4.2.1 (static Go binary copied onto the Home Assistant Alpine base).
- All major options configurable: theme, default error page, send-same-HTTP-code,
  show-details, theme rotation, disable-l10n, proxy headers, log level/format.
- Serves on port 8080 for reverse proxies (Traefik/nginx/…). Ships an AppArmor
  profile.
