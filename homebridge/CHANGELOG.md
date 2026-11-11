# Changelog

## 2026-11-10

- Upgrading from upstream version 2026-11-02-5 -> 2026-11-10

> Upstream 2026-11-10: https://github.com/homebridge/docker-homebridge/releases/tag/2026-11-10
>
> ## Homebridge Docker Image
>
> This Ubuntu Linux-based Docker image allows you to run [Homebridge](https://github.com/homebridge/homebridge), developed by [Nfarina](https://github.com/nfarina), on your home network. Homebridge emulates the iOS HomeKit API, allowing you to integrate smart home devices with Apple Home.
>
> The image supports multiple CPU architectures. Docker automatically pulls a compatible image for your system when one is available.
>
> **Ubuntu 26.04 rollout and 32-bit ARM:** During fall 2026, every Homebridge Docker image except `synology` moves to Ubuntu 26.04, one release stream at a time. Node.js no longer publishes 32-bit builds, so images based on Ubuntu 26.04 no longer include the `arm32v7` (32-bit ARM) architecture. If you run Homebridge in Docker on a 32-bit ARM device, move to a 64-bit (`arm64v8`) OS to keep receiving updates. Images already published stay available under their dated tags (for example `2026-10-23`).
>
> | Image Tag | Architectures | Release Type |
> | :--- | :--- | :--- |
> | `latest`, `ubuntu` | `amd64`, `arm32v7`*, `arm64v8` | Stable |
> | `synology` | `amd64`, `arm32v7`, `arm64v8` | Stable |
> | `beta` | `amd64`, `arm32v7`*, `arm64v8` | Beta |
> | `alpha` | `amd64`, `arm64v8` | Alpha |
> | `legacy` | `amd64`, `arm32v7`*, `arm64v8` | Legacy |
>
> \* `arm32v7` is dropped when that release stream moves to Ubuntu 26.04. `synology` stays on Ubuntu 22.04 and is not part of this rollout.
>
> ### Release Types
>
> - **Stable** (`latest`, `ubuntu`): Stable releases using the latest stable versions of Homebridge and its plugins.
> - **Legacy** (`legacy`): Stable releases using Homebridge 1.x and compatible plugin versions.
> - **Beta** (`beta`): Pre-release versions of Homebridge and the Homebridge UI for testing upcoming features.
> - **Alpha** (`alpha`): Early pre-release versions of Homebridge and the Homebridge UI for development and early testing.
>
> ## Current Package Manifest:
>
> ### Docker.manifest
>
> Homebridge Docker Package Manifest
>
>  Release Version: 2026-11-10
>
>  | Package | Version |
>  |:-------:|:-------:|
>  |Ubuntu|ubuntu:24.04|
>  |ffmpeg for homebridge|v2.2.2|
>  |Homebridge APT Package|v2.0.24|
>  |NodeJS|26.13.0|
>  |Homebridge UI|5.30.0|
>  |Homebridge|2.5.0|
>
>
> ## Docker Build Instruction Changes
>
> * **@homebridge/homebridge-apt-pkg**: Updated from 2.0.23 to 2.0.24
>
> ## Changes Since Previous Release (2026-11-02):
>
> ### Changes in Docker.manifest
> ```diff
> - |Homebridge APT Package|v2.0.23|
> + |Homebridge APT Package|v2.0.24|
> - |NodeJS|24.22.2|
> + |NodeJS|26.13.0|
> ```
>
> ### Docker Homebridge Changes
> ### Code Changes
>
> * Update stable dependencies in . (#1167) (`37ff4d2`)
> * Update alpha dependencies in alpha (#1166) (`bb70670`)
> * Update alpha dependencies in alpha (#1165) (`7fefa6c`)
> * Update beta dependencies in beta (#1163) (`9879e22`)
> * Update package.json (`c78cf18`)
> * Update alpha dependencies in alpha (#1162) (`686093b`)
> * Update legacy dependencies in legacy (#1161) (`6d9c443`)
> * Update alpha dependencies in alpha (#1160) (`2c6ba6f`)
> * Update beta dependencies in beta (#1159) (`d6164b7`)
> * Update synology dependencies in synology (#1158) (`b1b0af3`)
> * Update legacy dependencies in legacy (#1157) (`7345ef2`)
> * Update alpha dependencies in alpha (#1156) (`d9c6498`)
> * Update beta dependencies in beta (#1155) (`2d261e0`)

## 2026-11-02-5

- Guard the layout-migration `rm -rf` with `${STORE:?}` so it can never expand to `/`. No behaviour change.

## 2026-11-02-4

- `webui` uses `[PROTO:https]` with an `https` bool (default false) so Open Web UI is http unless TLS is enabled.

## 2026-11-02-3

- Persist like upstream Docker: Supervisor `data` mounts at `/homebridge`
  (`map.path`). Drops the `/data/homebridge` bind-mount and `SYS_ADMIN`
  (fixes state reset when the bind did not stick across HA restarts).
- Migrates nested `homebridge/homebridge/` from the -1/-2 layout on start.

## 2026-11-02-2

- Mount `/ssl` and add **HTTPS certificate/key file** options so Config UI
  TLS can be set from `/ssl/...` before first boot (written into
  `config.json`).
- Fix mDNS: default `enable_avahi` to off and set `host_dbus: true`. With
  host networking, in-container Avahi collides with the host
  (“another mdns processor on the same host”); HAP should use host Avahi
  over D-Bus instead.

## 2026-11-02-1

- Fix start crash: upstream `VOLUME /homebridge` cannot be `rm`/`symlink`’d
  (`Device or resource busy`). Persist on HA at `/data/homebridge` and
  bind-mount that over upstream’s path (`SYS_ADMIN`; turn Protection mode
  off if Supervisor prompts).

## 2026-11-02

- First Home Assistant app release wrapping official
  [`homebridge/homebridge:2026-11-02`](https://github.com/homebridge/docker-homebridge).
- Host networking, `/data` → `/homebridge`, `exec /init`. Options: `tz`,
  `enable_avahi`, `env_vars`. Upstream tracked via dated stable tags.

> Upstream 2026-11-02: https://github.com/homebridge/docker-homebridge/releases
