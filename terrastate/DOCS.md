# Home Assistant App: Terrastate

## Overview

This app wraps [webhippie/terrastate](https://github.com/webhippie/terrastate)
`2.11.4` (Apache-2.0) — a small Terraform HTTP state backend, as an
alternative to S3 or Terraform Cloud when you are not hosting on AWS.

Upstream's own image is Alpine-based and already has its own shell and a
non-root `terrastate` user. This app adds only `jq` (to read Supervisor's
options) and runs as root (needed to read `/data/options.json` and write to
the `/data` volume), then **`exec`s** upstream's own entrypoint and binary
unchanged: `/usr/bin/terrastate server`.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `access_username` / `access_password` | string / password | empty | Basic auth for the state backend. **Strongly recommended** — see Security below. |
| `encryption_secret` | password | empty | When set, state files are encrypted at rest. |
| `storage_path` | string | `/data/storage` | Where state files are written, on the HA `/data` volume. |
| `server_host` | string | empty | Public URL clients use to reach this app; informational only. |
| `metrics_token` | password | empty | Bearer token to protect the `/metrics` endpoint. |
| `log_level` | list | `info` | `debug`, `info`, `warn`, `error`. |

## Security

Terrastate runs without authentication unless **Username** and **Password**
are both set — confirmed directly: leaving them empty answers every
`/remote/*` request with no credential check at all. Set both before
exposing this app to anything beyond a fully trusted network. This repository
generally fronts apps like this with [Traefik](../traefik/) for TLS — point
Terraform at the proxied HTTPS URL rather than exposing port `8080` directly,
and still set the username/password here regardless.

## Using it from Terraform

Confirmed against the running image (the route is `/remote/<key>`, not the
plain root path some other backends use):

```hcl
terraform {
  backend "http" {
    address        = "https://terrastate.example.com/remote/<state-name>"
    lock_address   = "https://terrastate.example.com/remote/<state-name>"
    unlock_address = "https://terrastate.example.com/remote/<state-name>"
    username       = "<access_username>"
    password       = "<access_password>"
  }
}
```

Replace `<state-name>` with any path segment you choose — each distinct value
becomes its own state file under **Storage path**
(`<storage_path>/<state-name>/terraform.tfstate`). Locking uses Terrastate's
own `LOCK`/`UNLOCK` HTTP methods, handled automatically by Terraform's `http`
backend — no extra configuration needed.

## Ports

| Container port | Host port (default) | Purpose |
| --- | --- | --- |
| `8080/tcp` | `8084` | Terraform HTTP state backend (basic auth) |
| `8081/tcp` | `8085` | Health check and Prometheus metrics |

Host ports differ from the container's own defaults (`8080`/`8081`) only to
avoid colliding with other apps in this repository that already default to
host port `8080` (Traefik, Ultimate CA Manager); change them under
**Network** if you'd rather use something else.

## Health and metrics

`GET /healthz` and `GET /readyz` (port `8081` in the container, `8085` on
the host by default) both return a plain-text `OK` with no authentication —
this is what the app's **watchdog** checks. Prometheus metrics are on the
same port at `/metrics`, optionally protected by **Metrics token** as a
Bearer token.

## Storage and backups

State files live under **Storage path** (default `/data/storage`), inside
the HA `/data` volume, so they are included in Home Assistant backups.
Backups are cold: the app stops while the backup runs, to avoid capturing a
state file mid-write.

## Notes

- Upstream: [webhippie/terrastate](https://github.com/webhippie/terrastate),
  documentation at <https://webhippie.github.io/terrastate/>.
- track-upstream follows GitHub releases (tag format `vX.Y.Z`) that also
  exist on Docker Hub as `webhippie/terrastate:X.Y.Z` (no `v` prefix there).
- The upstream image's own baked-in `TERRASTATE_STORAGE` environment variable
  is not read by the binary — confirmed by writing and reading back a test
  state with each candidate variable name. Only `TERRASTATE_SERVER_STORAGE`
  (which this app sets) actually controls where state is written.
