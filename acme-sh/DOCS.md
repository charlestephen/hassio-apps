# Home Assistant App: Acme.sh

Issues and renews certificates with the official acme.sh image, then runs
the deploy hooks named in the config. Account state stays in the add-on
data directory. Each certificate is stored in acme.sh's default directory:
`/data/acme.sh/<domain>` is a symlink to `/ssl/acme.sh/<domain>`, which holds
`<domain>.cer`, `<domain>.key`, `fullchain.cer`, and `ca.cer`. The add-on
does not create `/ssl/<domain>/`.

The client runs `acme.sh --upgrade` on every start and before each renewal,
so it follows upstream without a pinned release. Renewal is about every six
hours.

## Configuration

| Option | Description |
|---|---|
| `email` | Account email. Certificates are not issued until this is set. |
| `ca` | `letsencrypt`, `letsencrypt_test`, or `zerossl`. |
| `certificates` | One entry per certificate. |
| `env_vars` | Environment variables exported before every acme.sh command. Names must be shell identifiers. Values are masked on the config screen; set `secret: true` on tokens and passwords so they are flagged as secret and never written to the log. |

Each certificate:

| Option | Description |
|---|---|
| `domain` | Primary name. A leading `*` is allowed. An IPv4 or IPv6 address is also allowed; see IP certificates below. |
| `alt_domains` | Extra names, separated by spaces or commas. |
| `challenge` | `dns`, `standalone`, `webroot`, or `dns_persist`. |
| `dns_hook` | DNS API name when the challenge is `dns`, such as `dns_technitium` or `dns_cf`. |
| `dns_sleep` | Seconds to wait for the TXT record instead of checking public DNS. Leave unset to poll Cloudflare/Google DoH. Saved on the certificate, so renewals reuse it. |
| `certificate_profile` | CA profile to request, passed as `--cert-profile`. Saved on the certificate, so renewals reuse it. |
| `renewal_days` | Days after issuance when renewal is due, passed as `--days`. Saved on the certificate, so renewals reuse it. |
| `webroot` | Directory when the challenge is `webroot`. Must be under `/share`, `/data`, `/config`, or `/ssl`. |
| `deploy_hooks` | Deploy hook names, separated by spaces or commas. Example: `unifios`. |
| `reload_cmd` | Shell command saved on the certificate and run after it is installed. |
| `home_assistant` | Copy this certificate to `/ssl/fullchain.pem` and `/ssl/privkey.pem`. If more than one entry sets this, the last one wins and the log says so. |

`standalone` binds port 80 on the host. That port has to be free.

## UniFi OS

The `unifios` hook logs into the console API. It is the remote hook. The
`unifi` hook writes files on the machine where acme.sh is running.

Set these in `env_vars`:

| Name | Value |
|---|---|
| `DEPLOY_UNIFIOS_HOST` | Management URL. UniFi OS hardware uses `https://<console>` (port 443). The hook's own default is `https://localhost:11443`. |
| `DEPLOY_UNIFIOS_USERNAME` | Console admin username. |
| `DEPLOY_UNIFIOS_PASSWORD` | Console admin password. |

Deploy hook name: `unifios`.

## Custom hooks

Put `deploy/<name>.sh` in the add-on config directory. It is linked into
acme.sh's deploy directory on start and again after each upgrade. The script
must define `<name>_deploy`, and `<name>` is what you put in `deploy_hooks`.

## DNS API example

For Cloudflare, set `challenge` to `dns` and `dns_hook` to `dns_cf`.
Put `CF_Token` and `CF_Account_ID` in `env_vars`, using a user API token
from Cloudflare Profile → API Tokens → User API Tokens with the
Zone → DNS → Edit permission, limited to the zones being issued for.
`CF_Account_ID` is shown under API on a zone's Overview page. For a single
zone, `CF_Zone_ID` can be set instead of `CF_Account_ID`.

## DNS-PERSIST

Set `challenge` to `dns_persist` (draft-ietf-acme-dns-persist-01). No DNS API
credentials are used: a permanent TXT record at `_validation-persist.<domain>`
authorizes the CA to validate without a fresh challenge record each time.

On start the add-on logs the exact record to create, from
`acme.sh --make-dns-persist-value`. Create it once, then issuing succeeds and
renewals need no DNS changes. The value is tied to the ACME account, so it
changes if the account is recreated. Wildcards get `policy=wildcard`
automatically. Only CAs that offer `dns-persist-01` can use this.

## IP certificates

`domain` (and `alt_domains`) may be an IPv4 or IPv6 address. IP identifiers
cannot use a DNS challenge, so set `challenge` to `standalone` or `webroot`
and make sure the CA can reach the address on port 80.

Let's Encrypt only issues IP certificates under its short-lived profile
(160 hours), so also set `certificate_profile` to `shortlived` and
`renewal_days` to `3` so renewal happens well before expiry.
