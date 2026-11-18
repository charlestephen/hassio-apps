# Changelog

## 3.2.6

- Upgrading from upstream version 3.2.5-1 -> 3.2.6

> Upstream mimir-3.2.6: https://github.com/grafana/mimir/releases/tag/mimir-3.2.6
>
> This release contains 4 PRs from 2 authors. Thank you!
>
> # Changelog
>
> ## 3.2.6
>
> ### Grafana Mimir
>
> * [BUGFIX] Upgrade Go to 1.26.11 to address [CVE-2026-97054](https://pkg.go.dev/vuln/GO-2026-6859). #17376
> * [BUGFIX] Update `github.com/klauspost/compress` to v1.20.2 to address [CVE-2026-116591](https://pkg.go.dev/vuln/GO-2026-6865). #17209
> * [BUGFIX] Update the OpenTelemetry libraries to v1.47.0 to address [CVE-2026-81871](https://nvd.nist.gov/vuln/detail/CVE-2026-81871), [CVE-2026-81872](https://pkg.go.dev/vuln/GO-2026-6615), and [CVE-2026-128085](https://github.com/advisories/GHSA-q7gw-24fr-5p69). #17394
>
>
> **All changes in this release**: https://github.com/grafana/mimir/compare/mimir-3.2.5...mimir-3.2.6

## 3.2.5-1

- First release: Mimir 3.2.5 in monolithic mode with filesystem storage under `/data/mimir`, one tenant.
