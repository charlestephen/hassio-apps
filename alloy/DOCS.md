# Home Assistant Add-on: Grafana Alloy

Grafana Alloy is the OpenTelemetry Collector distribution from Grafana and the
official replacement for Promtail. This add-on runs Alloy on your Home Assistant
host and, out of the box, ships the logs of **every container on the host** to a
Loki endpoint. You can also replace the bundled config with any Alloy
configuration of your own.

## Installation

1. Add this repository to **Settings → Add-ons → Add-on Store → ⋮ → Repositories**:
   `https://github.com/charlestephen/hassio-apps`. The prebuilt images are
   public on `ghcr.io`, so no registry credentials are required.
2. Install the **Grafana Alloy** add-on.
3. **Disable Protection mode** for the add-on (see below) — this is required for
   Docker log collection.
4. Set the `loki_url` option (or supply your own config) and start the add-on.

## ⚠️ Protection mode must be disabled

The default config tails container logs through the host Docker socket. The
Supervisor only mounts the Docker socket into the add-on when **Protection mode
is turned off** (add-on **Info** tab → toggle **Protection mode** off). The
socket is mounted at `/run/docker.sock`; the built-in config references it as
`/var/run/docker.sock`, which is the symlinked equivalent on the base image.
This is the same trade-off every Docker-monitoring add-on requires: Alloy gets
read access to the Docker API of your host. If you only forward logs from files
or other sources and don't need the Docker socket, you can leave Protection mode
on and use a custom config that doesn't reference `unix:///var/run/docker.sock`.

> **Podman hosts:** the built-in default targets the Docker socket
> (`unix:///var/run/docker.sock`), which is correct for Home Assistant OS. If you
> run the container engine yourself on Podman, point the socket at
> `unix:///run/podman/podman.sock` in a custom config (see Configuration below).

## Configuration

There are three ways to configure Alloy, in order of precedence:

### 1. `/config/config.alloy` (file — highest precedence)

Drop a complete `config.alloy` into this add-on's config directory
(`/addon_configs/<slug>_alloy/config.alloy`, reachable as `/config/config.alloy`
inside the container, e.g. via the Studio Code Server / Samba add-ons). If this
file exists it is used verbatim and all options below are ignored. Best for large
or version-controlled configs.

### 2. `alloy_config` option (inline)

Paste a full Alloy (River) configuration into the **Alloy configuration** field
on the **Configuration** tab. Used verbatim when no `/config/config.alloy` exists.

### 3. Built-in default (no custom config)

When neither of the above is set, the add-on generates this config, substituting
your options:

```alloy
discovery.docker "local" {
  host = "unix:///var/run/docker.sock"
}

discovery.relabel "docker_containers" {
  targets = discovery.docker.local.targets

  rule {
    source_labels = ["__meta_docker_container_name"]
    regex         = "/(.*)"
    target_label  = "container"
  }
}

loki.source.docker "app_logs" {
  host    = "unix:///var/run/docker.sock"
  targets = discovery.relabel.docker_containers.output
  labels = {
    app  = "docker",
    host = "<your HA host name>",
  }
  forward_to = [loki.write.grafana_loki.receiver]
}

loki.write "grafana_loki" {
  endpoint {
    url = "<loki_url>"
  }
}

logging {
  level  = "<log_level>"
  format = "json"
}
```

| Option         | Default                                  | Description                                                                 |
| -------------- | ---------------------------------------- | --------------------------------------------------------------------------- |
| `loki_url`     | `http://loki:3100/loki/api/v1/push`      | Loki push endpoint used by the default config.                              |
| `log_level`    | `debug`                                  | Alloy's own log verbosity: `debug`, `info`, `warn`, `error`.               |
| `alloy_config` | _(empty)_                                | Full inline Alloy config; overrides the default when set.                  |

> **Note on `loki_url`:** the default `http://loki:3100/...` only resolves if a
> service named `loki` is reachable on the add-on's Docker network. Most setups
> should point this at a routable address such as
> `https://loki.cst.nyc/loki/api/v1/push`.

## The Alloy UI

Alloy's web UI, `/metrics` and component debug endpoints are exposed on port
**12345** (configurable under **Network**). Open it from the **Open Web UI**
button. Use it to confirm `loki.source.docker` is discovering containers and that
`loki.write` is healthy.

## State

Alloy's WAL and component state are stored in the add-on's `/data` volume, so
positions survive restarts and Alloy won't re-send already-shipped logs.

## Updating Alloy

The Alloy version is pinned in the `Dockerfile` (`ALLOY_VERSION`). Bump it, then
rebuild/update the add-on.
