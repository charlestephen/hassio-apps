# Hawser Agent for Dockhand

This app lets [Dockhand](https://dockhand.pro) manage the Docker host that
Home Assistant runs on — containers, images, networks, volumes and Compose
stacks. It does so by running the [Hawser](https://github.com/Finsys/hawser)
agent inside the add-on.

The Hawser binary is baked into the image at the version shown on the Info
page. Upstream Hawser releases are tracked automatically; installing an app
update upgrades the agent.

## ⚠️ Required: turn off Protection mode

The agent needs access to the host's Docker socket (`/var/run/docker.sock`) to
do anything useful. Home Assistant guards that access behind **Protection
mode**, so on the add-on's **Info** page you must:

1. Toggle **Protection mode** **OFF**.
2. Confirm the warning Home Assistant shows.
3. Start (or Restart) the add-on.

If Protection mode is on, the add-on starts but every Docker call from Dockhand
will fail. This is by design — Home Assistant requires the explicit opt-in
because giving an add-on Docker socket access is equivalent to giving it root
on the host.

## Quick start

### Edge mode (default — recommended)

The agent connects **out** to your Dockhand server. Best when Home Assistant is
behind NAT, on a dynamic IP, you'd rather not open a port, or your Dockhand UI
is loaded over HTTPS (browsers will block plain-HTTP calls from an HTTPS page).

1. In Dockhand, add a new host and copy the agent token shown.
2. In this add-on's **Configuration** tab, set:
   - `mode`: `edge`
   - `token`: the agent token from Dockhand
   - `dockhand_url`: `wss://your-dockhand.example.com/api/hawser/connect`
3. Save → **Start**. Check the **Log** tab — you should see `Hawser starting in
   Edge mode → wss://…` and the host appears in Dockhand.

### Standard mode

The agent **listens** for connections from Dockhand. Best for a LAN/homelab
where Home Assistant has a stable address and Dockhand can reach it directly.

1. In the add-on Configuration: `mode: standard`, optionally set `token` (an
   auth token Dockhand will need to send), optionally set TLS files.
2. Save → **Start**.
3. In Dockhand, add the host at **`http://<home-assistant-ip>:2376`** (or
   `https://<ip>:2376` if you configured TLS). The default port is `2376` —
   matching Hawser's own default and what Dockhand expects.
4. If you change `port`, remember to also change the **Network → 2376/tcp**
   mapping on the add-on page to match.

> **Mixed content note (Standard mode):** if your Dockhand UI is loaded over
> HTTPS, browsers will refuse to fetch from a plain `http://…:2376` agent. You
> either need TLS on the agent (see options below) or Edge mode, which sidesteps
> the problem entirely.

## Options

| Option | Default | Notes |
|---|---|---|
| `mode` | `edge` | `edge` or `standard`. |
| `agent_name` | _hostname_ | Name shown in Dockhand. |
| `token` | _empty_ | **Edge:** required, agent token from Dockhand. **Standard:** optional auth token. |
| `dockhand_url` | _empty_ | **Edge only:** Dockhand WebSocket URL. Ignored in Standard mode. |
| `port` | `2376` | **Standard only:** listen port. |
| `bind_address` | `0.0.0.0` | **Standard only:** bind address. |
| `tls_cert` | _empty_ | **Standard only:** path to TLS cert (relative → `/ssl`). |
| `tls_key` | _empty_ | **Standard only:** path to TLS key (relative → `/ssl`). |
| `docker_socket` | `/var/run/docker.sock` | Docker socket path. |
| `stacks_dir` | `/data/stacks` | Where Compose stack files live (on persistent `/data`). |
| `log_level` | `info` | `debug`, `info`, `warn`, `error`. |
| `skip_df_collection` | `false` | Skip disk metrics (useful on NAS hosts). |

> Home Assistant doesn't support hiding form fields conditionally — Edge and
> Standard fields all show in the UI. Fields not relevant to your `mode` are
> simply ignored; only the ones marked above as required for that mode matter.

### Certificates

Put cert files in Home Assistant's `ssl` share and reference them by file name
(e.g. `tls_cert: server.crt`), or use an absolute path. Relative paths are
resolved under `/ssl`.

## Sidebar

The add-on adds a **Hawser** entry to the HA sidebar showing a small status
page. Hawser has no interactive UI of its own — manage the host from Dockhand.
The add-on's **Log** tab is where you watch connection status and the bundled
Hawser version.

## Persistent state

- `/data/agent_id` — a UUID generated on first start, kept stable across
  restarts/updates so Dockhand keeps recognising the host.
- `/data/stacks` — Compose stack files managed through Dockhand (default
  `stacks_dir`).

## Troubleshooting

- **"Fetch error" in Dockhand when adding the host (Standard mode).** Almost
  always either mixed content (Dockhand UI is HTTPS, agent is HTTP) or
  Dockhand's server can't reach the HA host's IP. Use Edge mode, or put TLS
  on the agent.
- **Docker calls fail / "permission denied" on the socket.** Protection mode
  is on. Turn it off (see the section above) and restart the add-on.
- **Add-on keeps restarting.** Check the **Log** tab. In Edge mode, missing
  `dockhand_url` or `token` will halt the agent on purpose.

## Updating

The app version mirrors the pinned upstream Hawser release. When
[Finsys/hawser](https://github.com/Finsys/hawser) publishes a new version, the
repository's upstream tracker bumps this app and CI rebuilds the image. Home
Assistant then offers the update.

## Links

- Upstream Hawser: <https://github.com/Finsys/hawser>
- Dockhand: <https://dockhand.pro> · Manual: <https://dockhand.pro/manual/>
