# Changelog

## 4.1.0-1

- Initial release.
- Checkmate `4.1.0`: thin wrapper on the official GHCR-only image
  (`node:24-slim`, non-root `node` user upstream) — adds only `jq`, starts
  as root to read Supervisor's options (same trade-off this repository's
  Pocket ID app makes), then `exec`s upstream's own entrypoint and command
  unchanged.
- Wired to this repository's new MongoDB app by default:
  `mongo_host`/`port`/`user`/`password`/`database` build a `mongodb://` URI
  (with `authSource=admin`, since the root user created by `MONGO_INITDB_*`
  lives in the `admin` database); `db_connection_string` overrides it
  entirely for a different setup. Checkmate has no embedded-database mode —
  confirmed from its own `docker/docker-compose.yaml`, an external MongoDB
  is always required.
- `client_host` required at runtime (wrapper exits with a clear error if
  empty); `jwt_secret`/`encryption_key` auto-generate and persist under
  `/data` on first start if left blank. Live-tested and caught a real
  format mismatch: `ENCRYPTION_KEY` must be 32 bytes as standard base64
  (`openssl rand -base64 32`), not hex like `JWT_SECRET` — Checkmate's own
  validator rejected a hex value with "must be 32 bytes as padded standard
  base64".
- Fixed a first-boot bug caught by repeated live testing: the wrapper's
  `log()` helper wrote to stdout, and `gen_secret()` called it right before
  printing the secret — so on first generation only, `KEY="$(gen_secret
  ...)"` captured the log line *and* the secret together, corrupting
  `ENCRYPTION_KEY`/`JWT_SECRET` and intermittently failing Checkmate's own
  env validation. Fixed by sending `log()` output to stderr, which a
  command substitution never captures. Confirmed with 5/5 clean runs
  against a fresh `/data` volume after the fix (0/5 before it).
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` use upstream's own GitHub organization avatar.
