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
DOCKER_HOST=tcp://dd815a57-docker-socket-proxy:2375
```

`dd815a57-docker-socket-proxy` is the app's slug with this repository's prefix
(`dd815a57`, shown on the app's Info page); a fork added under another URL has
a different prefix. The bare name `docker-socket-proxy` does not resolve.

Do not publish `2375` on the host or LAN — the proxy has no TLS or
authentication. Access control is the allow-list below plus hassio-network
reachability.

Examples:

| Consumer | How to wire |
| --- | --- |
| Traefik Manager / Agent | Set **Docker host** / `docker_host` to `tcp://dd815a57-docker-socket-proxy:2375` (proxy restart method). |
| Homarr | Prefer this proxy over mounting the socket; same `DOCKER_HOST` (or Homarr's Docker hostname/port fields pointing at this slug). |
| OTLP Collector | Docker stats read through this proxy by default (its **Docker host** option). Turn this app's **Containers** option on. |
| Any container on hassio | `export DOCKER_HOST=tcp://dd815a57-docker-socket-proxy:2375` |

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

## HAProxy overlay

This app ships a small `haproxy.cfg.template` overlay on top of Tecnativa
`v0.5.0`. The allow-list ACLs match upstream; the overlay only:

- Declares intentional root (`uid 0`, `chroot /`) so HAProxy 3.4 does not
  warn about implicit root / missing chroot.
- Sets non-zero `docker-events` timeouts (`connect 10s`, `server 24h`)
  instead of `timeout server 0` (which warns and can hang soft-stop).
- Omits the unused empty global server-state file.
- Sets `hard-stop-after 5s` so SIGTERM finishes even with `/events` open.

Startup still ends in `exec docker-entrypoint.sh haproxy -f /tmp/haproxy.cfg`.

Full upstream reference:
[Tecnativa/docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy).
