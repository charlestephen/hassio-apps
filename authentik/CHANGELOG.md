# Changelog

## 2026.8.5-7

- Fix start-up failure with `/certs` mapped from `/ssl`: the app now drops to the authentik user itself, so upstream no longer runs `chown -R` on `/certs`. Files in `/ssl` keep their ownership.

## 2026.8.5-6

- Home Assistant `/ssl` is now mounted read-only at `/certs` in the container.

## 2026.8.5-5

- With **Use PgBouncer** on, connect with `sslmode=prefer`. authentik defaults to no TLS, so it could not connect when PgBouncer required TLS.

## 2026.8.5-4

- New **Use PgBouncer** option connects through the PgBouncer app with the settings authentik requires behind a transaction-mode pooler.

## 2026.8.5-3

- Default **Log level** is back to `info`; 2026.8.5-2 changed it to `warning`.

## 2026.8.5-2

- Default **Log level** is now `warning`, which removes per-request and health-check log lines and suits SD-card installs. Existing installs keep their current setting.

## 2026.8.5-1

- Fix migrations failing with "permission denied for schema public" when the database already existed under another owner. With the admin password set, the app now makes the database user the owner and grants it rights on the `public` schema on every start.

## 2026.8.5

- First release: authentik 2026.8.5 in `allinone` mode, using the PostgreSQL app for its database.
