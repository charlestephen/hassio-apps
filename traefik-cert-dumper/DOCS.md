# Traefik Certs Dumper

Thin Home Assistant wrapper around the
[traefik-certs-dumper](https://github.com/kereis/traefik-certs-dumper) image
(`1.8.32`). It reads the certificates Traefik stores in `acme.json` and writes
them as PEM files into the Home Assistant `ssl` folder, so other apps can use
them.

The dumper only reads a file and writes files, so it has no database and no
PostgreSQL options.

## Quick start

1. Run the **Traefik** app from this repository with Let's Encrypt on. It keeps
   its certificates in `/ssl/traefik/acme.json`.
2. Install and start **Traefik Certs Dumper**. The defaults match that layout.
3. Find the certificates under `/ssl/traefik-certs/<domain>/fullchain.pem` and
   `privkey.pem`.

## Output

| Setting | Result |
| --- | --- |
| Empty **Domains** | One subfolder per domain: `/ssl/<output folder>/<domain>/` |
| One domain in **Domains** | Files straight in `/ssl/<output folder>/` |
| Several domains in **Domains** | One subfolder per listed domain |

The dumper rewrites a file only when its content changes. Upstream's default file
names are `cert.pem` and `key.pem`; this app defaults to `fullchain.pem` and
`privkey.pem`, which is what Home Assistant apps usually expect. The certificate
Traefik stores already includes the chain.

## Options

| Option | Variable |
| --- | --- |
| ACME file | `ACME_FILE_PATH` (under `/ssl`) |
| Output folder | `OUTPUT_DIR` (under `/ssl`) |
| Domains | `DOMAIN` |
| Certificate file name / Private key file name | `CERTIFICATE_FILE_NAME`, `PRIVATE_KEY_FILE_NAME` |
| Combined PEM file | `COMBINED_PEM` |
| Also write RSA keys | `CONVERT_KEYS_TO_RSA` |
| Also write PKCS12 / PKCS12 password | `COMBINE_PKCS12`, `PKCS12_PASSWORD` |
| Owner user ID / group ID | `OVERRIDE_UID`, `OVERRIDE_GID` |

## Restarting other apps

This app has no Docker socket, so the image's container restart options are not
available. Apps that read the files can reload them on their own, or use a post
hook script through the extra environment variable `POST_HOOK_FILE_PATH`.

## Extra environment variables

The box at the bottom of the options adds any other variable. Rows marked secret
stay masked in the UI and the log. They are applied last, so they override the
options above.
