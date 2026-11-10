# Changelog

## 1.8.32

- First release: traefik-certs-dumper 1.8.32, writing certificates to the ssl folder.

## 1.8.32-1

- Fix the app not starting under the Supervisor: the Owner user ID and group ID options no longer have a null default, which the Supervisor rejects as a missing option.

## 1.8.32-2

- Run the image's own `/usr/bin/dump`, patched in place for the output folder, so its Docker healthcheck finds the process. The container was reported unhealthy before.
