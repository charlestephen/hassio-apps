# Home Assistant App: RSS-Bridge

## Overview

This app wraps [RSS-Bridge/rss-bridge](https://github.com/RSS-Bridge/rss-bridge)
(Unlicense/public domain). RSS-Bridge generates Atom/RSS feeds for websites
that don't provide their own, via "bridges" — small PHP modules, one per
supported site.

Upstream's own image (Debian, nginx + php-fpm) already supervises both
processes via its own entrypoint, so this app makes no changes at all: no
options, no custom entrypoint — just the image with Home Assistant labels
and a persistent config volume.

Upstream has no semver releases; it tags both GitHub releases and this
image by date (e.g. `2025-08-05`), confirmed live against both GitHub's
releases API and Docker Hub's own tag listing.

## Configuration

Everything is file-based, not option-based — there's nothing to set in the
app's own configuration panel. On start, upstream's entrypoint copies any of
the following out of the mapped config volume into the running app, owned by
`www-data`:

| File (in `/config`) | Goes to |
|---|---|
| `config.ini.php` | `/app/config.ini.php` |
| `whitelist.txt` | `/app/whitelist.txt` |
| `*Bridge.php` | `/app/bridges/` |
| `*Format.php` | `/app/formats/` |
| `DEBUG` | `/app/DEBUG` |

None of these need to exist — with nothing in `/config`, RSS-Bridge just
runs with its own built-in defaults (every bridge enabled, no auth, file
cache). Reach `/config` via this app's Samba/SSH-visible config directory.

### Enabling authentication

RSS-Bridge has no admin UI for this — it's set directly in `config.ini.php`.
Create that file in `/config` with, for example:

```ini
[authentication]
enable = true
username = "admin"
password = "change-me"
```

or a shared token instead of a username/password:

```ini
[authentication]
token = "a-long-random-token"
```

Restart the app after changing it (upstream only copies these files in at
container start, not on a live file-watch).

### Limiting which bridges are enabled

By default every bridge is available. To restrict the list, add to
`config.ini.php`:

```ini
[system]
enabled_bridges[] = "TwitterBridge"
enabled_bridges[] = "YoutubeBridge"
```

See upstream's own
[configuration docs](https://github.com/RSS-Bridge/rss-bridge/blob/master/DOCKER.md)
for the complete set of `config.ini.php` sections (cache backend, proxy,
error output format, rate limiting).

## Ports

| Port | Purpose |
|---|---|
| `80/tcp` | Web UI and feed endpoints (host port `8086` by default — change under **Network** if you'd rather use something else). |

## Data

`/config` is this app's one persistent/editable directory, included in
backups. RSS-Bridge's own file-cache (when `[cache] type = file` is set)
lives inside `/app/cache`, which is **not** persisted — it's fine for it to
be rebuilt from scratch on restart, since it's only a cache of fetched feed
content, not source-of-truth data.

## Notes

- Upstream: [RSS-Bridge/rss-bridge](https://github.com/RSS-Bridge/rss-bridge).
- Runs as root inside the container (upstream's own image sets no `USER`;
  its entrypoint `chown`s copied config files to `www-data` itself).
- The image also ships `curl-impersonate` (Chrome user-agent spoofing),
  enabled by default via baked-in `LD_PRELOAD`/`CURL_IMPERSONATE` env vars —
  this is upstream's own behavior, not something this wrapper adds or can
  turn off without overriding the image's environment directly.
