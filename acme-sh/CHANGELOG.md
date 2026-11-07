# Changelog

## 1.0.9

- Skip legacy migration when `/addon_configs/<slug>` is the same inode as `/config`.

## 1.0.8

- Refresh idempotent legacy migration helpers (comment trim).

## 1.0.7

- Fix start failure when `/config` already has files: make legacy
  `addon_configs` migration idempotent (no failing copy/rm under `set -e`).

## 1.0.6

- One-shot migrate: copy legacy `addon_configs/…_acme-sh` into `/config`, then remove that host directory.

## 1.0.5

- Prefer Supervisor `app_config` map (replaces deprecated `addon_config`).

## 1.0.4

- Add `ca: custom` plus `acme_server` for a custom ACME directory URL
  (ACME proxy, Step CA, or other provider). Passed through as
  `--server` on account register, default CA, and issue.

## 1.0.3

- Add a per-certificate `dns_sleep` option, passed to acme.sh as
  `--dnssleep`.
- Add `dns_persist` as a challenge type (dns-persist-01). The record to
  create is printed in the log on start.
- Allow IP addresses as certificate names (standalone or webroot only),
  with `certificate_profile` and `renewal_days` options for short-lived
  IP certificates.

## 1.0.2

- Mask `env_vars` values on the config screen and add a per-entry
  `secret` toggle. Secret values are never written to the log.

## 1.0.1

- Store each certificate in acme.sh's default directory, with
  `/data/acme.sh/<domain>` linked to `/ssl/acme.sh/<domain>`.
- Stop writing a second copy to `/ssl/<domain>/`.

## 1.0.0

- Add the Acme.sh app. It issues and renews certificates from the config
  screen, runs deploy hooks, and copies the files into `/ssl`.
- The client upgrades itself on start and before each renewal.
