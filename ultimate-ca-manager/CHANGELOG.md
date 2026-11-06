# Changelog

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
