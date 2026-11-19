# Changelog

## 2026.10.1-1

- Fix: `BUILD_FROM` was declared in a stage scope, not before the first
  `FROM` in the file, so CI's `--build-arg BUILD_FROM=...` resolved to
  blank instead of the HA base image. The image never actually built.

## 2026.10.1

- Initial release.
- Akvorado 2026.10.1: orchestrator, inlet, outlet and console run as four s6
  services in one container; only the compiled binary is taken from
  upstream's distroless image, since it has no shell.
- `kafka_host`/`kafka_port`, `clickhouse_host`/`clickhouse_port`/
  `clickhouse_password`, and `redis_host`/`redis_port` options, defaulting to
  this repository's `kafka`, `clickhouse` and `valkey` apps.
- Exposes inlet's NetFlow/IPFIX/sFlow listeners (`2055/udp`, `4739/udp`,
  `6343/udp`) and the console web UI (`8083/tcp`).
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` use Akvorado's own mark (from its GitHub organization
  avatar), composited with the project name for the logo.
