## Learned User Preferences

- Sign commits and pushes with the user's signing key.
- When the upstream updater rewrites an app, follow each file's existing style. In `CHANGELOG.md` only, leave a blank line and add `- Upgrading from upstream version <previous version> -> $APP_NEW_VERSION`, with the previous version written out and `$APP_NEW_VERSION` left for the updater script.

## Learned Workspace Facts

- Home Assistant displays `version` from each app's `config.yaml`. That field must be a real version. `.github/workflows/track-upstream.yml` runs `scripts/update-upstream-version.py --all` for every app with `upstream_repo` in `build.yaml`, then `scripts/push-github-signed-commit.py` commits through GitHub's `createCommitOnBranch` API with no custom author or committer so the commit is signed. `build.yml` builds the images after that push and refuses a version that still contains `$`.
- The updater strips a leading `v` from release tags and maps tags such as `REL-9_18` and `REL_18_6` to `9.18` and `18.6`. Sources that need the prefix keep it via `upstream_version_arg_prefix` or `upstream_build_from_prefix` (Alloy's download URL and Homarr's image tags). It ignores prerelease tags and will not replace a recorded version with an older one.
- Add-on base images use `ghcr.io/hassio-addons/base:stable`.
- `upstream_repo` is the version source and can differ from the published image: pgAdmin is `pgadmin-org/pgadmin4` (tags only; no GitHub Releases) with image `dpage/pgadmin4`; Technitium is `TechnitiumSoftware/DnsServer` with image `technitium/dns-server`; Traefik Manager Agent is `chr0nzz/traefik-manager` with image `ghcr.io/chr0nzz/traefik-manager-agent`; Forgejo is `codeberg.org/forgejo/forgejo`. PostgreSQL tracks `postgres/postgres` tags `REL_18_*` only. Tang tracks `latchset/tang`. Resolved Watchdog is first-party and has no upstream release.
- Updates compare `upstream_version.txt` with the chosen tag. Those files are absent until an update succeeds, so a missing file always looks stale.
- `main` requires a verified commit signature. A local `git commit` from `github-actions[bot]` is unsigned and is rejected. Dependabot and Renovate open pull requests and do not update this `version` field, so they do not replace the updater.
