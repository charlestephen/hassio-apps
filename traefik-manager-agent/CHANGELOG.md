# Changelog

All notable changes to the Traefik Manager Agent app are documented here.
The version tracks the upstream Traefik Manager Agent (TMA) release it is
built from.

## 1.7.2

Initial release.

- Thin Home Assistant wrapper around the official
  `ghcr.io/chr0nzz/traefik-manager-agent:1.7.2` image (multi-arch:
  `aarch64`, `amd64`), including its built-in `HEALTHCHECK`.
- `TMA_API_KEY` (generated in the main Traefik Manager app under
  **Settings → Agents**) is the only required option.
- Backups and dynamic config are persisted under this app's `/data` volume
  by default, so they survive updates and reinstalls.
- Full environment-variable surface exposed as app options, including:
  - Agent server tuning (port, per-IP rate limit, debug logging).
  - Connection to this host's Traefik API (URL, basic auth, TLS
    verification).
  - Config file paths, ACME JSON, access log, and plugins directory.
  - Automatic Traefik restart after a static-config change (`proxy`,
    `poison-pill`, or `socket` method).
  - **CrowdSec** integration (LAPI URL, bouncer key, machine credentials,
    mTLS).
  - Agent-managed **git backup** (repo, branch, credentials, auto-push,
    commit message template) for sites not using Traefik Manager's
    "Use Host Repository" option.
