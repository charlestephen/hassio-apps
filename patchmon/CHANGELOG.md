# Changelog

## 2.1.8-1

- Fix `icon.png`/`logo.png`: replaced a flattened render with a solid white
  background (confirmed via pixel inspection: opaque white at every corner)
  with upstream's own `logo_square_default.svg`
  (https://github.com/PatchMon/PatchMon/blob/main/frontend/public/assets/logo_square_default.svg),
  rendered to 256x256 PNG with a real transparent background.

## 2.1.8

- First release: PatchMon 2.1.8 with a private Valkey cache, using the PostgreSQL app for its database.
