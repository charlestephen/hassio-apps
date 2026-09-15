# Home Assistant App: Homarr

Modern, self-hosted dashboard for your homelab — widgets, service integrations,
and single sign-on. This app is a thin wrapper around the official
[Homarr](https://homarr.dev) image.

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

## Authentication

`auth_providers` selects the enabled login methods (comma-separated):

- `credentials` — built-in local users (default).
- `oidc` — single sign-on via an OpenID Connect provider.
- `ldap` — LDAP directory authentication.

Combine them, e.g. `credentials,oidc`.

### OIDC / SSO

Set at minimum:

- **Auth providers**: include `oidc`.
- **OIDC issuer URL**: your provider's issuer URI (no trailing slash).
- **OIDC client ID** / **OIDC client secret**: from the app you register.
- **OIDC display name**: label on the login button.

Register Homarr's redirect URL with your IdP:
`https://<your-homarr-host>/api/auth/callback/oidc`. Group-based access uses
**OIDC groups attribute**; enable **OIDC auto-login** to skip the login screen.

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
