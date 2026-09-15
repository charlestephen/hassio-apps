# Home Assistant App: Linkding

[Linkding](https://github.com/sissbruecker/linkding) is a self-hosted bookmark
manager. This app runs the upstream `ghcr.io/sissbruecker/linkding:latest-alpine`
image wrapped with the Home Assistant app framework, using **SQLite** by default.

## Data

Bookmarks live in SQLite under the app's dedicated **config directory**,
mounted at `/config` inside the app (host path `/addon_configs/<slug>_linkding`,
browsable via the Samba/SSH apps). linkding's `/etc/linkding/data` is
symlinked there, so data survives restarts and updates.

## First run

Set **`superuser_name`** + **`superuser_password`** to auto-create an admin on
first start. Then open the app (sidebar via ingress, or `http://<host>:9090`)
and log in.

## Options

| Option | Description |
| --- | --- |
| `superuser_name` | Initial admin username (created on first start). |
| `superuser_password` | Initial admin password (masked). |
| `disable_background_tasks` | Set `true` to disable linkding's background worker. |
| `env_vars` | A list of `name`/`value` pairs injected as environment variables at startup — use this for **any** linkding setting (`LD_*`) without a rebuild. |

### Env-var injection examples

```yaml
env_vars:
  - name: LD_CSRF_TRUSTED_ORIGINS
    value: "https://linkding.lan.cst.wtf"
  - name: LD_DISABLE_URL_VALIDATION
    value: "True"
```

Injected variables take precedence over the basic options above, so you can
override anything (e.g. point `LD_DB_ENGINE` at Postgres if you ever move off
SQLite).

## Web access

- **Ingress:** opens in the HA sidebar (HA handles auth).
- **Direct:** `http://<home-assistant-host>:9090`.

> Ingress note: linkding uses a static context path, so behind HA ingress static
> assets/login may not resolve until a path-rewrite proxy is added (planned
> follow-up). If the sidebar view looks broken, use the `:9090` URL.
