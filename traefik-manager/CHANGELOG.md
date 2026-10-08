# Changelog

## 1.15.1

- Upgrading from upstream version 1.15.0 -> 1.15.1

All notable changes to the Traefik Manager app are documented here.
The version tracks the upstream Traefik Manager release it is built from.

> Upstream v1.15.1: https://github.com/chr0nzz/traefik-manager/releases/tag/v1.15.1
>
> ## v1.15.1
>
> **Improvements:**
> - **[routes]** The route form warns when TLS is on and a plain http entry point such as `web` is selected, since that route returns 404 on http
> - **[docs]** FAQ entry for `404 page not found`, a LAN only / CGNAT setup for umbrelOS, and the front proxy route for an Umbrel behind another reverse proxy
>
> **Bug fixes:**
> - **[oidc, security]** Update PyJWT to 2.15.0 ([CVE-2026-101918](https://github.com/advisories/GHSA-42vr-xj54-vc7v))
> - **[routes]** Editing or cloning a route without TLS no longer adds `tls: {}` back on save
> - **[config]** A dynamic config with an empty `http:`, `tcp:`, `udp:` or `tls:` key no longer breaks setup and the routes page ([#209](https://github.com/chr0nzz/traefik-manager/discussions/209))

## 1.15.0

- Upgrading from upstream version 1.14.0 -> 1.15.0

> Upstream v1.15.0: https://github.com/chr0nzz/traefik-manager/releases/tag/v1.15.0
>
> ## v1.15.0
>
> **Enhancements:**
> - **[i18n]** Translate the web interface through Weblate
> - **[i18n]** Add French
> - **[i18n]** Add French (Canada)
> - **[i18n]** Add German
> - **[i18n]** Add Spanish
> - **[i18n]** Add Portuguese (Portugal)
> - **[i18n]** Add Portuguese (Brazil)
> - **[i18n]** Add Dutch
> - **[i18n]** Add Chinese (Simplified)
> - **[i18n]** Add Russian
> - **[i18n]** Add Czech
> - **[i18n]** Add Danish
> - **[i18n]** Add English (United States) and English (United Kingdom)
> - **[i18n, settings]** Pick the language from the navigation bar or Settings, Interface, General
> - **[i18n, setup]** Pick the language in the setup wizard and on the sign-in page
> - **[i18n, settings]** Hide the language button in Settings, Interface, Navbar
> - **[i18n]** Open any page in a language with a /fr/ path or a lang query parameter
> - **[i18n]** Show numbers, dates and times in the chosen language
> - **[i18n, agent]** Show agent errors in the chosen language
> - **[i18n, api]** Return API error messages in the chosen language
> - **[api]** Add POST /api/settings/language
> - **[agent, api]** Add error codes to agent error responses
> - **[settings]** Split Settings, Interface into General, Dashboard, Navbar and Tabs
> - **[webui]** Confirm a delete by typing the name of what is being deleted
> - **[routes]** Show and edit middlewares, services and TLS options from other files in the route Raw YAML ([#185](https://github.com/chr0nzz/traefik-manager/issues/185))
> - **[routes]** Autocomplete names and add snippets in the route Raw YAML ([#185](https://github.com/chr0nzz/traefik-manager/issues/185))
> - **[routes]** Block a Raw YAML save that points at something that does not exist ([#185](https://github.com/chr0nzz/traefik-manager/issues/185))
> - **[webui]** Add a Discord link to Settings, About
> - **[webui]** Remove the help translate popup
> - **[docker, agent]** Run as a non-root user with `PUID` and `PGID` (thanks @boazgarty)
>
> **Bug fixes:**
> - **[auth, security]** Block password-only sign-in when the two-factor secret cannot be read
> - **[auth, oidc]** Add `OIDC_REDIRECT_URI` to pin the OIDC callback URL
> - **[auth, security]** Limit wrong two-factor codes on the password reset page
> - **[security]** Stop the Traefik and CrowdSec connection tests from following redirects
> - **[config, security]** Stop `manager.yml` from being treated as a Traefik config
> - **[geoip, security]** Cap the size of the GeoIP download
> - **[auth]** Keep the base path and language after sign-in
> - **[install]** Compile translations on native installs and updates
> - **[webui]** Use the singular for counts of one
> - **[i18n]** Translate dashboard, logs, CrowdSec and server messages as whole sentences
> - **[i18n]** Keep delete and remove buttons red in every language
> - **[i18n, notifications]** Show notifications in each viewer's language and send webhooks in the default language
> - **[i18n]** Translate route health, certificate, CrowdSec, git backup and update messages
> - **[static]** Fix the Logging section summary
> - **[dashboard]** Fix grouping of Files & Data routes in other languages
> - **[dashboard]** Check Traefik's internal routers that have a link, instead of leaving them grey ([#202](https://github.com/chr0nzz/traefik-manager/issues/202), thanks @nofuturekid)
> - **[backups, security]** Harden git backup remote calls (thanks @boazgarty)
> - **[ci, security]** Limit workflow permissions and pin actions (thanks @boazgarty)
>
> **Documentation:**
> - **[i18n]** Add a Languages page
> - **[i18n]** Add a translation guide for developers
> - **[config]** Document default_language and showLangPicker
> - **[agent]** Document agent error codes
> - **[security]** Document `OIDC_REDIRECT_URI` and `TRUSTED_PROXIES`
> - **[routes]** Document the Raw YAML editor
> - **[umbrelos]** Add umbrelOS as an install method ([#190](https://github.com/chr0nzz/traefik-manager/discussions/190))
>
> Upstream v1.14.2: https://github.com/chr0nzz/traefik-manager/releases/tag/v1.14.2
>
> ## v1.14.2
>
> **Enhancements:**
> - **[webui, i18n]** Invite you once to help translate the interface, in a popup that names your browser's language, links Weblate and the translator docs, and can be put off for two weeks or turned off for good ([#184](https://github.com/chr0nzz/traefik-manager/discussions/184))
> - **[docs]** Add a Translations section to the README with the live per-language progress and where to help ([#184](https://github.com/chr0nzz/traefik-manager/discussions/184))
>
> **Bug fixes:**
> - **[webui, routes]** Keep the route Raw YAML editor on the theme the rest of the page uses, instead of staying dark after a switch to light ([#185](https://github.com/chr0nzz/traefik-manager/issues/185))
> - **[routes]** Show the `serversTransports`, middlewares and TLS options a route references in its Raw YAML, and write them back when you save, instead of leaving them out and silently discarding any you added ([#185](https://github.com/chr0nzz/traefik-manager/issues/185))
> - **[routes, webui]** Show the host Traefik resolved on the Routes tab, the route map, the domain filter and certificate matching, so a rule that builds its host with a Go template reads and links like any other route ([#181](https://github.com/chr0nzz/traefik-manager/discussions/181))
> - **[auth, oidc, security]** Verify the provider's id_token before trusting it: check the signature against the provider's JWKS, the issuer, the audience against the client ID, and the expiry, instead of decoding the payload and reading the email and group claims that decide access ([GHSA-4gj3-wgxw-79jj](https://github.com/chr0nzz/traefik-manager/security/advisories/GHSA-4gj3-wgxw-79jj))
> - **[auth, oidc, security]** Refuse an OIDC sign-in where the provider returned no id_token at all, instead of skipping every check above and continuing on the unsigned userinfo response ([GHSA-4gj3-wgxw-79jj](https://github.com/chr0nzz/traefik-manager/security/advisories/GHSA-4gj3-wgxw-79jj))
> - **[auth, oidc, security]** Use an OIDC callback once, by taking the state out of the session when it is checked, and refuse a sign-in whose nonce is missing rather than skipping the comparison, so a callback cannot be replayed
> - **[auth, oidc, security]** Ignore a userinfo response whose sub names a different account than the verified id_token, instead of letting it overwrite the verified claims that decide access
> - **[auth, oidc, security]** Require the provider to say `email_verified` is true before an allowlisted email is accepted. An absent claim, a null, a 0 or an empty string used to pass as verified. If your provider does not send the claim, map it, or allow the account by group instead - the log names the missing claim
> - **[setup, auth, security]** Stop treating a `manager.yml` that cannot be read or parsed as a brand new install. A YAML error, a file that parses to a list or a bare scalar, or any read failure reopened the first-run setup wizard to an unauthenticated visitor, who could set the admin password and get a signed-in session. Setup now refuses to run until the file is fixed or restored
> - **[auth, security]** Write `manager.yml`, `agents.yml` and the secret encryption key so only the account running Traefik Manager can read them, keep a stricter mode you set yourself, and narrow an existing file once at startup. They were created world-readable, and every save undid a manual `chmod`
> - **[notifications, security]** Keep a notification channel's own bot token and webhook URL out of the delivery log. A provider's error usually quotes the request it could not make, so the credential was written to the log on every failed delivery
> - **[auth, security]** Remove control characters from the `next` parameter before checking it, so `next=/<tab>/example.com` can no longer redirect off the site
> - **[auth, security]** Check that an `X-Api-Key` header holds a real key before letting it skip the forced password change. Any value at all used to be enough
> - **[auth]** Say when two-factor is switched on but its secret cannot be decrypted, in Settings and in `GET /api/auth/otp/status`, instead of reporting a second factor that is never asked for. This happens when the encryption key is lost or replaced, which is now also written to the log
> - **[build, security]** Verify every third-party asset the build downloads against a recorded SHA-256, and fail on an HTTP error instead of saving the error page as the asset. The tailwindcss binary the build runs was fetched the same unchecked way
> - **[build, security]** Commit the docs lockfile and stop `npm install` from running dependency lifecycle scripts, closing the path a malicious `postinstall` used in May 2026
> - **[ci, security]** Pin every GitHub Action to a commit rather than a movable tag in the jobs that publish images and sign attestations, and stop leaving the workflow token in `.git/config` for later steps to read
> - **[agent, release, security]** Sign the agent binaries during the release, so `gh attestation verify` can tell a released binary from one added to the release afterwards
> - **[webui, providers]** Show a provider tab's route count as soon as the dashboard loads, for every provider, instead of leaving Internal, Consul, Nomad and the rest blank until the tab is opened
> - **[agent, routes]** Read an agent's router list without treating its completeness flags as routers, which broke the agent routes API and left agent routes unable to load ([#181](https://github.com/chr0nzz/traefik-manager/discussions/181))
> - **[routes, dashboard]** Launch and check a route whose rule builds its host with a Go template, such as ``Host(`plex.{{ env `DOMAINNAME0` }}`)``, by taking the host Traefik resolved from its API instead of the raw template, so the route gets a link, a status dot and a search match like any other, while the config file keeps the template ([#181](https://github.com/chr0nzz/traefik-manager/discussions/181))
> - **[dashboard]** Say a route's host comes from a template Traefik has not resolved, instead of "the rule has no host", when Traefik reports no router for it ([#181](https://github.com/chr0nzz/traefik-manager/discussions/181))
>
> **Documentation:**
> - **[dashboard]** Describe how a route with a templated host rule is launched and checked ([#181](https://github.com/chr0nzz/traefik-manager/discussions/181))
> - **[agent]** Check the checksum, and the new build attestation, when installing an agent binary by hand
>
> 1 older upstream releases omitted.

## 1.14.0

- Update to Traefik Manager 1.14.0 from upstream.

## 1.13.5

Initial release.

- Thin Home Assistant wrapper around the official
  `ghcr.io/chr0nzz/traefik-manager:1.13.5` image (multi-arch: `aarch64`,
  `amd64`).
- Upstream's own gunicorn process is preserved; the app only injects
  configuration as environment variables before exec'ing it.
- `manager.yml`, the dynamic config, and backups are persisted under this
  app's `/data` volume by default, so they survive updates and reinstalls.
- Full environment-variable surface exposed as app options, including:
  - Connection to the Traefik API (URL, basic auth, TLS verification).
  - Config file paths (dynamic config, static config, ACME JSON, access log,
    plugins directory).
  - Authentication (admin password, session/cookie settings, proxy hop
    trust).
  - Automatic Traefik restart after a static-config change (`proxy`,
    `poison-pill`, or `socket` method).
  - **OIDC/SSO** login with email/group allow-lists.
  - **CrowdSec** integration (LAPI URL, bouncer key, machine credentials,
    mTLS).
  - GeoIP database path, agent API rate limit, sub-path serving, log level.
