# Changelog

## 4.2.5

- Upgrade Error Pages 4.2.3 -> 4.2.5.

> Upstream v4.2.5: https://github.com/tarampampam/error-pages/releases/tag/v4.2.5
>
> <!-- Release notes generated using configuration in .github/release.yml at master -->
>
> ## What's Changed
> ### 📦 Dependency updates
> * build(deps): bump golang from 1.26.5 to 1.27.0 in https://github.com/tarampampam/error-pages/pull/423
>
> **Full Changelog**: https://github.com/tarampampam/error-pages/compare/v4.2.4...v4.2.5
>
> ## 🐋 Docker images
>
> ```cpp
> // server
> ghcr.io/tarampampam/error-pages:4.2.5
> ghcr.io/tarampampam/error-pages:4.2
> ghcr.io/tarampampam/error-pages:4
> ghcr.io/tarampampam/error-pages:latest
> quay.io/tarampampam/error-pages:4.2.5
> quay.io/tarampampam/error-pages:4.2
> quay.io/tarampampam/error-pages:4
> quay.io/tarampampam/error-pages:latest
> tarampampam/error-pages:4.2.5
> tarampampam/error-pages:4.2
> tarampampam/error-pages:4
> tarampampam/error-pages:latest
>
> // builder
> ghcr.io/tarampampam/error-pages:4.2.5-builder
> ghcr.io/tarampampam/error-pages:4.2-builder
> ghcr.io/tarampampam/error-pages:4-builder
> ghcr.io/tarampampam/error-pages:latest-builder
> quay.io/tarampampam/error-pages:4.2.5-builder
> quay.io/tarampampam/error-pages:4.2-builder
> quay.io/tarampampam/error-pages:4-builder
> quay.io/tarampampam/error-pages:latest-builder
> tarampampam/error-pages:4.2.5-builder
> tarampampam/error-pages:4.2-builder
> tarampampam/error-pages:4-builder
> tarampampam/error-pages:latest-builder
> ```
>
> ## 📦 Helm chart
>
> ```bash
> helm install error-pages oci://ghcr.io/tarampampam/error-pages/charts/error-pages \
>   --version 4.2.5
> ```

## 4.2.3-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-error_pages-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 4.2.2.a

- Base image is `ghcr.io/hassio-addons/base:stable` (Alpine 3.24). The error-pages binary is
  statically linked and unaffected; only the base OS layer changes.

## 4.2.2

- Update upstream `error-pages` binary from `4.2.1` to `4.2.2`. This is a
  bug-fix release: corrects the default behaviour of `--send-same-http-code` when
  no explicit status code is supplied by the reverse proxy, and updates bundled
  templates for several themes. No configuration changes required.

## 4.2.1

- Initial release.
- error-pages 4.2.1 (static Go binary copied onto the Home Assistant Alpine base).
- All major options configurable: theme, default error page, send-same-HTTP-code,
  show-details, theme rotation, disable-l10n, proxy headers, log level/format.
- Serves on port 8080 for reverse proxies (Traefik/nginx/…). Ships an AppArmor
  profile.
