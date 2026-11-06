# Traefik

[Traefik](https://traefik.io/) as a Home Assistant app. The official Traefik
binary is installed from GitHub Releases; options generate the static config
(or you supply your own). Dynamic routing uses Traefik’s file provider.

Upstream docs: <https://doc.traefik.io/traefik/>

## Where config lives

This app maps the Home Assistant configuration directory with
`homeassistant_config`, which appears **inside the container** as
`/homeassistant`. Do **not** use `/config/...` for Traefik routes — in current
Supervisor that is the app’s own config folder, not HA’s `configuration.yaml`
tree (older boomam-style addons used `/config` for HA config; that mapping no
longer applies here).

| Place | Path |
| --- | --- |
| On disk / Samba / VS Code | `homeassistant/traefik/` next to `configuration.yaml` |
| Inside the Traefik container | `/homeassistant/traefik/` |

Defaults:

- Dynamic routes: `dynamic_configuration_path: /homeassistant/traefik/`
- Optional custom static file: `/homeassistant/traefik/traefik.yaml`
- ACME storage: `/ssl/traefik/acme.json`

Create the `traefik` folder yourself and drop YAML there before or right after
first start. If you previously stored files under `/config/traefik/` from
`3.7.17`, move them to `homeassistant/traefik/`.

## Quick start

1. Install **Traefik** from this app repository.
2. Create `homeassistant/traefik/` (beside `configuration.yaml`) and add at
   least one dynamic YAML file (example below).
3. In the app **Configuration** tab, confirm
   `dynamic_configuration_path: /homeassistant/traefik/`.
4. Optionally enable Let's Encrypt and set provider env vars (see below).
5. Start the app. Open the dashboard via the HA sidebar (Ingress) or
   `http://<ha-host>:8080/dashboard/`.

### Starter dynamic config

Save as `homeassistant/traefik/fileConfig.yaml` (create the directory first).
Replace `home.example.com` with your hostname:

```yaml
http:
  routers:
    httpsredirect:
      entryPoints:
        - "web"
      middlewares:
        - "httpsRedirect"
      rule: "HostRegexp(`{host:.+}`)"
      service: httpsredirect

    homeassistant:
      rule: "Host(`home.example.com`)"
      entryPoints:
        - "websecure"
      tls:
        certResolver: le
      service: homeassistant

  middlewares:
    httpsRedirect:
      redirectScheme:
        scheme: https

  services:
    httpsredirect:
      loadBalancer:
        servers:
          - url: "http://homeassistant"

    homeassistant:
      loadBalancer:
        servers:
          - url: "http://homeassistant:8123"
        passHostHeader: true
```

`certResolver: le` only works when Let's Encrypt is enabled in the app options.

## Entrypoints

| Name | Port | Role |
| --- | --- | --- |
| `web` | `80` | HTTP (redirects to HTTPS in the generated static config) |
| `websecure` | `443` | HTTPS |
| `traefik` | `8080` | API / dashboard (also proxied for Ingress on 8099) |

Publish or remap these under the app **Network** tab as needed. Port 80 often
conflicts with other host services — change the host mapping if required.

## Configuration options

### `log_level` (required)

Traefik log verbosity: `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`,
`PANIC`. Default `ERROR`. Prefer `DEBUG` only while troubleshooting.

### `access_logs` (required)

When `true`, Traefik writes access logs to stdout (visible in the app Log tab).

### `forwarded_headers_insecure` (required)

When `true`, Traefik trusts incoming `X-Forwarded-*` headers instead of
overwriting them. Enable only if you trust the forwarder (for example
Cloudflare in front of Traefik).

### `insecure_skip_verify` (required)

When `true`, Traefik skips TLS verification for backend servers (self-signed
upstreams). Prefer proper certificates when you can.

### `proxy_protocol_trusted_ips` (optional)

List of IPs/CIDRs allowed to send PROXY protocol headers to the `websecure`
entrypoint.

### `dynamic_configuration_path` (required)

Directory for Traefik’s file provider (watched for changes). Default
`/homeassistant/traefik/` — the Home Assistant config directory inside the
container. Create `traefik/` next to `configuration.yaml` on the host.

### `letsencrypt`

When `enabled: true`, Traefik configures the `le` certificate resolver and
stores ACME data at `/ssl/traefik/acme.json`.

| Field | Purpose |
| --- | --- |
| `email` | ACME account email |
| `challenge_type` | `tlsChallenge`, `httpChallenge`, or `dnsChallenge` |
| `provider` | DNS provider name for `dnsChallenge` ([list](https://doc.traefik.io/traefik/https/acme/#providers)) |
| `delayBeforeCheck` | Seconds to wait before DNS TXT checks |
| `resolvers` | DNS servers for challenge checks (e.g. `1.1.1.1:53`) |

DNS challenges usually need provider credentials in `env_vars`, for example:

```yaml
env_vars:
  - CF_DNS_API_TOKEN=your-cloudflare-token
```

### `custom_config`

Expert override: when `use_config_file` is `true`, **all** generated static
options above are ignored and Traefik starts with `--configFile` pointing at
`config_file` (default `/homeassistant/traefik/traefik.yaml`). The file must
exist before start.

### `env_vars`

List of `NAME=value` strings exported into the Traefik process environment
(provider tokens, etc.).

## Persistence

| Path | Contents |
| --- | --- |
| `/homeassistant/traefik/` (host: `…/homeassistant/traefik/`) | Dynamic (and optional custom static) YAML |
| `/ssl/traefik/` | ACME storage (`acme.json`) when Let's Encrypt is on |

## Notes

- Ingress serves the dashboard via a small nginx proxy (Traefik API quirk);
  direct access remains on port `8080`.
- App version tracks the bundled Traefik release (bumped by this repository’s
  upstream tracker when [traefik/traefik](https://github.com/traefik/traefik)
  publishes a new stable tag). Wrapper-only fixes append a suffix (e.g.
  `3.7.17-1`) so Supervisor downloads a new image — it will not re-pull an
  unchanged version string.
