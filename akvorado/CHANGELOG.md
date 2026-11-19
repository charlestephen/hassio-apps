# Changelog

## 2026.10.1-6

- Fix: `clickhouse.orchestrator-url` was templated as `http://localhost:8080`,
  which only resolves for processes inside this container -- ClickHouse runs
  in the sibling `clickhouse` app's own container, so its attempts to pull
  the orchestrator's dictionary data (protocol/ASN name lookups) over HTTP
  hit its own loopback instead and failed with "Connection refused". Found
  live on a production Supervisor: every console query using
  `dictGetOrDefault('default.protocols', ...)` returned
  `Internal Server Error`, traced to ClickHouse's own log
  (`HTTPDictionarySource::loadAll()` / `ExternalDictionariesLoader`), not an
  akvorado-to-ClickHouse connectivity problem as first suspected. Now renders
  `http://${OWN_HOST}:8080`, where `OWN_HOST` is this container's own
  `hostname` -- the name sibling containers already reach it by on the
  Supervisor's internal network.

## 2026.10.1-5

- Add `default_sampling_rate` option, wired into `outlet.core`. Found live
  with real SNMPv3 credentials working end to end: SNMP resolved cleanly
  (`akvorado_outlet_metadata_provider_snmp_poller_success_requests_total`
  nonzero, zero "metadata missing" errors), but every flow was still
  rejected with `error="sampling rate missing"` since the exporter doesn't
  report its own rate in-band. `0` (default) keeps akvorado's own
  behavior (reject); set to the exporter's real ratio to accept flows.

## 2026.10.1-4

- Add SNMPv3 support: `snmp_v3_user`, `snmp_v3_auth_protocol`,
  `snmp_v3_auth_passphrase`, `snmp_v3_priv_protocol`,
  `snmp_v3_priv_passphrase`. Akvorado picks SNMPv3 over v1/v2c whenever a
  username is set (upstream's own rule); `snmp_community` is still used
  when `snmp_v3_user` is left empty.

## 2026.10.1-3

- Add `snmp_community` option (default `public`), wired into
  `outlet.metadata.providers`. Found on a live Supervisor with real NetFlow
  v10 traffic: without SNMP, akvorado discards every flow it receives
  ("metadata missing", "sampling rate missing" — confirmed via
  `akvorado_outlet_core_flows_errors_total`), so this is required for any
  flow to actually reach ClickHouse, not optional enrichment.
- Corrects an earlier doc note: the BMP provider (`10179/tcp`) runs on
  upstream's own defaults already; it does not need explicit
  `outlet.routing` config to start.

## 2026.10.1-2

- Fix: leaving `inlet: {}` in the rendered config did not default to the
  three documented flow listeners (2055/4739/6343 udp); it produced a
  single UDP input bound to `:0` (an OS-assigned port), so no exported
  flows could ever reach the inlet. Found on a live Supervisor —
  `/proc/net/udp` inside the container showed no socket on any of the
  three ports. Now sets `inlet.flow.inputs` explicitly to the three
  listeners.

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
