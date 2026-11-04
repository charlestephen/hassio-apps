# Home Assistant App: Gluetun

Lightweight VPN client for many commercial providers (and custom OpenVPN /
WireGuard configs). This app wraps the official
[`qmcgaw/gluetun`](https://hub.docker.com/r/qmcgaw/gluetun) image `v3.41.3`
([qdm12/gluetun](https://github.com/qdm12/gluetun)) and **execs upstream**
`/gluetun-entrypoint` after exporting HA options as Gluetun environment
variables.

## Requirements

- **Device** `/dev/net/tun` (declared in `config.yaml`)
- **Capability** `NET_ADMIN`
- On Supervised / HA OS this is enough for OpenVPN and WireGuard userspace.
  Kernel WireGuard may need extra host modules depending on the OS image.

Disable **Protection mode** only if the Supervisor blocks TUN; prefer leaving
it on when the app starts cleanly.

## How it works

1. Options from `/data/options.json` become Gluetun env vars
   (`VPN_SERVICE_PROVIDER`, `OPENVPN_*`, `WIREGUARD_*`, proxies, …).
2. Server list / public-IP files persist under `/data/gluetun/`.
3. Control returns to upstream `/gluetun-entrypoint`.
4. Other Home Assistant apps cannot easily share this container's network
   namespace. Use the **HTTP proxy** (`8888`) or **Shadowsocks** (`8388`)
   instead — that is the HA-friendly way to send traffic through the VPN.

## Quick start

1. Install **Gluetun**.
2. Set **VPN service provider**, **VPN type**, and credentials (OpenVPN user /
   password or WireGuard keys — see the
   [provider wiki](https://github.com/qdm12/gluetun-wiki/tree/main/setup/providers)).
3. Optionally set **Server countries** (e.g. `Netherlands`).
4. Start the app. Check logs until the VPN is up; control API listens on
   port **8000**.
5. Point a client or another app at `http://<ha-host>:8888` (HTTP proxy) when
   enabled.

## Configuration

| Option | Default | Description |
| --- | --- | --- |
| `tz` | `America/New_York` | Container timezone (`TZ`). |
| `vpn_service_provider` | `private internet access` | Provider slug (see wiki). |
| `vpn_type` | `openvpn` | `openvpn` or `wireguard`. |
| `server_countries` / `regions` / `cities` / `hostnames` | *(empty)* | Comma-separated server filters. |
| `openvpn_user` / `openvpn_password` | *(empty)* | OpenVPN credentials. |
| `openvpn_protocol` | `udp` | `udp` or `tcp`. |
| `wireguard_*` | *(empty)* | Private key, addresses, peer public key, endpoint, … |
| `vpn_port_forwarding` | `false` | Provider port-forwarding when supported. |
| `firewall_vpn_input_ports` | *(empty)* | Extra allowed input ports through the kill switch. |
| `dot` / `dot_providers` | on / `cloudflare` | DNS-over-TLS. |
| `httpproxy` | `true` | Built-in HTTP proxy on **8888**. |
| `shadowsocks` | `false` | Shadowsocks on **8388** (set a password). |
| `log_level` | `info` | Gluetun log verbosity. |
| `updater_period` | `24h` | Server-list refresh interval. |
| `extra_env` | *(empty)* | Multiline `KEY=VALUE` for any other Gluetun env. |

### Example (Private Internet Access / OpenVPN)

```yaml
vpn_service_provider: "private internet access"
vpn_type: openvpn
openvpn_user: "p1234567"
openvpn_password: "replace-me"
server_countries: Netherlands
httpproxy: true
shadowsocks: false
```

### Example (WireGuard / custom)

Use provider docs for key material, or set `vpn_service_provider: custom` and
fill WireGuard fields / `extra_env` per
[custom provider](https://github.com/qdm12/gluetun-wiki/blob/main/setup/providers/custom.md).

## Ports

| Port | Purpose |
| --- | --- |
| `8000/tcp` | HTTP control server (status / public IP) |
| `8888/tcp` | HTTP proxy (when enabled) |
| `8388/tcp` + `udp` | Shadowsocks (when enabled) |

## Notes

- Full env reference:
  [gluetun-wiki](https://github.com/qdm12/gluetun-wiki).
- track-upstream bumps this app when GitHub releases a tag that also exists
  on Docker Hub as `qmcgaw/gluetun:vX.Y.Z`.
- Do not use `:latest` mentally — this app pins a release tag.
