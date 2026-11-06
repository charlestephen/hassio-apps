# Homebridge

Thin Home Assistant wrapper around the official
[`homebridge/homebridge`](https://github.com/homebridge/docker-homebridge)
Docker image (`2026-11-02`). Same layout as upstream Docker: persistent
data is mounted at **`/homebridge`**, then the image’s own `/init` runs.
Host networking is required for HomeKit / mDNS.

## Why host networking

HomeKit discovery needs the container on the host network (mDNS / Bonjour).
That matches
[Install Homebridge on Docker](https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-Docker).
Do **not** put this behind Home Assistant Ingress — use the Config UI on port
`8581` on the HA host.

## Quick start

1. Install **Homebridge**.
2. Start the app (host network is already set).
3. Open `http://<home-assistant-ip>:8581` (or `https://` if you set cert options)
   and finish the UI setup.
4. Install plugins and pair with the Apple Home app from the UI.

## Data

Supervisor mounts this app’s data volume at **`/homebridge`** inside the
container — the same path the upstream image expects. Config, plugins, and
persist files live there (alongside Supervisor’s `options.json`). App
backups include that volume.

HA **`/ssl`** is mounted read-only so you can point the UI at existing
certificates (Let’s Encrypt / Acme.sh / etc.).

## HTTPS (Config UI)

Set both options before start (or restart after):

| Option | Example |
| --- | --- |
| `https_cert_file` | `/ssl/fullchain.pem` |
| `https_key_file` | `/ssl/privkey.pem` |

The wrapper writes those paths into the UI `ssl` block in `config.json` so
HTTPS is on for first boot. Also set **`https: true`** so the Supervisor
**Open Web UI** button uses `https://` (`[PROTO:https]`).

## mDNS / Avahi

This app uses **host networking**. Leave **Enable in-container Avahi** off
(default) and keep `host_dbus` so Homebridge uses the host’s mDNS/Avahi.
Turning in-container Avahi on usually yields *“another mdns processor on the
same host”* and breaks discovery.

## Options

| Option | Default | Notes |
| --- | --- | --- |
| `tz` | `America/New_York` | `TZ` for the container. |
| `enable_avahi` | `false` | In-container Avahi. Leave off on host network. |
| `https` | `false` | Open Web UI protocol (`true` → https). |
| `https_cert_file` | _(empty)_ | Full-chain PEM under `/ssl`. |
| `https_key_file` | _(empty)_ | Private key PEM under `/ssl`. |
| `env_vars` | `[]` | Extra environment variables. |

Everything else (plugins, bridge settings, startup script) is managed in the
Homebridge Config UI, as upstream intends.

## Home Assistant coexistence

- This app bridges *non*-HomeKit devices into HomeKit. Prefer it **or** HA’s
  built-in HomeKit Bridge for a given accessory — not both for the same device.
- Host networking is required by Homebridge; it does not replace HA’s own
  network stack.
- If mDNS looks broken after install, try **Enable Avahi → off** and restart.

## Links

- Upstream image: <https://github.com/homebridge/docker-homebridge>
- Homebridge: <https://github.com/homebridge/homebridge>
- Docker install wiki: <https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-Docker>
