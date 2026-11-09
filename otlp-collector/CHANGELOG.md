# Changelog

## 0.165.0-5

- Publish the collector's self-metrics on host port `8889` by default (was `8888`, shared with
  Gluetun and Tang). The container still listens on `8888`; the host port is changeable under **Network**.
- Docker stats now go through the Docker Socket Proxy app (new `docker_host` option, default
  `tcp://dd815a57-docker-socket-proxy:2375`) instead of the raw socket. The app no longer asks for
  `docker_api`, so Protection mode stays on, and it no longer exits on its first start when the socket is
  not mounted. If the proxy is not reachable the collector starts without Docker stats and logs why.

## 0.165.0-4

- Rebuild as Docker schema2 manifests (`oci-mediatypes=false`). `--provenance=false`
  alone still published OCI image manifests that GHCR returns as 404 to classic
  Docker Accept headers; Supervisor install stayed "won't download".

## 0.165.0-3

- Rebuild without Buildx provenance/SBOM attestations so GHCR tags are plain
  image manifests again. HA Supervisor could not resolve the OCI index
  (`unknown/unknown` attestation) and failed to download the add-on image.

## 0.165.0-2

- Fix generated default config for Collector Contrib `0.165.0`: replace removed
  `service.telemetry.metrics.address` with a Prometheus pull reader on `:8888`
  so the add-on starts again.
- Docs: placeholder-only OTLP endpoint examples (no private hostnames).

## 0.165.0-1

- Slim image: drop `hassio-addons/base` (s6/bashio unused) for Alpine 3.24 +
  jq + ca-certificates; still COPY the upstream contrib binary and exec it.

## 0.165.0

- Upgrading from upstream version 0.164.0 -> 0.165.0

> Upstream v0.165.0: https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.165.0
>
> The OpenTelemetry Collector Contrib contains everything in the [opentelemetry-collector release](https://github.com/open-telemetry/opentelemetry-collector/releases/tag/v0.165.0), be sure to check the release notes there as well.
>
> ## Unmaintained Components
>
> These components are marked as [Unmaintained](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/component-stability.md#unmaintained) and will eventually be removed from our community distributions. If you depend on these components we need your help to support them.
>
> - exporter/logicmonitor
> - receiver/riak
>
> ## End User Changelog
>
> ### 🛑 Breaking changes 🛑
>
> - `all`: Remove the deprecated SignalFx receiver. Use the OTLP receiver instead. (#51934)
> - `connector/service_graph`: Remove deprecated feature gates connector.servicegraph.legacyLatencyMetricNames and connector.servicegraph.legacyLatencyUnitMs (#52246)
> - `exporter/signalfx`: Stop producing `disk_ops.total` and `disk_ops.pending` metrics with the default translation rules. (#52729)
>   Use `system.disk.operations` instead of `disk_ops.total`. It is sent by default as a cumulative counter, so the per-period
>   number of operations on a host can be charted with SignalFlow, for example:
>   ```
>   data('system.disk.operations', rollup='delta').sum(by=['host.name'])
>   ```
>   Use `system.disk.pending_operations` instead of `disk_ops.pending`. Both are excluded by default, so replace
>   `disk_ops.pending` with `system.disk.pending_operations` in `include_metrics`:
>   ```yaml
>   exporters:
>     signalfx:
>       include_metrics:
>         - metric_name: system.disk.pending_operations
>   ```
>   
> - `pkg/coreinternal`: Promote internal.coreinternal.goldendataset.EmitV1DatabaseConventions and internal.coreinternal.goldendataset.DontEmitV0DatabaseConventions feature gates from Alpha to Beta. (#52690)
>   The gates are now enabled by default, so goldendataset generates db.system.name (semconv v1.40.0)
>   instead of the deprecated db.system (semconv v1.28.0). The migration remains reversible by disabling
>   the gates.
>   
> - `pkg/coreinternal`: Promote internal.coreinternal.goldendataset.EmitV1NetworkConventions and internal.coreinternal.goldendataset.DontEmitV0NetworkConventions feature gates to Stable. (#52503)
>   The gates can no longer be disabled. goldendataset now always generates `network.local.address`,
>   `network.peer.address`, and `server.address`, and no longer generates the deprecated `net.host.ip`,
>   `net.peer.ip`, `http.host`, and `http.server_name` attributes.
>   
> - `pkg/coreinternal`: Promote internal.coreinternal.goldendataset.EmitV1RPCConventions and internal.coreinternal.goldendataset.DontEmitV0RPCConventions feature gates to Stable. (#52219)
>   The gates can no longer be disabled. goldendataset now always generates `rpc.method` and
>   `service.peer.name`, and no longer generates the deprecated `rpc.service` and `peer.service`
>   attributes.
>   
> - `pkg/jaeger`: Promote "pkg.translator.jaeger.EmitV1HttpConventions" and "pkg.translator.jaeger.DontEmitV0HttpConventions" feature gates to Beta. (#52146)
>   The Jaeger translator now emits `http.response.status_code` instead of the deprecated `http.status_code` by default.
>   
> - `pkg/zipkin`: Promote "pkg.translator.zipkin.EmitV1CloudResourceConventions" and "pkg.translator.zipkin.DontEmitV0CloudResourceConventions" feature gates to Beta. (#52148)
>   The Zipkin translator now emits `cloud.resource_id` instead of the deprecated `faas.id` by default.
>   
> - `pkg/zipkin`: Promote "pkg.translator.zipkin.EmitV1NetworkConventions" and "pkg.translator.zipkin.DontEmitV0NetworkConventions" feature gates to Stable. (#52250)
>   The gates can no longer be disabled. The Zipkin translator now always emits `network.local.address`,
>   `network.peer.address`, and `service.peer.name`, and no longer emits the deprecated `net.host.ip`,
>   `net.peer.ip`, and `peer.service` attributes.
>   
> - `processor/resource_detection`: The `system` and `docker` detectors now set `os.type` to `zos` instead of the deprecated `z_os` on z/OS. (#52804)
> - `processor/transform`: Remove the deprecated `flatten_data` config option. Use `flatten.log` instead. (#32080)
> - `receiver/file_log`: Remove stable gate filelog.protobufCheckpointEncoding (#52387)
> - `receiver/kafka_metrics`: Remove stable receiver.kafkametricsreceiver.UseFranzGo gate (#52241)
> - `receiver/prometheus`: `__scheme__` and `__metrics_path__` labels on scraped samples are no longer dropped from datapoint attributes. (#52736)
>
> ### 🚩 Deprecations 🚩
>
> - `connector/routing`: Stabilizing gate connector.routing.defaultErrorModeIgnore (#52352)
> - `processor/resource_detection`: The `system` detector adds the `os.build_id` resource attribute and deprecates `os.build.id`. (#52806)
> - `processor/resource_detection`: Deprecate the `azure.resourcegroup.name` resource attribute in favor of `azure.resource_group.name`, behind the `processor.azuredetector.RenameResourceGroupAttribute` feature gate (#49079)
>   The new `processor.azuredetector.RenameResourceGroupAttribute` feature gate is alpha
>   and disabled by default, so the azure detector continues to emit `azure.resourcegroup.name` and
>   there is no change in behavior. Enabling the gate makes the detector emit
>   `azure.resource_group.name` instead, matching the naming convention used by other semantic
>   convention attributes such as `cloud.availability_zone`. The gate is intended to be promoted to
>   beta, and enabled by default, in a future release, giving users time to migrate any
>   configuration that filters or routes on `azure.resourcegroup.name`.
>   
>
> ### 💡 Enhancements 💡
>
> - `connector/datadog`: Use `url.template` for HTTP client span resource names when it is present. (#52553)
>   From updated github.com/DataDog/datadog-agent modules: with the default resource name logic, HTTP client spans get resource names like `GET /users/{id}` from `url.template`, and otherwise just the method (DataDog/datadog-agent#54496).
>   
> - `connector/span_metrics`: Reduce consume-path allocations by reusing shared metric keys, avoiding per-event attribute map copies, and filtering resource key attributes without a full map copy. (#49860)
>   When `calls_dimensions` and `histogram.dimensions` are both empty, the duration
>   histogram reuses the calls metric key. Delta timestamp maps are allocated only
>   for delta temporality. With `events.enabled`, dimensions are resolved from span,
>   event, and resource attributes without building a merged map per event. When
>   `resource_metrics_key_attributes` is set, only the configured attributes are
>   copied into the resource key hash.
>   
> - `exporter/azuredataexplorer`: Restore the stability of the exporter from `unmaintained` to `beta` (#52282)
> - `exporter/clickhouse`: Size the ClickHouse client connection pool from `sending_queue.num_consumers` by default. (#52350)
>   The metrics exporter uses one connection per metric type per consumer.
>   `max_open_conns` and `max_idle_conns` set in `endpoint` or `connection_params` still take precedence.
>   
> - `exporter/clickhouse`: Change the default column codec in the base table schemas from `ZSTD(1)` to `ZSTD(3)`. (#52705)
>   Only applies to newly created tables, existing tables are not altered.
> - `exporter/datadog`: Use `url.template` for HTTP client span resource names when it is present. (#52553)
> …
>
> 1 older upstream releases omitted.

## 0.164.0

- Default pipeline: shared `otlp_endpoint` exports traces, metrics, and logs;
  Docker stats + Home Assistant Prometheus scrape on by default; optional
  per-signal overrides and Prometheus remote_write; `config_yaml` still
  replaces the generated config entirely.
- Best-effort `hostmetrics` / Docker `filelog` / `journald` when those host
  paths are mounted into the container.
- First Home Assistant app release wrapping OpenTelemetry Collector Contrib
  `0.164.0` (`otel/opentelemetry-collector-contrib`).
- Thin wrapper: COPY upstream binary onto HA base (official image is
  `FROM scratch`), generate config from options, `exec otelcol-contrib`.
- track-upstream via `upstream_repo` + Docker Hub image gate.

> Upstream v0.164.0: https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.164.0

