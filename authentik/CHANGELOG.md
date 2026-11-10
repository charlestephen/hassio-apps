# Changelog

## 2026.8.5-2

- Default **Log level** is now `warning`, which removes per-request and health-check log lines and suits SD-card installs. Existing installs keep their current setting.

## 2026.8.5-1

- Fix migrations failing with "permission denied for schema public" when the database already existed under another owner. With the admin password set, the app now makes the database user the owner and grants it rights on the `public` schema on every start.

## 2026.8.5

- First release: authentik 2026.8.5 in `allinone` mode, using the PostgreSQL app for its database.
