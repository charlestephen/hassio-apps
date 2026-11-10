# Changelog

## pgbouncer_1_23_1-fixed

- Upgrading from upstream version 1.26.1-2 -> pgbouncer_1_23_1-fixed

> Upstream pgbouncer_1_23_1-fixed: https://github.com/pgbouncer/pgbouncer/releases/tag/pgbouncer_1_23_1-fixed
>
> **2024-08-02  -  PgBouncer 1.23.1  -  "Everything is put back in order"**
>
> - Fixes
>   * Fix a possible segmentation fault after PgBouncer reloads its configuration. ([#1105]) (bug introduced in 1.23.0)
>   * Fix all known put_in_order crashes. ([#1120]) (new crashes were introduced in 1.23.0)
>   * Add missing files to release tarball that are required for testing. ([#1124]) (missing files were introduced in 1.23.0)
>
> [#1120]: https://github.com/pgbouncer/pgbouncer/pull/1120
> [#1105]: https://github.com/pgbouncer/pgbouncer/pull/1105
> [#1124]: https://github.com/pgbouncer/pgbouncer/pull/1124
>
> **All changes**: https://github.com/pgbouncer/pgbouncer/compare/pgbouncer_1_23_0...pgbouncer_1_23_1-fixed

## 1.26.1-2

- Ignore the `extra_float_digits` startup parameter by default. Clients built on sqlx or JDBC, such as the Authentik server, send it on every connection and were refused with "unsupported startup parameter".

## 1.26.1-1

- New **Enable TLS** option accepts TLS from clients using a certificate from Home Assistant's `/ssl` folder, with a TLS mode of allow, prefer or require.
- Documented how logins are checked and that legacy MD5 passwords cannot be used.

## 1.26.1

- First release: PgBouncer 1.26.1 built from the upstream source. Finds the PostgreSQL app on its own and checks logins against the server's password hashes.
