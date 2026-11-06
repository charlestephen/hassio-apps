# Changelog

## 2.249-5

- Fix immediate exit after “Executing command:” with nothing: Supervisor starts
  the app with an empty command, so upstream `exec "$@"` was a no-op. Default
  to upstream’s gunicorn CMD (also set in the Dockerfile). Bind-mount fallback
  + `/data/ucm-addon.log` diagnostics kept; still `SYS_ADMIN` + root.

## 2.249-4

- Run the upstream entrypoint as root. Dropping to UID 1000 made the process
  exit immediately when `/ssl` bind-mounts were not writable by `ucm`.

## 2.249-3

- Replace empty/white store icons with Ultimate CA Manager’s real brand mark
  (upstream `favicon.svg` / in-app Logo — orange U-shield).
- Refresh `apparmor.txt` (profile `ultimate-ca-manager` matching slug) so
  Supervisor loads the custom AppArmor profile.

## 2.249-2

- Fix start crash: upstream Docker VOLUMEs at `/opt/ucm/data` and `/etc/ucm`
  cannot be replaced with symlinks (`Device or resource busy`). Bind-mount
  `/ssl/ucm/{data,etc}` over them instead (`SYS_ADMIN`).

## 2.249-1

- Add **HTTPS certificate file** / **HTTPS private key file** options so the
  first-time config can point at PEM paths under `/ssl` (copied to UCM’s
  `https_cert.pem` / `https_key.pem` on each start).

## 2.249

- First Home Assistant app release wrapping
  [Ultimate CA Manager](https://github.com/NeySlim/ultimate-ca-manager)
  `v2.249`. Thin wrapper: options → env, PKI under `/ssl/ucm/` (symlinked at
  `/data/ucm`), auto-persisted `KEY_ENCRYPTION_KEY`, `exec` upstream
  entrypoint as `ucm`. Upstream tracked via `upstream_repo` + Docker Hub
  image gate. Standard image (not `-fips`).

> Upstream v2.249: https://github.com/NeySlim/ultimate-ca-manager/releases/tag/v2.249
