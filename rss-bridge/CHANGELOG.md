# Changelog

## 2025.08.05-1

- Initial release.
- RSS-Bridge `2025-08-05`: thin wrapper, no options, no custom entrypoint —
  upstream's own Debian image (nginx + php-fpm) already supervises both
  processes via its own entrypoint, and all configuration is file-based
  (`config.ini.php`, `whitelist.txt`, custom bridges) via the mapped
  `/config` volume, which is exactly the directory upstream's own entrypoint
  already copies from on start.
- Upstream has no semver releases; tracks date-based tags (e.g.
  `2025-08-05`), confirmed matching 1:1 between GitHub releases and Docker
  Hub image tags.
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` rendered from upstream's own `static/favicon.svg`.
