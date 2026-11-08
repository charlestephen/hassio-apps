# Docker Socket Proxy

Thin Home Assistant wrapper around
[Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)
(`0.5.0`). It mounts the host Docker socket once and serves a **filtered**
TCP Docker API on port `2375` **only on the hassio Docker network** (host port
mapping defaults to `null`). Other apps talk to Docker without a raw
`/var/run/docker.sock` mount.

## Protection mode

`docker_api` only works when **Protection mode is off**. On the add-on's
**Info** page, toggle **Protection mode → OFF**, then start (or restart) the
app. If the socket is missing, the wrapper logs a warning and HAProxy will
fail to reach Docker.

## Point other apps at this proxy

Use Supervisor DNS only (same host, hassio network):

```text
DOCKER_HOST=tcp://docker-socket-proxy:2375
```

`docker-socket-proxy` is this app's `slug`. Do not publish `2375` on the host
or LAN — the proxy has no TLS or authentication. Access control is the
allow-list below plus hassio-network reachability.

Examples:

| Consumer | How to wire |
| --- | --- |
| Traefik Manager / Agent | Set **Docker host** / `docker_host` to `tcp://docker-socket-proxy:2375` (proxy restart method). |
| Homarr | Prefer this proxy over mounting the socket; same `DOCKER_HOST` (or Homarr's Docker hostname/port fields pointing at this slug). |
| Any container on hassio | `export DOCKER_HOST=tcp://docker-socket-proxy:2375` |

Enable only the API toggles each consumer needs. In particular, leave
`containers` off unless required — `GET /containers/{id}/json` can expose
container env (including tokens/secrets).

## Options

Boolean options map 1:1 to Tecnativa environment variables (`true` → `1`,
`false` → `0`).

### Safe defaults (on)

| Option | Env | Default | Notes |
| --- | --- | --- | --- |
| `events` | `EVENTS` | `true` | Event stream |
| `ping` | `PING` | `true` | `/_ping` |
| `version` | `VERSION` | `true` | `/version` |

### Opt-in read APIs (off)

| Option | Env | Default | Notes |
| --- | --- | --- | --- |
| `containers` | `CONTAINERS` | `false` | List/inspect — can leak env secrets |
| `images` | `IMAGES` | `false` | List/inspect images |
| `info` | `INFO` | `false` | `/info` |
| `networks` | `NETWORKS` | `false` | Networks |
| `volumes` | `VOLUMES` | `false` | Volumes |

### Write / dangerous (off)

| Option | Env | Default | Notes |
| --- | --- | --- | --- |
| `post` | `POST` | `false` | Allow non-GET verbs on enabled sections |
| `auth` | `AUTH` | `false` | Registry auth |
| `secrets` | `SECRETS` | `false` | Swarm secrets |
| `exec` | `EXEC` | `false` | `docker exec` |
| `build` / `commit` | `BUILD` / `COMMIT` | `false` | Image build/commit |
| `allow_start` / `allow_stop` / `allow_restarts` | `ALLOW_*` | `false` | Container lifecycle |
| `allow_pause` / `allow_unpause` | `ALLOW_*` | `false` | Pause/resume |
| `system` / `swarm` / … | matching names | `false` | Remaining Engine API prefixes |

### Other

| Option | Env | Default |
| --- | --- | --- |
| `log_level` | `LOG_LEVEL` | `info` |
| `disable_ipv6` | `DISABLE_IPV6` | `false` |
| `socket_path` | `SOCKET_PATH` | `/var/run/docker.sock` |

Full upstream reference:
[Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy).
