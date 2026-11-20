# Changelog

## 0.93.0-1

- Initial release.
- Activepieces `0.93.0`: thin wrapper on the official Debian-based image,
  `exec`s upstream's own entrypoint (`tini -- docker-entrypoint.sh`)
  unchanged, which picks `WORKER_AND_APP` mode by default (server + worker
  in one process, confirmed from reading that entrypoint script directly).
- Runs fully standalone by default: `db_type: pglite` (embedded database)
  and `redis_type: memory` (embedded queue), matching upstream's own
  standalone configuration path — no external dependencies required.
  Setting `db_type: postgres`/`redis_type: standalone` plus the matching
  host/port options wires this repository's own PostgreSQL/Valkey apps in
  instead.
- `frontend_url` required at runtime (wrapper exits with a clear error if
  empty); `encryption_key`/`jwt_secret` auto-generate and persist under
  `/data` on first start if left blank, matching the Authentik/Pocket ID
  apps' own pattern for secrets.
- `execution_mode` exposes only the two Activepieces sandbox modes that need
  no special container privileges (`UNSANDBOXED`, `SANDBOX_CODE_ONLY`); the
  two that need `CAP_SYS_ADMIN`/privileged mode are left to `env_vars`.
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` use upstream's own GitHub organization avatar.
