## Learned User Preferences

- Sign commits and pushes with the user's signing key.
- When the upstream updater rewrites an app, follow each file's existing style. In `CHANGELOG.md` only, leave a blank line and add `- Upgrading from upstream version <previous version> -> $APP_NEW_VERSION`, with the previous version written out and `$APP_NEW_VERSION` left for the updater script.

## Learned Workspace Facts

- Tracked add-ons store `$APP_NEW_VERSION` in `config.yaml`, `build.yaml`, the Dockerfile, `DOCS.md`, and the current changelog heading. `.github/workflows/track-upstream.yml` runs `scripts/update-upstream-version.py` to replace it. Only apps with `upstream_repo` in `build.yaml` are included; postgres, tang, and resolved-watchdog are not.
- The updater strips a leading `v` from release tags and maps pgAdmin tags such as `REL-9_18` to `9.18`. Sources that need the prefix keep `v$APP_NEW_VERSION` (Alloy's download URL and Homarr's image tags).
- Add-on base images use `ghcr.io/hassio-addons/base:stable`.
- `upstream_repo` is the version source and can differ from the published image: pgAdmin is `pgadmin-org/pgadmin4` (tags only; no GitHub Releases) with image `dpage/pgadmin4`; Technitium is `TechnitiumSoftware/DnsServer` with image `technitium/dns-server`; Traefik Manager Agent is `chr0nzz/traefik-manager` with image `ghcr.io/chr0nzz/traefik-manager-agent`; Forgejo is `codeberg.org/forgejo/forgejo`.
- Updates compare `upstream_version.txt` with the latest release or tag. Those files are absent until an update succeeds, so a missing file always looks stale. `build.yml` does not expand `$APP_NEW_VERSION`.
- `main` requires a verified commit signature. The updater's `git commit` and `git push` as `github-actions[bot]` is unsigned and is rejected, so the bump and image build do not land. Commits created through the GitHub API are verified. Dependabot and Renovate do not replace this updater.
