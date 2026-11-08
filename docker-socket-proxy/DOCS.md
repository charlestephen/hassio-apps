# Docker Socket Proxy

Thin Home Assistant wrapper around
[Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy)
(`0.5.0`). It mounts the host Docker socket once and exposes a **filtered**
TCP Docker API on port `2375`, so other apps can talk to Docker without a
raw `/var/run/docker.sock` mount.

## Protection mode

`docker_api` only works when **Protection mode is off**. On the add-on's
**Info** page, toggle **Protection mode → OFF**, then start (or restart) the
app. If the socket is missing, the wrapper logs a warning and HAProxy will
fail to reach Docker.

## Point other apps at this proxy

On the Home Assistant Docker network, set:

```text
DOCKER_HOST=tcp://docker-socket-proxy:2375
```

`docker-socket-proxy` is this app's `slug` (Supervisor DNS name). Remap the
published host port in **Network** if you need a different host-side port;
the container still listens on `2375`.

Examples:

| Consumer | How to wire |
| --- | --- |
| Traefik Manager / Agent | Set **Docker host** / `docker_host` to `tcp://docker-socket-proxy:2375` (proxy restart method). |
| Homarr | Prefer this proxy over mounting the socket; use the same `DOCKER_HOST` value (or Homarr's Docker hostname/port fields). |
| Any container with a Docker client | `export DOCKER_HOST=tcp://docker-socket-proxy:2375` |

Do **not** publish `2375` on an untrusted or public network. The proxy has no
TLS or authentication — access control is the allow-list below plus network
reachability.

## Options

Boolean options map 1:1 to Tecnativa environment variables (`true` → `1`,
`false` → `0`). Enable only what each consumer needs.

### Always-on / usually safe

| Option | Env | Default | Notes |
| --- | --- | --- | --- |
| `events` | `EVENTS` | `true` | Event stream |
| `ping` | `PING` | `true` | `/_ping` |
| `version` | `VERSION` | `true` | `/version` |
| `containers` | `CONTAINERS` | `true` | List/inspect containers |
| `images` | `IMAGES` | `true` | List/inspect images |
| `info` | `INFO` | `true` | `/info` |
| `networks` | `NETWORKS` | `true` | Networks |
| `volumes` | `VOLUMES` | `true` | Volumes |

### Write / dangerous (off by default)

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
