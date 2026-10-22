# Changelog

## 1.21.1

- Upgrading from upstream version 1.21.0 -> 1.21.1

> Upstream v1.21.1: https://github.com/grafana/alloy/releases/tag/v1.21.1
>
> ## [1.21.1](https://github.com/grafana/alloy/compare/v1.21.0...v1.21.1) (2026-10-21)
>
>
> ### Bug Fixes 🐛
>
> * **faro.receiver:** Enforce download_from_origins on redirects and sourcemap URLs [backport] ([#7481](https://github.com/grafana/alloy/issues/7481)) ([530886e](https://github.com/grafana/alloy/commit/530886e87c22dd5bbf9783fbcc7fd4ccf1d3b824)) (@kgeckhart)
> * **prometheus.exporter.kafka:** Avoid panic on empty consumer group member assignment [backport] ([#7441](https://github.com/grafana/alloy/issues/7441)) ([9b6b80a](https://github.com/grafana/alloy/commit/9b6b80a0437a293069ce4d6a06e692c3d1fd0fba)) (@ptodev)
> * Update go version to 1.27.3 [backport] ([#7472](https://github.com/grafana/alloy/issues/7472)) ([88cfe69](https://github.com/grafana/alloy/commit/88cfe693521b490ef73ff953a907ff6b9ab50a10)) (@kalleep)
>
> ## Upgrading
>
> Read the [release notes] for specific instructions on upgrading from older versions:
>
> [release notes]: https://grafana.com/docs/alloy/v1.21/release-notes/
>
> ## Installation
>
> Refer to our [installation guide] for how to install Grafana Alloy.
>
> [installation guide]: https://grafana.com/docs/alloy/v1.21/get-started/install/

## 1.21.0

- Upgrading from upstream version 1.20.1 -> 1.21.0

> Upstream v1.21.0: https://github.com/grafana/alloy/releases/tag/v1.21.0
>
> ## [1.21.0](https://github.com/grafana/alloy/compare/v1.20.0...v1.21.0) (2026-10-16)
>
>
> ### ⚠ BREAKING CHANGES
>
> * **otelcol.receiver.kafka:** `otelcol.receiver.kafka` and `otelcol.exporter.kafka` `metadata > retry > max_retries` now defaults to `20` (was `3`) and is now actually applied. Upstream's Kafka client silently ignored it since the franz-go migration. `otelcol.exporter.kafka` now also applies `backoff`. ([#7366](https://github.com/grafana/alloy/issues/7366))
> * **otelcol.connector.signaltometrics:** `otelcol.connector.signaltometrics` `error_mode` now defaults to `ignore` (was `propagate`). A failing OTTL expression now skips the record and logs the error instead of dropping the whole payload. Set `error_mode = "propagate"` to restore the previous behavior. ([#7366](https://github.com/grafana/alloy/issues/7366))
> * **loki.write:** `loki.write` configurations that set `wal { enabled = true }` now fail to load unless Alloy runs with `--stability.level=experimental`. To keep using the WAL, add `--stability.level=experimental` to the `alloy run` command. To keep the default stability level, remove the `wal` block or set `enabled = false`. ([#7257](https://github.com/grafana/alloy/issues/7257))
> * **loki.write:** Remove tenant label from metrics ([#7232](https://github.com/grafana/alloy/issues/7232))
>
> ### Features 🌟
>
> * Add CAP_DAC_OVERRIDE in the allowed Linux capabilities list ([#7303](https://github.com/grafana/alloy/issues/7303)) ([dddc5d8](https://github.com/grafana/alloy/commit/dddc5d895ec62e7a2b24517ad2a515860e0527f6)) (@grcevski)
> * **database_observability.postgres:** Enable stat_statements by default ([#7224](https://github.com/grafana/alloy/issues/7224)) ([044d3a4](https://github.com/grafana/alloy/commit/044d3a48a50c7ec8b806f346d52169fdddd594f2)) (@matthewnolf)
> * **database_observability.sql_server:** Add `health_check` collector ([#7205](https://github.com/grafana/alloy/issues/7205)) ([c1d90e0](https://github.com/grafana/alloy/commit/c1d90e0048454580486d7f0697a54e2ce6437175)) (@rgeyer)
> * **database_observability.sql_server:** Add support for clustering mode ([#7208](https://github.com/grafana/alloy/issues/7208)) ([90100b3](https://github.com/grafana/alloy/commit/90100b3f9cbcb5f65655b94e0efa4758a02041e6)) (@matthewnolf)
> * **database_observability.sql_server:** Support monitoring multiple database blocks ([#7207](https://github.com/grafana/alloy/issues/7207)) ([bbf24e2](https://github.com/grafana/alloy/commit/bbf24e241b9534ee9b50804a5b8003cd6e033418)) (@matthewnolf)
> * **database_observability:** Add engine label for explain_plan log digests (mysql/postgres) ([#6944](https://github.com/grafana/alloy/issues/6944)) ([551c3ad](https://github.com/grafana/alloy/commit/551c3adfbe6bb3c14377e6a0087fb8704aa57a11)) (@rgeyer)
> * **database_observability:** Add relabel blocks to database_instance ([#7369](https://github.com/grafana/alloy/issues/7369)) ([320c17e](https://github.com/grafana/alloy/commit/320c17e2c17faf91bd71df10149f59d15c09f1d1)) (@matthewnolf)
> * **helm:** Add resizePolicy to alloy and config-reloader containers ([#7274](https://github.com/grafana/alloy/issues/7274)) ([9983d74](https://github.com/grafana/alloy/commit/9983d744ec1bbb6f1557662a233b4608418f9e0f)) (@younsl)
> * **loki.source.cloudflare:** Add api_url argument ([#7353](https://github.com/grafana/alloy/issues/7353)) ([befe940](https://github.com/grafana/alloy/commit/befe94025136d572a10ffa26f7114808450589c4)) (@thampiotr)
> * **otelcol.connector.signaltometrics:** `error_mode` now defaults to `ignore` (was `propagate`) ([#7366](https://github.com/grafana/alloy/issues/7366)) ([1e353a6](https://github.com/grafana/alloy/commit/1e353a6bbc44dbadb507d7c626f0d026fb93a84f)) (@ptodev)
> * **otelcol.encoding.jsonlog:** Add the `parse_ints` argument ([#7377](https://github.com/grafana/alloy/issues/7377)) ([42fe191](https://github.com/grafana/alloy/commit/42fe1910d56b9f5b1068c8df2e338128c403d4e0)) (@ptodev)
> * **otelcol.exporter.loadbalancing:** Add the `randomness` and `attributes` routing keys, and the `routing_attributes` argument ([#7377](https://github.com/grafana/alloy/issues/7377)) ([42fe191](https://github.com/grafana/alloy/commit/42fe1910d56b9f5b1068c8df2e338128c403d4e0)) (@ptodev)
> * **otelcol.receiver.kafka:** `metadata > retry > max_retries` now defaults to `20` (was `3`) ([#7366](https://github.com/grafana/alloy/issues/7366)) ([1e353a6](https://github.com/grafana/alloy/commit/1e353a6bbc44dbadb507d7c626f0d026fb93a84f)) (@ptodev)
> * **otelcol.receiver.kafka:** Deprecate `metadata > full`, which has no effect upstream. This also applies to `otelcol.exporter.kafka` ([#7366](https://github.com/grafana/alloy/issues/7366)) ([1e353a6](https://github.com/grafana/alloy/commit/1e353a6bbc44dbadb507d7c626f0d026fb93a84f)) (@ptodev)
> * **otelcol.receiver.vcenter:** Add the `proxy_url` argument ([#7377](https://github.com/grafana/alloy/issues/7377)) ([42fe191](https://github.com/grafana/alloy/commit/42fe1910d56b9f5b1068c8df2e338128c403d4e0)) (@ptodev)
> * **otelcol:** Add a `partition` block (`metadata_keys`, `cache_size`, `idle_timeout`) to the `sending_queue > batch` block of exporters ([#7377](https://github.com/grafana/alloy/issues/7377)) ([42fe191](https://github.com/grafana/alloy/commit/42fe1910d56b9f5b1068c8df2e338128c403d4e0)) (@ptodev)
> * **otelcol:** Upgrade to OTel Collector v0.162.0 ([#7366](https://github.com/grafana/alloy/issues/7366)) ([1e353a6](https://github.com/grafana/alloy/commit/1e353a6bbc44dbadb507d7c626f0d026fb93a84f)) (@ptodev)
> * Remove the experimental prometheus.exporter.catchpoint component ([#7309](https://github.com/grafana/alloy/issues/7309)) ([7b24cb1](https://github.com/grafana/alloy/commit/7b24cb15c12199f60449ea29539e1711bf4c5f2f)) (@dehaansa)
> * Update Beyla to version 3.38.0 ([#7322](https://github.com/grafana/alloy/issues/7322)) ([bd8d703](https://github.com/grafana/alloy/commit/bd8d70381d0c49b318ea759bfcbfc2f68c025de1)) (@grcevski)
>
>
> ### Bug Fixes 🐛
>
> * **database_observability.postgres:** Stop retrying explain plans with missing session settings ([#7325](https://github.com/grafana/alloy/issues/7325)) ([0bdc41d](https://github.com/grafana/alloy/commit/0bdc41d34a5fc08a4d6a2a56f148aa122e774622)) (@cristiangreco)
> * **database_observability.sql_server:** Redact native explain-plan XML ([#7230](https://github.com/grafana/alloy/issues/7230)) ([5b01d2a](https://github.com/grafana/alloy/commit/5b01d2a4639bf5efcba37f698e635fc24eff127b)) (@rgeyer, @cristiangreco)
> * **database_observability:** Correct explain plan cost semantics ([#7307](https://github.com/grafana/alloy/issues/7307)) ([2cdeba9](https://github.com/grafana/alloy/commit/2cdeba9a3cdace81abe907a5ec1af137cb577815)) (@cristiangreco, @cursoragent)
> * **database_observability:** Escape strings to avoid logfmt parsing issues ([#7302](https://github.com/grafana/alloy/issues/7302)) ([8b722eb](https://github.com/grafana/alloy/commit/8b722ebb78669f7776502474ae4383759ceb9da5)) (@fridgepoet)
> * **database_observability:** Use `strconv.Quote` on database-derived strings ([#7288](https://github.com/grafana/alloy/issues/7288)) ([7aad05f](https://github.com/grafana/alloy/commit/7aad05fa5a920657200e4cfff09fc9c549c74432)) (@cristiangreco)
> * **deps:** Update gosnowflake to v2.2.0 to fix GO-2026-6665 ([#7340](https://github.com/grafana/alloy/issues/7340)) ([4b1e336](https://github.com/grafana/alloy/commit/4b1e336f0d9f253138730b080a2ba1aaebc7924b)) (@thampiotr)
> * **local.file_match, loki.source.file:** Fix matching through Widows junctions ([#7261](https://github.com/grafana/alloy/issues/7261)) ([653850b](https://github.com/grafana/alloy/commit/653850b14ac076066fc9b460b67a14c892016b39)) (@ptodev)
> * **loki.process:** Move stage.label validation to syntax.Validator ([#7308](https://github.com/grafana/alloy/issues/7308)) ([b24cd5d](https://github.com/grafana/alloy/commit/b24cd5ded474e0558818ed78f0ea5fa3b4b54507)) (@michael-duren)
> * **loki.process:** Move stage.label_keep validation to syntax.Validator ([#7244](https://github.com/grafana/alloy/issues/7244)) ([1f29bd7](https://github.com/grafana/alloy/commit/1f29bd73ee6d38a94da7151e2e70186b96505bfd)) (@michael-duren)
> * **loki.process:** Move stage.limit validation to syntax.Validator ([#7278](https://github.com/grafana/alloy/issues/7278)) ([9423ed4](https://github.com/grafana/alloy/commit/9423ed40c2849c91dfac0a91d3b37100f0de988a)) (@michael-duren)
> * **loki.process:** Move stage.output validation to syntax.Validator ([#7243](https://github.com/grafana/alloy/issues/7243)) ([97a5026](https://github.com/grafana/alloy/commit/97a50267e44d6c2cd7a9f61793dcbb4a9cd5b776)) (@michael-duren)
> * **loki.process:** Move stage.regex to syntax.Validator ([#7342](https://github.com/grafana/alloy/issues/7342)) ([0cbb482](https://github.com/grafana/alloy/commit/0cbb4824fe190517e05b81bb8b0d770d1d522ca2)) (@michael-duren)
> * **loki.process:** Move stage.static_labels validation to syntax.Validator ([#7175](https://github.com/grafana/alloy/issues/7175)) ([2b92bfb](https://github.com/grafana/alloy/commit/2b92bfb075aeb9d0662ce4f5d130483e4ecc11f1)) (@michael-duren)
> * **loki.process:** Move stage.structured_metadata_drop validation to syntax.Validator ([#7245](https://github.com/grafana/alloy/issues/7245)) ([8b55f30](https://github.com/grafana/alloy/commit/8b55f30ebc34b6d7a283f6db2322044f351ca635)) (@michael-duren)
> * **loki.process:** Move stage.tenant validation to syntax.Validator ([#7263](https://github.com/grafana/alloy/issues/7263)) ([5f45ab2](https://github.com/grafana/alloy/commit/5f45ab2e5a0a10eea12737452dbd9cff7727c11b)) (@michael-duren)
> * **loki.source.docker:** Do not time out log streams ([#7297](https://github.com/grafana/alloy/issues/7297)) ([4b2e798](https://github.com/grafana/alloy/commit/4b2e79853f5bc9c1cbf9d474e2cbd4b57017b0ab)) (@SaiPisey2)
> * **loki.source.file:** Reduce CPU usage for long lines ([#7291](https://github.com/grafana/alloy/issues/7291)) ([f98aef2](https://github.com/grafana/alloy/commit/f98aef2c8b25188e9b9b58305e52797837f8e170)) (@kalleep)
> * **loki.source.kubernetes:** Forward log lines with out-of-order timestamps ([#7080](https://github.com/grafana/alloy/issues/7080)) ([41d9001](https://github.com/grafana/alloy/commit/41d9001c1ad36c566d4d4f9c669d91d2f23703e7)) (@johnpinto-clarity)
> * **loki.write:** Catch more runtime errors when parsing config ([#7216](https://github.com/grafana/alloy/issues/7216)) ([32c2180](https://github.com/grafana/alloy/commit/32c2180837b850181cba14b23d794652b0e8a073)) (@kalleep)
> * **loki.write:** Prevent panic on failed update ([#7128](https://github.com/grafana/alloy/issues/7128)) ([3aa1c65](https://github.com/grafana/alloy/commit/3aa1c6577ebb015e2a1124888c91db9396200394)) (@kalleep)
> * **loki.write:** Remove tenant label from metrics ([#7232](https://github.com/grafana/alloy/issues/7232)) ([ad6125b](https://github.com/grafana/alloy/commit/ad6125b4e9c9ad72592c4a83bb08bd82e700d630)) (@kalleep)
> * **loki.write:** Require experimental stability level to enable the WAL ([#7257](https://github.com/grafana/alloy/issues/7257)) ([cc12943](https://github.com/grafana/alloy/commit/cc12943dd38160c216f9861cd557d6ca7462a613)) (@dehaansa)
> * **loki.write:** Retry wal write errors ([#7316](https://github.com/grafana/alloy/issues/7316)) ([fc8eb73](https://github.com/grafana/alloy/commit/fc8eb738ccfb1b18a98d277ba920cdbad27b8935)) (@kalleep)
> * **loki.write:** Zero-initialize counters when the metrics registry is reused ([#7258](https://github.com/grafana/alloy/issues/7258)) ([04838bf](https://github.com/grafana/alloy/commit/04838bff02a3c5106a94b92c757f99104267aa43)) (@dehaansa)
> * **loki:** Add the timestamp to batch size calculation ([#7226](https://github.com/grafana/alloy/issues/7226)) ([222798c](https://github.com/grafana/alloy/commit/222798c8fb8b848a79d1f58f3176e1401ab1ba07)) (@grobinson-grafana)
> * **loki:** Include estimate for stream labels in batch size ([#7176](https://github.com/grafana/alloy/issues/7176)) ([6c131a1](https://github.com/grafana/alloy/commit/6c131a16ec808ebf858fa0f6198165b6e679c8ac)) (@grobinson-grafana)
> * **loki:** Make loki_write_sent_bytes_total and loki_write_dropped_bytes_total count uncompressed bytes ([#7228](https://github.com/grafana/alloy/issues/7228)) ([4de4474](https://github.com/grafana/alloy/commit/4de447412fd3f84687c1cf5c1b1d9b11f5cbe63b)) (@grobinson-grafana)
> * **otelcol.connector.host_info:** Mirror upstream logic and fix potential sources of over-count ([#7236](https://github.com/grafana/alloy/issues/7236)) ([4371d71](https://github.com/grafana/alloy/commit/4371d710ca120dfcdf6808e61c4f65dad682a10d)) (@jcreixell)
> * **otelcol.exporter.loki:** Release fanout lock when the context ends mid-forward ([#7259](https://github.com/grafana/alloy/issues/7259)) ([0308c4d](https://github.com/grafana/alloy/commit/0308c4d28c237320af6f7f62b0b8477bbfb191ec)) (@dehaansa)
> * **otelcol.receiver.cloudflare:** Default max_request_body_size to 20MiB ([#7194](https://github.com/grafana/alloy/issues/7194)) ([2eadc7b](https://github.com/grafana/alloy/commit/2eadc7bdcbdbf8eedd3e53bdb83d2de6b447acda)) (@sindef)
> * **otelcol.receiver.filelog:** Use alphabetical instead of lexicographic sort type ([#7212](https://github.com/grafana/alloy/issues/7212)) ([d652b74](https://github.com/grafana/alloy/commit/d652b74b9ff9589ea5f224c046b6238b99f2dc21)) (@geonusp)
> * **otelcol.receiver.vcenter:** Convert `max_query_metrics` when converting an OpenTelemetry Collector config ([#7377](https://github.com/grafana/alloy/issues/7377)) ([42fe191](https://github.com/grafana/alloy/commit/42fe1910d56b9f5b1068c8df2e338128c403d4e0)) (@ptodev)
> * **otelcol:** Convert the exporter `sending_queue > batch` block when converting an OpenTelemetry Collector config ([#7377](https://github.com/grafana/alloy/issues/7377)) ([42fe191](https://github.com/grafana/alloy/commit/42fe1910d56b9f5b1068c8df2e338128c403d4e0)) (@ptodev)
> * **otelcol:** Converters now read the upstream `keepalive` section of HTTP client and server configs ([#7366](https://github.com/grafana/alloy/issues/7366)) ([1e353a6](https://github.com/grafana/alloy/commit/1e353a6bbc44dbadb507d7c626f0d026fb93a84f)) (@ptodev)
> * **prometheus.remote_write:** Tolerate unknown WAL record types on replay ([#7189](https://github.com/grafana/alloy/issues/7189)) ([26d1a25](https://github.com/grafana/alloy/commit/26d1a2533d2c45f1e5a720aedd3ef119887e54c9)) (@kgeckhart)
>
> ## Upgrading
>
> Read the [release notes] for specific instructions on upgrading from older versions:
>
> [release notes]: https://grafana.com/docs/alloy/v1.21/release-notes/
>
> ## Installation
>
> Refer to our [installation guide] for how to install Grafana Alloy.
>
> [installation guide]: https://grafana.com/docs/alloy/v1.21/get-started/install/

## 1.20.1
- Upgrade Grafana Alloy v1.19.2 -> 1.20.1.

> Upstream v1.20.1: https://github.com/grafana/alloy/releases/tag/v1.20.1
>
> ## [1.20.1](https://github.com/grafana/alloy/compare/v1.20.0...v1.20.1) (2026-09-28)
>
>
> ### Bug Fixes 🐛
>
> * **loki:** Add the timestamp to batch size calculation [backport] ([#7248](https://github.com/grafana/alloy/issues/7248)) ([3457a1c](https://github.com/grafana/alloy/commit/3457a1ccc8da558ffbd162c040a0d8ca62a0c54f)) (@grobinson-grafana)
> * **loki:** Include estimate for stream labels in batch size [backport] ([#7247](https://github.com/grafana/alloy/issues/7247)) ([b346475](https://github.com/grafana/alloy/commit/b346475ab6242f6d9762d37e3c26bee9f65126c0)) (@grobinson-grafana)
> * **loki:** Make loki_write_sent_bytes_total and loki_write_dropped_bytes_total count uncompressed bytes [backport] ([#7249](https://github.com/grafana/alloy/issues/7249)) ([575025a](https://github.com/grafana/alloy/commit/575025a43c8b204cb2e28edd7cb3a71e56455465)) (@grobinson-grafana)
> * **otelcol.connector.host_info:** Mirror upstream logic and fix potential sources of over-count [backport] ([#7253](https://github.com/grafana/alloy/issues/7253)) ([479eb6f](https://github.com/grafana/alloy/commit/479eb6f11b2149b8326d0d229601d977e2630aaf)) (@jcreixell)
> * **otelcol.receiver.cloudflare:** Default max_request_body_size to 20MiB [backport] ([#7254](https://github.com/grafana/alloy/issues/7254)) ([237fac7](https://github.com/grafana/alloy/commit/237fac76db82fd1466f920b577e4274d77bb244d)) (@sindef)
> * **prometheus.remote_write:** Tolerate unknown WAL record types on replay [backport] ([#7237](https://github.com/grafana/alloy/issues/7237)) ([a613be5](https://github.com/grafana/alloy/commit/a613be532ebd9cfa247039c5bee9c2c2ef185625)) (@kgeckhart)
>
> ## Upgrading
>
> Read the [release notes] for specific instructions on upgrading from older versions:
>
> [release notes]: https://grafana.com/docs/alloy/v1.20/release-notes/
>
> ## Installation
>
> Refer to our [installation guide] for how to install Grafana Alloy.
>
> [installation guide]: https://grafana.com/docs/alloy/v1.20/get-started/install/

## 1.19.2

- Upgrade Grafana Alloy v1.17.1 -> v1.19.2.

## 1.17.1-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-alloy-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 1.17.0.a

- Upgrade base image from `ghcr.io/home-assistant/base:3.23` to `3.24` (Alpine
  3.24). Brings musl 1.2.5, OpenSSL 3.4, and the latest Python 3.12 patch. No
  change to Alloy configuration or behaviour.

## 1.17.0

- Upgrade Grafana Alloy from `v1.16.2` to `v1.17.0`. Key upstream changes:
  - `otelcol.*` components updated to OpenTelemetry Collector v0.121.
  - `prometheus.operator.*` components add support for scraping `ScrapeConfig`
    custom resources directly.
  - Improved health reporting: `loki.write` now surfaces per-stream send errors
    in the component health endpoint.
  - Minor CPU overhead reduction in `loki.process` when no stage drops a log
    line.
  See the [upstream release notes](https://github.com/grafana/alloy/releases/tag/v1.17.0) for the full list.

## 1.16.2.d

- Grant the AppArmor profile access to `/etc/s6-overlay` so `s6-rc-compile` can
  read the service database at boot (fixes the `s6-rc-compile … Permission
  denied` error under enforcement).

## 1.16.2.c

- Grant the AppArmor profile read access to `/init` and the s6/bashio scripts
  (`ix` → `rix`) so s6-overlay can start under AppArmor enforcement.

## 1.16.2.b

- Add an AppArmor profile (`apparmor.txt`) so the app runs confined under
  Home Assistant. It grants Alloy access to the host Docker socket
  (`/run/docker.sock` / `/var/run/docker.sock`), `/data`, `/config` and outbound
  networking. If you hit unexpected permission errors, set `apparmor: false` in
  the app config to fall back to the default profile.

## 1.16.2.a

- **Docker socket:** the built-in default config now points at
  `/var/run/docker.sock` instead of `/run/docker.sock`. Both refer to the same
  socket — the Supervisor bind-mounts the host Docker socket at
  `/run/docker.sock`, and `/var/run/docker.sock` is its symlink on the Alpine
  base image — so log collection is unchanged. Protection mode must still be
  disabled for the socket to be mounted (see DOCS).

## 1.16.2

- Align the app version with the bundled Grafana Alloy release (`v1.16.2`) so
  upstream auto-updates bump a version Home Assistant can see.

## 1.0.0

- Initial release.
- Grafana Alloy `v1.16.2` on the Home Assistant Alpine base image (`base:3.23`).
- Ships all host container logs to Loki by default via the Docker socket.
- Config precedence: `/config/config.alloy` file → inline `alloy_config` option →
  built-in default.
- Exposes the Alloy HTTP UI / metrics on port `12345`.
