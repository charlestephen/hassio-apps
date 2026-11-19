# Changelog

## 2.11.4-1

- Initial release.
- Terrastate 2.11.4: self-hosted Terraform HTTP state backend. Thin wrapper
  on upstream's own Alpine-based image — add `jq` only, run as root (needed
  for `/data/options.json` and the `/data` volume; upstream's own image runs
  as its own non-root `terrastate` user), `exec` upstream's unchanged
  entrypoint/binary (`/usr/bin/terrastate server`).
- `access_username`/`access_password` (basic auth, strongly recommended —
  the backend is unauthenticated without them, confirmed live),
  `encryption_secret` (optional at-rest encryption), `storage_path` (default
  `/data/storage`, on the HA `/data` volume), `server_host`, `metrics_token`,
  `log_level`.
- Confirmed live against the actual upstream image, not just its docs: the
  real state API path is `/remote/<key>` (GET/POST/DELETE/LOCK/UNLOCK), not
  the plain root path some other Terraform HTTP backends use; the image's
  own baked-in `TERRASTATE_STORAGE` default is not read by the binary at
  all — only `TERRASTATE_SERVER_STORAGE` (used here) actually controls where
  state is written, found by writing a test state under each candidate
  variable and checking which one the file actually landed under.
- Health/readiness (`/healthz`, `/readyz`) and Prometheus metrics
  (`/metrics`) are served on their own port `8081`, matched to this app's
  `watchdog`.
- Default host ports are `8084`/`8085` (container stays `8080`/`8081`) since
  this repository's own checker caught `8080` already defaulting on Traefik
  and Ultimate CA Manager.
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` use upstream's own GitHub organization avatar
  (webhippie).
