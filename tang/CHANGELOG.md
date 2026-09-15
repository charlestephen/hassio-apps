# Changelog

## 1.0.11-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-tang-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 1.0.11

- Switch the base to Alpine 3.24 by pinning `FROM alpine:3.24` directly in the
  Dockerfile. Because the Tang app no longer uses the hassio-addons base
  image, the base OS is upgraded by bumping this single line rather than tracking
  `ghcr.io/hassio-addons/base` releases. No behaviour change.

## 1.0.10

- Fix the Forgejo CI workflow (`build_tang.yml`): remove the hardcoded
  `--build-arg BUILD_FROM=ghcr.io/hassio-addons/base:20.0.1` that had been
  silently overriding the `FROM alpine:3.24` line in every build since 1.0.5.
  All images built between 1.0.5 and 1.0.9 were actually running on the old
  hassio-addons base despite the Dockerfile change — 1.0.10 is the first release
  where the plain-Alpine image was actually delivered.
- Add missing `BUILD_NAME` and `BUILD_DESCRIPTION` build-args to the CI workflow
  so the OCI labels are populated correctly.

## 1.0.9

- **Complete architectural rebuild.** Drop `ghcr.io/hassio-addons/base` and all
  s6-overlay machinery. The app now runs on plain `alpine:3.24` with a single
  hand-written shell entrypoint (`/usr/local/bin/tang-run`) as PID 1.
- Remove s6-rc.d services, `cont-init.d` scripts, and all `bashio` calls. Tang
  has no reason to query the Supervisor API; removing the dependency eliminates
  the `curl: (6) Could not resolve host: supervisor` and
  `FATAL: Unknown log_level:` boot failures entirely.
- The entrypoint reads `log_level` directly from `/data/options.json` using `jq`
  (no Supervisor API call), generates keys with `tangd-keygen` on first run if
  `/data/tang/db` is empty, and starts the server via
  `socat TCP-LISTEN:8888,reuseaddr,fork SYSTEM:"/usr/libexec/tangd <db>"`.
- Install `tang`, `jose`, `jq`, and `socat` from the Alpine package tree
  (including the `edge/testing` repo for `tang` and `jose`).

## 1.0.8

- Attempt to patch the `base-addon-log-level` s6 boot script to tolerate
  Supervisor DNS failures. The patch applied correctly but had no effect because
  the CI workflow was still building images on the old
  `ghcr.io/hassio-addons/base:20.0.1` base due to the hardcoded `BUILD_FROM`
  build-arg (see 1.0.10). Superseded by the full base replacement in 1.0.9.

## 1.0.7

- Switch Tang from `host_network: true` to bridge networking. Under bridge
  networking port 8888 is published via Docker NAT rather than bound directly on
  the host; the `ports:` / `ports_description:` keys in `config.yaml` are
  restored so Supervisor exposes the port correctly.

## 1.0.4.c

- Grant the AppArmor profile access to `/etc/s6-overlay` so `s6-rc-compile` can
  read the service database at boot (fixes the `s6-rc-compile … Permission
  denied` error under enforcement).

## 1.0.4.b

- Run s6-overlay as PID 1 (`init: false`) so the process supervisor owns the
  tree and reaps children correctly.
- Grant the AppArmor profile read access to `/init` and the s6/bashio scripts
  (`ix` → `rix`), fixing "can't open /init: permission denied" under enforcement.

## 1.0.4.a

- Refresh the AppArmor profile (`apparmor.txt`) so Tang runs confined under Home
  Assistant — drop the removed `tangd-update` rule, allow `tangd-rotate-keys`,
  and add `network unix stream`. Set `apparmor: false` in the app config to
  fall back to the default profile if needed.

## 1.0.4

- Fix startup: remove the call to `/usr/libexec/tangd-update`, which the Alpine
  `tang` package does not ship (it caused the init script to fail). `tangd`
  serves the advertisement directly from the key directory.
- Publish the image to the private Forgejo registry
  (`git.lan.cst.wtf/charlestephen/hassio-addons-tang-{arch}`).

## 1.0.1

- Add icon.png and logo.png for Home Assistant UI
- Fix init: set to true for proper s6-overlay startup
- Fix /init permission denied error by ensuring execute permission after COPY
- Add AppArmor security profile

## 1.0.0

- Initial release
- Tang NBDE server for LUKS2 automatic unlocking
- Auto-generates signing and exchange keys on first run
- Persistent key storage in /data/tang/db
