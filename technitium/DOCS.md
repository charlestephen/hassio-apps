# Home Assistant App: Technitium DNS

## Overview

Technitium DNS Server is an open source authoritative and recursive DNS server. It features a web-based management interface, DNSSEC validation, DNS-over-HTTPS (DoH), **DNS-over-HTTPS/3 (DoH3)**, DNS-over-TLS (DoT), **DNS-over-QUIC (DoQ)**, and advanced DNS filtering.

This app tracks the upstream `technitium/dns-server` image and adds Microsoft's `libmsquic` library so QUIC-based DNS protocols (DoQ and DoH3) are available out of the box.

## Configuration

Example app configuration:

```yaml
log_level: info
web_service_local_addresses: "0.0.0.0"
reset_webservice_config: false

# Optional upstream DNS_SERVER_* initialization variables
# (read only when /data/technitium has no existing config):
dns_server_domain: "dns.example.lan"
dns_server_admin_password: "change-me-on-first-boot"
dns_server_recursion: AllowOnlyForPrivateNetworks
dns_server_forwarders: "1.1.1.1, 9.9.9.9"
dns_server_forwarder_protocol: Udp
dns_server_enable_blocking: true
dns_server_block_list_urls: "https://big.oisd.nl/, https://small.oisd.nl/"

# Free-form passthrough for any other DNS_SERVER_* variable
# (see upstream DockerEnvironmentVariables.md):
extra_env:
  - "DNS_SERVER_LOG_USING_LOCAL_TIME=true"
  - "DNS_SERVER_STATS_MAX_STAT_FILE_DAYS=365"
```

> **First-boot only.** Upstream documents that these variables are read by the
> DNS server only when its config file does not yet exist. After the first run
> they are ignored and the saved config in `/data/technitium` wins. Use the web
> UI for ongoing changes, or — for the web-service binding only — set
> `reset_webservice_config: true` once.

### Core options

#### `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually sufficient) messages.
- `warning`: Only shows warning and error messages.
- `error`: Only shows error messages.
- `fatal`: Only very severe error messages.

#### `web_service_local_addresses`

Comma-separated IP addresses for the Technitium web console to listen on during first-run config generation. The default is `0.0.0.0`, which matches Home Assistant's IPv4 Docker network.

#### `reset_webservice_config`

Set this to `true` once if the Technitium web UI is unreachable because an existing `webservice.config` has the wrong bind address. The app backs up `/data/technitium/webservice.config`, lets Technitium regenerate it on startup, and records a marker so the reset is not repeated on every restart.

### Upstream `DNS_SERVER_*` options (first-boot seed only)

| Option | Maps to | Description |
|---|---|---|
| `dns_server_domain` | `DNS_SERVER_DOMAIN` | Primary domain Technitium uses to identify itself. |
| `dns_server_admin_password` | `DNS_SERVER_ADMIN_PASSWORD` | Initial web-console admin password. Stored as a Home Assistant secret-style field. |
| `dns_server_prefer_ipv6` | `DNS_SERVER_PREFER_IPV6` | Use IPv6 for upstream queries when available. |
| `dns_server_recursion` | `DNS_SERVER_RECURSION` | `Allow`, `Deny`, `AllowOnlyForPrivateNetworks` (recommended for HA), or `UseSpecifiedNetworkACL`. |
| `dns_server_forwarders` | `DNS_SERVER_FORWARDERS` | Comma-separated forwarder addresses. |
| `dns_server_forwarder_protocol` | `DNS_SERVER_FORWARDER_PROTOCOL` | `Udp`, `Tcp`, `Tls`, `Https`, or `HttpsJson`. |
| `dns_server_enable_blocking` | `DNS_SERVER_ENABLE_BLOCKING` | Enable Blocked Zone and Block List Zone. |
| `dns_server_block_list_urls` | `DNS_SERVER_BLOCK_LIST_URLS` | Comma-separated block-list URLs. |
| `dns_server_optional_protocol_dns_over_http` | `DNS_SERVER_OPTIONAL_PROTOCOL_DNS_OVER_HTTP` | Enable plain DNS-over-HTTP on 80/tcp for use *behind a TLS-terminating reverse proxy only*. |

#### `extra_env` (free-form passthrough)

Any upstream `DNS_SERVER_*` variable that doesn't have a typed option above can be supplied as a `KEY=value` string in the `extra_env` list. The schema enforces the `DNS_SERVER_` prefix and `KEY=value` shape. Example:

```yaml
extra_env:
  - "DNS_SERVER_LOG_USING_LOCAL_TIME=true"
  - "DNS_SERVER_SSO_ENABLED=true"
  - "DNS_SERVER_SSO_AUTHORITY=https://auth.example.com"
  - "DNS_SERVER_SSO_CLIENT_ID=technitium"
```

See the full list in upstream's [DockerEnvironmentVariables.md](https://github.com/TechnitiumSoftware/DnsServer/blob/master/DockerEnvironmentVariables.md).

## Web UI

After starting the app, access the Technitium web management interface at `http://<hassio-ip>:5380`. On first run, you will be prompted to set an admin password (unless `dns_server_admin_password` was provided).

## DNS Configuration

To use Technitium as your network DNS:

1. Start the app.
2. Access the web UI and complete initial setup.
3. Configure your router's DHCP to advertise the Home Assistant IP as DNS server, or manually configure devices to use `<hassio-ip>:53`.

## Networking

This app runs with **host networking enabled** (`host_network: true`). That
means Technitium binds directly to host ports rather than going through
Docker's userland NAT. Two practical consequences:

1. **The app must have exclusive use of every port it listens on.** On HA OS
   this is the default; on Supervised installs you may need to disable a host
   resolver listening on `53/udp` first. If startup fails with
   "address already in use", check `ss -tulpn | grep ':53\b'` on the host.
2. **Technitium sees the real source IP of every query**, so per-client
   rules, logs and split-horizon resolution behave correctly. This is the
   main reason to enable host networking for a DNS workload.

### Ports Technitium listens on

| Port | Protocol | Description |
|------|----------|-------------|
| 5380 | TCP | Web management UI (the `webui:` URL) |
| 53 | TCP/UDP | DNS service — **required for HA-builtin DNS use case** |
| 853 | TCP | DNS-over-TLS (DoT) |
| 853 | UDP | **DNS-over-QUIC (DoQ)** — requires libmsquic |
| 443 | TCP | DNS-over-HTTPS (DoH) |
| 443 | UDP | **DNS-over-HTTPS/3 (DoH3)** — requires libmsquic |
| 53443 | TCP | DNS-over-HTTPS (alternate port) |
| 80 | TCP | DNS-over-HTTP (use behind a TLS-terminating reverse proxy only) |
| 8053 | TCP | DNS-over-HTTP (alternate port, reverse-proxy only) |
| 67 | UDP | DHCP server (optional) |

> The server itself runs on the bundled **.NET 10** runtime. `libmsquic` is
> bundled via Alpine's `libmsquic` package (maintained by Microsoft's QUIC team
> for musl libc), so DoQ and DoH3 work without extra setup.
