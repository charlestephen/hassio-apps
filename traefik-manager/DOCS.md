# Home Assistant App: Traefik Manager

[Traefik Manager](https://github.com/chr0nzz/traefik-manager) is a
self-hosted web UI for managing Traefik's routes, services, middlewares,
certificates and logs, without hand-editing YAML.

## Installation

1. Go to **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add this repository, then install **Traefik Manager**.
3. Point **Traefik API URL** at your Traefik instance's internal API
   (`http://traefik:8080` by default — use the internal address, not a public
   dashboard URL behind auth).
4. Start the app and open the Web UI (port `5000`). If **Admin password** is
   left blank, a random one is generated and printed to the app log on first
   start; the setup wizard runs from there.

## How data is stored

Every persistent path defaults under this app's own `/data` volume, so it
survives restarts, updates and reinstalls:

- `settings_path` → `/data/config/manager.yml` (plus its companions:
  `agents.yml`, `templates.yml`, `notifications.yml`, `dashboard.yml`,
  `.secret_key`, `.otp_key`, `cache/`, `geoip/`).
- `config_path` → `/data/config/dynamic.yml` — the Traefik dynamic config
  this app edits. Point it (or **Config directory**) at the file(s) your
  Traefik's file provider actually watches, typically over a shared volume
  with your Traefik container.
- `backup_dir` → `/data/backups` — a `.bak` file is written here before every
  change.

## Optional integrations

Leaving a field blank disables the corresponding tab in the UI — nothing
breaks, the feature just doesn't appear:

- **Certificates tab** — set **ACME JSON path** to Traefik's `acme.json`
  (or a directory of them, one per cert resolver).
- **Logs tab** — set **Access log path** to Traefik's access log.
- **Static Config editor / Plugins tab** — set **Static config path** /
  **Plugins directory**.
- **Restart Traefik automatically** after a static-config change — set
  **Restart method** (`proxy`, `poison-pill`, or `socket`) and the matching
  **Traefik container name** / **Docker host** / **Signal file path**.
- **CrowdSec** — set **CrowdSec LAPI URL** plus a bouncer **API key** (reads
  decisions) and/or a machine **ID/password** (reads alerts, unbans).

## OIDC / SSO

Set **OIDC enabled**, then **OIDC provider URL**, **OIDC client ID/secret**,
and **OIDC display name**. Access is denied to everyone unless you also set
**Allowed emails**, **Allowed groups**, or **Allow any authenticated user**.

## Agents (remote Traefik hosts)

Register a remote server under **Settings → Agents** in the UI to get an API
key, then deploy the companion **Traefik Manager Agent** app next to that
server's Traefik instance with that key. See the Traefik Manager Agent app's
own docs.

## Support

Issues with this app: <https://github.com/charlestephen/hassio-apps/issues>.
Upstream Traefik Manager docs: <https://traefik-manager.xyzlab.dev/>.
