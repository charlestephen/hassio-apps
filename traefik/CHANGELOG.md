# Changelog

## 3.7.18-2

- Migrate a static `traefik.yml` (not only `traefik.yaml`) out of the old dynamic folder into `/config`. Without this it was loaded as a dynamic route file and never found at the custom config path.
- Fix the service `finish` scripts: they called `s6-test`, which the base image does not ship ("unable to spawn s6-test").

## 3.7.18-1

- Use the app's own config folder (`app_config`, `/config`) instead of the Home Assistant config directory. Defaults are now `/config/dynamic/` and `/config/traefik.yaml`; existing files under `/homeassistant/traefik/` are migrated once.

## 3.7.18

- Upgrading from upstream version 3.7.17-6 -> 3.7.18

> Upstream v3.7.18: https://github.com/traefik/traefik/releases/tag/v3.7.18
>
> **Important:** Please read the [migration guide](https://doc.traefik.io/traefik/v3.7/migrate/v3/#v3718).
>
> **Bug fixes:**
> - **[authentication]** Limit BasicAuth password length ([#14168](https://github.com/traefik/traefik/pull/14168) @Neffi42)
> - **[authentication]** Support connection-bound authentication schemes in Proxy-Authorization ([#14203](https://github.com/traefik/traefik/pull/14203) @Neffi42)
> - **[k8s/ingress-nginx]** Apply host-less auth-tls annotations to the default TLS option ([#14224](https://github.com/traefik/traefik/pull/14224) @rtribotte)
> - **[k8s/ingress-nginx]** Apply Ingress NGINX CORS before the redirect annotations ([#14093](https://github.com/traefik/traefik/pull/14093) @lazerg)
> - **[k8s/ingress-nginx]** Fix Ssl-Client-* headers when Ingresses share a host ([#14160](https://github.com/traefik/traefik/pull/14160) @Neffi42)
> - **[k8s/knative]** Bump knative.dev/pkg to v0.0.0-20261102011501-7b6dcbbe4ea4 ([#14220](https://github.com/traefik/traefik/pull/14220) @kevinpollet)
> - **[middleware]** Accept uppercase Q weight in compress Accept-Encoding parsing ([#14153](https://github.com/traefik/traefik/pull/14153) @locker95)
> - **[middleware]** Bump github.com/vulcand/oxy to v2.3.2 ([#14241](https://github.com/traefik/traefik/pull/14241) @ldez)
> - **[middleware, performance]** Limit zstd encoder memory in the Compress middleware ([#14167](https://github.com/traefik/traefik/pull/14167) @juliens)
> - **[plugins]** Fix deterministic randomness in WASM plugins ([#14107](https://github.com/traefik/traefik/pull/14107) @yugfletcher)
> - **[plugins]** Bump github.com/traefik/yaegi to v0.16.3 ([#14231](https://github.com/traefik/traefik/pull/14231) @juliens)
> - **[server]** Validate HTTP Host matcher values ([#13571](https://github.com/traefik/traefik/pull/13571) @Milad93R)
> - **[server]** Resolve dot-segments and empty segments with path parameters ([#14188](https://github.com/traefik/traefik/pull/14188) @Neffi42)
> - **[server, grpc]** Add regression test for gRPC bidirectional streams ([#14037](https://github.com/traefik/traefik/pull/14037) @ozenyunus35)
> - **[service]** Fix SPIFFE configuration for the TCP servers transport ([#14200](https://github.com/traefik/traefik/pull/14200) @simpleqt)
> - **[tcp]** Detect TCP connection reset on read when the error is wrapped ([#14046](https://github.com/traefik/traefik/pull/14046) @noakky)
>
> **Documentation:**
> - **[k8s/ingress-nginx]** List missing ingress-nginx annotations as unsupported ([#14163](https://github.com/traefik/traefik/pull/14163) @lazerg)
> - **[middleware]** Use a Secret for basicAuth in the Chain middleware Kubernetes example ([#14143](https://github.com/traefik/traefik/pull/14143) @lazerg)
> - **[middleware]** Fix grammar in observability and InFlightReq pages ([#14209](https://github.com/traefik/traefik/pull/14209) @m-shahi)
> - **[plugins]** Fix typos in plugin type error and documentation ([#14186](https://github.com/traefik/traefik/pull/14186) @sarankumar1325)
> - Add version to the dot-segments migration note ([#14248](https://github.com/traefik/traefik/pull/14248) @kevinpollet)
> - Fix Docker Hub link in README ([#14198](https://github.com/traefik/traefik/pull/14198) @GUOZIJAN)
> - Fix broken anchors in providers overview, SPIFFE and v3 migration docs ([#14027](https://github.com/traefik/traefik/pull/14027) @SatvikMishra08)
> - Fix dead and redirecting external links ([#14139](https://github.com/traefik/traefik/pull/14139) @rachana5)
> - Move AI assistance disclosure to the pull request description ([#14194](https://github.com/traefik/traefik/pull/14194) @Neffi42)
> - Update download and GitHub star counts ([#14193](https://github.com/traefik/traefik/pull/14193) @tomatokoolaid)

## 3.7.17-6

- Create `/homeassistant/traefik/` on start. On a fresh install nothing created it, so the file provider failed with "unable to read directory".

## 3.7.17-5

- Treat `/addon_configs/<slug>` and `/config` as the same bind mount when
  they share an inode; skip copy/rm so start no longer fails.

## 3.7.17-4

- Refresh idempotent legacy migration helpers (comment trim).

## 3.7.17-3

- Fix start failure when `/homeassistant/traefik` already has files: merge used
  `cp -an`, which exits non-zero on existing paths under `set -e`. Migration is
  now idempotent (drop leftover `/config/traefik`, keep dest).

## 3.7.17-2

- One-shot migrate: copy leftover `/config/traefik` (and legacy `addon_configs/…_traefik`) into `/homeassistant/traefik`, then remove the legacy trees.

## 3.7.17-1

- Fix wrong default config directory. `3.7.17` mapped dynamic/custom paths to
  `/config/traefik/`, which is the app’s own config mount — not the Home
  Assistant configuration directory. Defaults are now `/homeassistant/traefik/`
  (`homeassistant_config`), i.e. `traefik/` next to `configuration.yaml` on
  disk. If you already put files under `/config/traefik/`, move them to
  `homeassistant/traefik/` (or set `dynamic_configuration_path` /
  `custom_config.config_file` explicitly).

## 3.7.17

- First release in this repository wrapping Traefik `v3.7.17` (binary from
  GitHub Releases on the HA base image).
- File-based dynamic config, optional Let's Encrypt, custom static config
  override, Ingress dashboard via nginx.
- Version tracked via `upstream_repo: traefik/traefik`.

> Upstream v3.7.17: https://github.com/traefik/traefik/releases/tag/v3.7.17
