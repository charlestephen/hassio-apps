# Home Assistant App: Acme.sh

Issues and renews certificates with the official acme.sh image, then runs
the deploy hooks named in the config. Account state and certificates are
stored in the add-on data directory. Each certificate is also copied to
`/ssl/<domain>/fullchain.pem` and `/ssl/<domain>/privkey.pem`.

The client runs `acme.sh --upgrade` on every start and before each renewal,
so it follows upstream without a pinned release. Renewal is about every six
hours.

## Configuration

| Option | Description |
|---|---|
| `email` | Account email. Certificates are not issued until this is set. |
| `ca` | `letsencrypt`, `letsencrypt_test`, or `zerossl`. |
| `certificates` | One entry per certificate. |
| `env_vars` | Environment variables exported before every acme.sh command. Names must be shell identifiers. Values are visible on the config screen. |

Each certificate:

| Option | Description |
|---|---|
| `domain` | Primary name. A leading `*` is allowed. |
| `alt_domains` | Extra names, separated by spaces or commas. |
| `challenge` | `dns`, `standalone`, or `webroot`. |
| `dns_hook` | DNS API name when the challenge is `dns`, such as `dns_technitium` or `dns_cf`. |
| `webroot` | Directory when the challenge is `webroot`. Must be under `/share`, `/data`, `/config`, or `/ssl`. |
| `deploy_hooks` | Deploy hook names, separated by spaces or commas. Example: `unifios`. |
| `reload_cmd` | Shell command saved on the certificate and run after it is installed. |
| `home_assistant` | Also copy this certificate to `/ssl/fullchain.pem` and `/ssl/privkey.pem`. If more than one entry sets this, the last one wins and the log says so. |

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

For Technitium, set `challenge` to `dns` and `dns_hook` to `dns_technitium`.
Put `Technitium_Server`, `Technitium_Token`, and optionally `Technitium_Expiry_Ttl`
in `env_vars`.
