# Changelog

## 1.2.0

- Upgrading from upstream version 1.1.2-2 -> 1.2.0

> Upstream v1.2.0: https://github.com/openobserve/openobserve/releases/tag/v1.2.0
>
> 📦 Download Binaries from https://openobserve.ai/downloads
>
> undefined

## 1.1.2-2

- Switched the base image from `openobserve/openobserve` (Community, AGPL)
  to OpenObserve's Enterprise Edition image `v1.1.2`, pulled from
  `public.ecr.aws/zinclabs/openobserve-enterprise` — `o2cr.ai` directly
  needs registry credentials this build doesn't have (confirmed: `podman
  pull o2cr.ai/openobserve/openobserve-enterprise:latest` returns "denied:
  Not Authorized"), while the ECR mirror is the identical image, pullable
  with no auth here or in CI.
- Drop-in replacement, confirmed live: ran both images side by side with the
  same `ZO_ROOT_USER_EMAIL`/`ZO_ROOT_USER_PASSWORD`/`ZO_TELEMETRY` env vars
  — identical startup (same SQLite local-mode init, same `/openobserve`
  binary path), identical `/healthz`, identical Basic Auth behavior against
  `/api/default/streams`. No option, entrypoint, or data-layout changes.
  Runs free with no license key; a key (set in-app under Management →
  License) only unlocks Enterprise's paid features, not required to start.
- `org.opencontainers.image.licenses` label corrected from `AGPL-3.0-only`
  (Community's license, wrong for this image) to
  `LicenseRef-OpenObserve-Enterprise` — Enterprise Edition is proprietary,
  not AGPL; see <https://openobserve.ai/legal/enterprise-license>.
- `build.yaml`'s `upstream_docker_image` is now unset rather than pointed at
  the old Docker Hub path: the version tracker's Docker Hub gate
  (`update-upstream-version.py`) only knows how to query Docker Hub, not AWS
  ECR Public, so leaving it set to the old path would make every future
  auto-update refuse to bump with a false "image not found". `upstream_repo`
  still tracks the open-source Community repo's release tags for version
  numbers — confirmed those numbers line up (Enterprise v1.1.2 reports
  itself as exactly `v1.1.2`, same as Community).

## 1.1.2-1

- First release: OpenObserve 1.1.2 with data under `/data/openobserve`.
