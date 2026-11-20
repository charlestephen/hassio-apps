# Home Assistant App: MongoDB

## Overview

This app wraps the official [`library/mongo`](https://hub.docker.com/_/mongo)
image `8.0` (SSPL-1.0). Thin wrapper: the upstream image already has a shell,
root user, and `jq` — this app maps **Root username**/**Root password**/
**Initial database** to the standard `MONGO_INITDB_*` environment variables
upstream's own entrypoint reads, then `exec`s that entrypoint and `mongod`
unchanged.

mongod's own default `--dbpath` is `/data/db` (confirmed via `mongod --help`
on the actual image), so no extra flag is needed — but the HA data map is
mounted directly at `/data/db` (not the usual bare `/data`), not `/data`.
Upstream's own image declares `VOLUME /data/db`; a bind mount at the parent
`/data` gets shadowed by Docker/Podman's own anonymous volume at that nested
path — confirmed live: database files existed inside the container but
never appeared on the host mount until the map path was changed to match
`/data/db` exactly.

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `root_username` | `root` | Root user, created on first start only. |
| `root_password` | `changeme` | **Change this before starting.** Only takes effect the very first time `/data/db` is empty. |
| `database` | *(empty)* | Optional database to create on first start. Most apps create their own on first connect, so this is rarely needed. |

Changing `root_username`/`root_password` after the database has already
initialized has no effect — these are seed-only values, exactly like this
repository's own PostgreSQL app's `superuser_password` option. Manage users
afterward via `mongosh` (`docker exec`/SSH into the app).

## Using it from another app

Point a dependent app at this app's hostname (the repository prefix + slug,
e.g. `dd815a57-mongodb`), port `27017`, with the root credentials set here —
or create a dedicated, less-privileged user via `mongosh` first, which is
the better practice for anything beyond a single-user homelab setup.

## Data

The HA data map is mounted at `/data/db` (not the usual `/data`) and holds
all database files, included in backups. `/data/configdb` (replica-set
config-server metadata, unused in standalone mode) is not persisted.

## Notes

- Upstream: [MongoDB](https://www.mongodb.com/), image source
  [docker-library/mongo](https://github.com/docker-library/mongo).
- No auto-update tracking is wired up for this app: `mongodb/mongo`'s GitHub
  tags use an `r` prefix (e.g. `r8.0.8`) that doesn't match Docker Hub's own
  tag format (`8.0.8`, no prefix) and also mixes in newer `9.x` alpha/dev
  tags — confirmed live, not a clean match for this repository's existing
  version-tracking script. `build_from` is pinned to the floating `8.0` Docker
  Hub tag (which Docker Hub itself keeps current with 8.x patches); bump it
  by hand when moving to a new MongoDB major version.
