# Homebridge

Thin Home Assistant wrapper around the official
[`homebridge/homebridge`](https://github.com/homebridge/docker-homebridge)
Docker image (`2026-11-02`). Follows upstream’s Docker guide: **host
networking**, data under `/homebridge`, then the image’s own `/init`.

## Why host networking

HomeKit discovery needs the container on the host network (mDNS / Bonjour).
That matches
[Install Homebridge on Docker](https://github.com/homebridge/homebridge/wiki/Install-Homebridge-on-Docker).
Do **not** put this behind Home Assistant Ingress — use the Config UI on port
`8581` on the HA host.

## Quick start

1. Install **Homebridge**.
2. Start the app (host network is already set).
3. Open `http://<home-assistant-ip>:8581` and finish the UI setup.
4. Install plugins and pair with the Apple Home app from the UI.

## Data

Supervisor `/data` is linked to `/homebridge` (config, plugins, persist).
Backups of this app include that volume.

## Options

| Option | Default | Notes |
| --- | --- | --- |
| `tz` | `America/New_York` | `TZ` for the container. |
| `enable_avahi` | `true` | Upstream `ENABLE_AVAHI` (`1`/`0`). Disable if host Avahi already owns mDNS and discovery conflicts. |
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
