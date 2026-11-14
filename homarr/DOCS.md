# Home Assistant App: Homarr

Modern, self-hosted dashboard for your homelab — widgets, service integrations,
and single sign-on. This app is a thin wrapper around the official
[Homarr](https://homarr.dev) image at `2.13.0`.

## Installation

1. Add this app repository to Home Assistant.
2. Install the **Homarr** app.
3. (Optional) Adjust options in the **Configuration** tab.
4. Start the app and open the Web UI (port `7575`).

## How data is stored

- The **SQLite database is persisted** under the app's `/data` volume
  (`/data/db/db.sqlite`), so it survives restarts, updates and reinstalls.
- If you leave **Secret encryption key** blank, a stable key is generated once
  and stored at `/data/.secret_encryption_key`. Keep a backup — losing it makes
  previously encrypted secrets unreadable. Never change it after first use.
- Homarr's internal `/appdata` (redis/nginx scratch) is ephemeral by design.

## Public URL (behind Traefik)

Set **Base URL** to Homarr’s public origin with no path, e.g.
`https://homarr.example.com`. Homarr needs this for secure cookies, origin
checks, and OIDC when TLS terminates at a reverse proxy. Optionally set
**Trusted proxies** to the proxy’s IP/CIDR on the hassio network.

## Authentication

`auth_providers` selects the enabled login methods (comma-separated):

- `credentials` — built-in local users (default).
- `oidc` — single sign-on via an OpenID Connect provider.
- `ldap` — LDAP directory authentication.

Combine them, e.g. `credentials,oidc`.

### OIDC / SSO

Set at minimum:

- **Base URL**: public `https://…` origin (see above).
- **Auth providers**: include `oidc` (use `credentials,oidc` while debugging).
- **OIDC issuer URL**: your provider's issuer URI (no trailing slash for
  Pocket ID; Authentik often keeps a trailing slash).
- **OIDC client ID** / **OIDC client secret**: from the app you register.
- **OIDC display name**: label on the login button.
- **OIDC scopes**: e.g. `openid email profile groups` (Pocket ID).
- **Token endpoint auth method**: leave unset for Homarr’s default
  (`client_secret_basic`). **Pocket ID requires `client_secret_post`.**

Register Homarr's redirect URL with your IdP:
`https://<your-homarr-host>/api/auth/callback/oidc`. Group-based access uses
**OIDC groups attribute**; enable **OIDC auto-login** to skip the login screen.
During first setup with OIDC, enter the IdP **admin group** name when prompted.

### Pocket ID

In Pocket ID: create an OIDC client with callback
`https://<homarr-fqdn>/api/auth/callback/oidc`, enable **PKCE**, allow your
groups. In Homarr set roughly:

| Option | Value |
| --- | --- |
| Base URL | `https://<homarr-fqdn>` |
| Auth providers | `oidc` or `credentials,oidc` |
| OIDC issuer | `https://<pocket-id-fqdn>` (no trailing slash) |
| OIDC scopes | `openid email profile groups` |
| OIDC groups attribute | `groups` |
| Token endpoint auth method | `client_secret_post` |
| Logout redirect URL | `https://<pocket-id-fqdn>` |

Setup wizard admin group = Pocket ID group name (e.g. `homarr_admin`).

### LDAP

Include `ldap` in **Auth providers**, then set **LDAP URI**, **LDAP base DN**,
the bind DN/password, and adjust the attribute/group mappings for your directory.

## External database / Redis (optional)

By default Homarr uses its embedded SQLite and bundled Redis. To use external
services, enable **Use external database** / **Use external Redis** and fill the
corresponding host/port/credential options.

## Support

Issues: <https://github.com/charlestephen/hassio-apps/issues>.
Upstream Homarr docs: <https://homarr.dev/docs>.
