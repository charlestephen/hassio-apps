# Changelog

## 2.19.2-1

- Add SMTP options (`smtp_host` / `port` / `from` / `user` / `password` /
  `tls` / `skip_cert_verify`) and **Disable UI configuration**. Pocket ID only
  applies `SMTP_*` from the environment when `UI_CONFIG_DISABLED` is set; the
  wrapper turns that on automatically if any SMTP field is filled.

## 2.19.2

- First Home Assistant app release wrapping [Pocket ID](https://github.com/pocket-id/pocket-id)
  `v2.19.2`. Thin wrapper: options → env, `/data` persistence, `exec` upstream
  entrypoint. Upstream tracked via `upstream_repo` + Docker Hub image gate.

> Upstream v2.19.2: https://github.com/pocket-id/pocket-id/releases/tag/v2.19.2
