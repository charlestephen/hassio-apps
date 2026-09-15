# Home Assistant App: Traefik Manager Agent

The [Traefik Manager Agent (TMA)](https://traefik-manager.xyzlab.dev/agent.html)
lets the main [Traefik Manager](../traefik-manager/) app manage a Traefik
instance running on a **different** host than the one Traefik Manager itself
runs on. Install this app on that remote host instead (it does not need to
run on the same Home Assistant instance as Traefik Manager, but can).

## Installation

1. In Traefik Manager's UI, go to **Settings → Agents** and add a new server.
   Copy the generated **API key** — it is shown once.
2. Go to **Settings → Add-ons → Add-on Store → ⋮ → Repositories** on the HA
   instance next to the remote Traefik, add this repository, and install
   **Traefik Manager Agent**.
3. Paste the API key into **TMA API key**, point **Traefik API URL** at that
   host's Traefik API (`http://traefik:8080` by default), and start the app.
4. In Traefik Manager, the server should show as connected on port `8090`.

## How data is stored

- `backup_dir` → `/data/backups` — `.bak` files written before each change,
  persisted under this app's own `/data` volume.
- `config_path` → `/data/config` by default; point it at the directory (or a
  single file) Traefik's file provider actually watches for this host.

Anything you leave blank simply does not appear as a tab for this server in
the Traefik Manager UI — leaving **ACME JSON path** unset, for instance,
just means no Certificates tab for this host.

## Optional integrations

Same knobs as the main Traefik Manager app, scoped to this one remote host:
ACME JSON path (Certificates tab), access log path (Logs tab), static config
path (Static Config editor), automatic Traefik restart (`proxy`,
`poison-pill`, or `socket` method), and CrowdSec (LAPI URL + bouncer key
and/or machine credentials).

## Git backup

Only needed if this agent should push its own config to its own git
repository, rather than the more common **Use Host Repository** option set
in Traefik Manager's UI (which pushes this agent's config to the *host's*
repo on a dedicated branch instead). Set **Git backup enabled** plus the
repo URL, branch, and credentials if you want that.

## Support

Issues with this app: <https://github.com/charlestephen/hassio-apps/issues>.
Upstream Traefik Manager Agent docs:
<https://traefik-manager.xyzlab.dev/agent.html>.
