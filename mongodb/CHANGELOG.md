# Changelog

## 8.0

- Initial release.
- MongoDB `8.0`: thin wrapper on the official image — no `RUN` steps at all
  (upstream's own image already has `jq`); maps `root_username`/
  `root_password`/`database` to the standard `MONGO_INITDB_*` environment
  variables, then `exec`s upstream's own entrypoint and `mongod` unchanged.
  `mongod`'s own default `--dbpath` is `/data/db` (confirmed via
  `mongod --help`), so no extra flag is needed -- but the HA data map is
  mounted directly at `/data/db`, not the usual bare `/data`: upstream's own
  image declares `VOLUME /data/db`, and live-testing caught that a bind
  mount at the parent `/data` gets shadowed by Docker/Podman's own anonymous
  volume at that nested path (database files existed in the container but
  never reached the host mount until the map path matched `/data/db`
  exactly).
- No auto-update tracking wired up (documented in DOCS.md): `mongodb/mongo`'s
  GitHub tags use an `r` prefix that doesn't match Docker Hub's own tag
  format and also mixes in newer alpha/dev tags, confirmed live not a clean
  match for this repository's existing version-tracking script.
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` use MongoDB's own GitHub organization avatar.
