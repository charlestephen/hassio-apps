# Changelog

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
