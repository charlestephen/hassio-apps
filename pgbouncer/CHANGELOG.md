# Changelog

## 1.26.1-1

- New **Enable TLS** option accepts TLS from clients using a certificate from Home Assistant's `/ssl` folder, with a TLS mode of allow, prefer or require.
- Documented how logins are checked and that legacy MD5 passwords cannot be used.

## 1.26.1

- First release: PgBouncer 1.26.1 built from the upstream source. Finds the PostgreSQL app on its own and checks logins against the server's password hashes.
