# Changelog

## 15.5.0

- Update Technitium DNS Server from 15.4.0 to 15.5.0 (upstream release 2026-09-19).
-### Fixes (upstream)
- Added support for LDAP authentication. Thanks to Roy Hagland (@Hemsby) for the PR #1869.
- Implemented support for draft-farrokhi-dnsop-ede-nta. NTA can be added by creating a Conditional Forwarder zone for the domain name with DNSSEC validation disabled. The FWD record's comments are used with the Extended DNS Error (EDE) included in the response.
- Added Zone File Editor option for Primary and Conditional Forwarder zones.
- Added support for predefined static API sessions that are configured using new DNS_SERVER_AUTH_STATIC_SESSIONS environment variable.
- Added new DNS_SERVER_WEB_SERVICE_WWW_FOLDER_PATH environment variable that allows changing the web service www root folder to allow using custom web service GUI. Thanks to Adrián García (@byGarcia) for PR #2138.
- Updated docker compose to add health check option that uses the Health Check API call.
- Updated Health Check API to be allowed to be called from loopback addresses without requiring authentication to support Docker health check.
-Fixed multi-hop amplification vulnerability reported by Qifan Zhang from Palo Alto Networks, that used multiple CNAME and delegation hops achieving a 4,096:1 packet amplification factor.
- Fixed cache poisoning vulnerability reported by Qifan Zhang from Palo Alto Networks, that allowed caching out-of-bailiwick DNAME record received from an attacker controlled zone targeting any domain name.
- Fixed DNSSEC validation bypass vulnerability reported by Qifan Zhang from Palo Alto Networks, that allowed an attacker controlled zone to inject out-of-bailiwick DS (Delegation Signer) records in referral responses to poison the resolver cache and disable DNSSEC validation for arbitrary signed zones.
- Fixed Denial of Service (DoS) vulnerability reported by Xuanchao Xie, that allowed an attacker to exploit DNS-over-HTTPS/3 (DoH/3) protocol service implementation to cause the DNS server to buffer large amount of data in memory causing the server to crash with Out Of Memory (OOM) error.
- Fixed authorization bypass vulnerability reported by Tao Pan (@pant0m), that allowed using ptr option feature in Add Record and Update Record API calls, and Delete Record API call to add/overwrite/delete PTR record in arbitrary reverse zone that the current user did not have modify permissions to.
- Fixed persistent Denial of Service (DoS) vulnerability affecting attacker selected victim domain name reported by Abdullah Al Ishtiaq, Kai Tu, Matthew Carter, Xiaotian Zhou, Ananna Rahman, Yilu Dong, Tianwei Yu, Ali Ranjbar, and Syed Rafiul Hussain from SyNSec Lab, The Pennsylvania State University. This vulnerability caused the attacker to add victim domain name to the background resolver task which fails to execute and requires the DNS Server to restart to recover.
- Fixed off-path cache poisoning vulnerability reported by Lior Shafir, Ameer Saleh, Prof. Raja Giryes, and Prof. Avishai Wool from Tel-Aviv University, that allowed an attacker to inject CNAME record in cache that caused all queries for the victim domain name to get redirected to the attacker's domain name that the CNAME specified.
- Fixed multiple stored XSS vulnerabilities reported by Yuqi Qiu and Xiang Li from AOSP Lab, Nankai University.
- Fixed zone name validation bypass vulnerability in Clone Zone and DNS Client Import API calls reported by Yuqi Qiu and Xiang Li from AOSP Lab, Nankai University.
- Fixed severe bug in DNS Client response sanitization function that caused Out Of Memory (OOM) exception resulting the DNS server to crash when specific types of response was received.
- Removed Auto Prefetch feature since it was not really effective while requiring too many system resources to function. Note that basic Prefetch feature is still available.
- Wild IP App: Updated app to add hex string support for IPv4. Thanks to Marty Cannon (@swimlane-marty) for the PR #2056.
- Multiple other minor bug fixes and improvements.

## 15.4.0-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-technitium-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 15.4.0

Update Technitium DNS Server from 15.3.0 to 15.4.0 (upstream release
2026-07-11).

### Fixes (upstream)

- **UDP socket binding**: fixed response-routing problems in specific
  deployment scenarios caused by UDP socket binding issues.
- **RFC compliance validation**: corrected issues that interfered with
  resolution and zone-transfer operations in certain circumstances.
- Various minor bug fixes and performance improvements.

### New features (upstream)

- **Unix Domain Sockets (UDS)** support extended to the Web Service over
  HTTPS and the DNS-over-HTTPS optional protocol (15.3.0 added UDS for
  plain HTTP only).

Full upstream changelog:
<https://github.com/TechnitiumSoftware/DnsServer/blob/master/CHANGELOG.md>

## 15.3.0

Update Technitium DNS Server from 15.2.0 to 15.3.0 (upstream release
2026-07-05).

### Security (upstream)

- **Fixed multiple Stored XSS vulnerabilities** in the Web Console
  (reported by Daniel Goldberg and Anner Klein, Tenzai).
- **Removed the `Delete` permission from the `DNS Administrators` group**
  in both the **Apps** section (privilege-escalation exploit) and the
  **Settings** section (unauthorized backup/restore configuration abuse).
  ⚠️ *Upstream applies this only to new installations — on an existing
  install, review and remove these permissions manually under
  Administration → Permissions.*
- **Fixed multiple RFC compliance issues** (reported by researchers from
  Tsinghua University).

### New features (upstream)

- **Health check API**: `GET /api/dnsClient/healthCheck` probes the server
  without generating query-log entries — useful for container/HA watchdogs.
- **Status API**: new `/api/status` endpoint (supersedes the SSO Status API).
- **Zones UI**: search/filtering and bulk deletion in the Zones section.
- **RFC 6303 / RFC 6761**: Locally Served Zones and Special-Use Domain
  Names support, with management options in Settings.
- **Unix domain socket support** for the Web Service and DNS-over-HTTP.
- **TXT records** now accept Unicode strings.
- New Settings options: update-check control, CSP `frame-ancestors`
  headers, DoH help-page redirection, and logging customization; per-user
  option to disable update notifications.

### Fixes (upstream)

- **DNSSEC**: resolved "missing RRSIG" validation failures when using
  forwarders.
- DNS Apps: JSON config files now support comments; all apps ship
  Markdown READMEs; app updates include online certificate signing,
  custom groups, and ASN support.

### App

- `build_technitium.yml` now reads `BUILD_FROM` and `TECHNITIUM_VERSION`
  from `build.yaml` instead of hardcoded stale values (base `20.0.1` /
  `TECHNITIUM_VERSION=latest`), making `build.yaml` the single source of
  truth for CI builds.

Full upstream changelog:
<https://github.com/TechnitiumSoftware/DnsServer/blob/master/CHANGELOG.md>

## 15.2.0.r

- Upgrade base image from `ghcr.io/hassio-addons/base:20.0.1` to
  `ghcr.io/hassio-addons/base:21.0.0`, which bundles Alpine 3.24 (musl 1.2.5,
  OpenSSL 3.4, s6-overlay 3.2.x). The Technitium application version and all
  app behaviour are unchanged; this is a base OS refresh only.

## 15.2.0.q

- **Add `auth_api: true`** to `config.yaml` so the Supervisor grants access to
  the HA authentication endpoint — required for future authenticated web UI
  proxying.
- **Add `discovery: [technitium]`** to `config.yaml` and a new `discovery`
  oneshot s6-rc.d service. After Technitium's web API becomes reachable on port
  5380, `bashio::discovery` broadcasts `{host: 127.0.0.1, port: 5380}` to the
  HA Supervisor so Home Assistant can register the service. Uses
  `bashio::net.wait_for 5380` (same pattern as AdGuard Home) instead of a
  manual `curl` poll loop.
- **Fix `finish` script** to properly halt the s6 supervision tree on fatal
  crashes. Previously it only logged a warning (allowing silent restart loops).
  Now: exit 256 + SIGTERM → clean `halt`; any other non-zero exit → propagate
  exit code to `/run/s6-linux-init-container-results/exitcode` and `halt` the
  container. Matches the AdGuard Home reference implementation.

## 15.2.0.p

- Bump `homeassistant:` minimum version from `2024.1.0` to `2026.6.0`.

## 15.2.0.o

- **Fix s6-rc oneshot startup failure.** `s6-rc-oneshot-run` parses `up` files
  as execline scripts, not shell scripts — a bash `#!/command/with-contenv bashio`
  shebang was silently treated as a comment, leaving `readonly` as the first
  token which s6 tried to exec as a binary (exit 127). Split each oneshot into
  an execline `up` wrapper (two lines) that chains into a separate bash `run`
  script. The longrun `run` and `finish` files are unaffected — those are
  exec'd directly by the kernel and always supported bash shebangs.

## 15.2.0.n

- **Migrate to s6-overlay v3 `s6-rc.d` service format.** Replace legacy
  `cont-init.d/technitium.sh` and `services.d/technitium/{run,finish}` with a
  proper three-stage s6-rc.d pipeline:
  - `init-technitium` (oneshot): creates the data directory and handles the
    `reset_webservice_config` one-shot recovery path.
  - `technitium` (longrun): exports `DNS_SERVER_*` environment variables from
    app options and `exec`s the .NET process — s6 supervises and restarts it.
  - `post-init-technitium` (oneshot): polls the Technitium REST API until ready,
    then restricts DNS listeners to real NIC IPs (via `bashio::network.interfaces`)
    excluding `172.30.32.2` so the HA Supervisor's dnsmasq retains ownership of
    that address and continues resolving `*.local.hass.io` natively.
    Also deletes the stale `local.hass.io` forwarder zone created by 15.2.0.k
    if it is still present — it is no longer needed under the correct binding.
- **Add `hassio_api: true` and `hassio_role: manager`** to `config.yaml` so
  the app can call the Supervisor API (`bashio::network.*`) to enumerate
  host interface addresses at runtime.
- **Declare `ports:`** (`53/udp`, `853/tcp`, `5380/tcp`) in `config.yaml` so
  Supervisor knows which host ports the app uses (informational under
  `host_network: true`).

## 15.2.0.m

- Promote app from `experimental` to `stable`.
- Add `homeassistant: "2024.1.0"` minimum version to satisfy Supervisor
  quality scoring requirements.

## 15.2.0.l

- **Fix SERVFAIL / "server misbehaving" loop under host networking.** Under
  `host_network: true` Technitium binds to `0.0.0.0:53`, which includes
  `172.30.32.2` — the address the HA Supervisor's dnsmasq used to own.
  The 15.2.0.k forwarder zone pointed `local.hass.io` back at `172.30.32.2`,
  which is now Technitium itself, causing an infinite loop and SERVFAIL for
  every `*.local.hass.io` query. The `run` script now detects whether
  Technitium is listening on that address via the settings API and skips
  creating the zone when a loop would result, logging an actionable warning
  instead.
- **Fix "server misbehaving" for external names.** If `dns_server_forwarders`
  is empty, Technitium attempts full recursive resolution from root servers,
  which frequently fails inside HA OS. Set upstream forwarders
  (e.g. `1.1.1.1,1.0.0.1`) in the app options to resolve this.

## 15.2.0.k

- **Fix HA-internal DNS resolution under host networking.** When Technitium
  binds to port 53 on the host it fully replaces the Supervisor's dnsmasq,
  which means queries for `*.local.hass.io` (app names, `homeassistant`,
  `supervisor`, etc.) would previously return NXDOMAIN.
  The `run` script now starts Technitium in the background, waits for its API
  to become ready, and creates a **conditional forwarder zone** for
  `local.hass.io` → `172.30.32.2` (HA Supervisor DNS) via the Technitium REST
  API. The operation is idempotent — it is a no-op if the zone already exists.
  An admin password must be set in app options for the auto-configuration
  to run; without one a warning is logged and a link to the manual UI step is
  provided.

## 15.2.0.j

- Downshift `startup:` from `system` to `services`. The `system` tier is for
  early-boot infrastructure (AppArmor, D-Bus); a DNS server belongs in the
  `services` tier, which runs after Supervisor's own plugins and networking
  are up, but before user-facing `application`-tier apps. This lets
  Home Assistant Core resolve DNS through Technitium once Core starts, and
  it isolates a misbehaving DNS startup from Supervisor's own boot sequence.

## 15.2.0.i

- **Bugfix:** Restore the `[PORT:5380]` template in the `webui:` URL. 15.2.0.h
  used `webui: http://[HOST]:5380` (a plain literal port), which doesn't match
  Supervisor's webui regex — Supervisor silently dropped the entire app
  from the repository listing, so 15.2.0.h never appeared as an available
  update. The `[PORT:NNNN]` placeholder is required by Supervisor even under
  host networking; it just renders to the same number under host networking
  because there's no NAT remap. No image change vs 15.2.0.h — Dockerfile and
  rootfs identical.

## 15.2.0.h

- **Switch to host networking (`host_network: true`)** so Technitium can serve
  as Home Assistant's built-in DNS resolver. Under host networking the app
  binds directly to host ports (no Docker NAT in front), which means:
  - The DNS server sees the **real client IP** of every query, enabling
    per-client rules, logging and split-horizon resolution to work correctly.
  - UDP throughput is no longer bottlenecked by Docker's userland conntrack
    path — important for recursive DNS under load.
  - The `ports:` / `ports_description:` keys are ignored by Supervisor; the
    listening ports are documented as comments at the top of `config.yaml`.
  - Port 53 (and any other port the app listens on) **must be free on the
    host**. On HA OS this is the default; Supervised installs may have a host
    resolver bound to 53 that needs to be disabled first.
- The web UI URL is unchanged — still `http://<hassio-ip>:5380` — but now it
  reaches a real host port rather than a NAT-mapped one.
- AppArmor profile unchanged. Host networking doesn't broaden the in-container
  capability set; `network tcp/udp/inet/inet6` + `capability net_bind_service`
  still cover everything the DNS server needs to bind.

## 15.2.0.g

- Install **libmsquic** so the .NET runtime can serve **DNS-over-QUIC (DoQ)** on
  853/udp and **DNS-over-HTTP/3 (DoH3)** on 443/udp. Sourced from Alpine
  v3.23/community (maintained by the Microsoft QUIC Team for musl), so no
  Microsoft apt repository is needed on the HA Alpine base.
- Track the upstream Technitium image at `:latest` by default (still overridable
  via the `TECHNITIUM_VERSION` build arg). The multi-stage build now stays in
  lockstep with the primary developer's container.
- Publish the full set of upstream container ports so DoQ, DoH3, DNS-over-HTTP
  (for reverse-proxy setups) and the optional DHCP server can be enabled
  without editing the app:
  - 853/udp — DNS-over-QUIC
  - 443/udp — DNS-over-HTTPS/3
  - 80/tcp, 8053/tcp — DNS-over-HTTP (behind a TLS-terminating proxy)
  - 67/udp — DHCP server
- Expose the most common upstream `DNS_SERVER_*` initialization variables as
  typed app options (`dns_server_domain`, `dns_server_admin_password`,
  `dns_server_prefer_ipv6`, `dns_server_recursion`, `dns_server_forwarders`,
  `dns_server_forwarder_protocol`, `dns_server_enable_blocking`,
  `dns_server_block_list_urls`, `dns_server_optional_protocol_dns_over_http`).
- Add an `extra_env` list option (schema-validated `DNS_SERVER_*=value` entries)
  as a free-form passthrough for any upstream variable not exposed as a typed
  option — covers all 30+ variables in upstream's
  [DockerEnvironmentVariables.md](https://github.com/TechnitiumSoftware/DnsServer/blob/master/DockerEnvironmentVariables.md)
  without crowding the HA UI.
- These variables only seed config on first boot (upstream behavior); existing
  installs keep using their saved `/data/technitium` state. Use
  `reset_webservice_config` for the web-service-only recovery path.
- AppArmor profile unchanged — its broad `file,` rule already covers
  `/usr/lib/libmsquic.so.2`, and `network udp` + `capability net_bind_service`
  already allow binding DoQ/DoH3 to privileged ports.

## 15.2.0.f

- Fix the web UI hanging under AppArmor enforcement: the profile lacked the broad
  `file,` rule the other complex apps have, so the .NET runtime was denied the
  `/proc/self/*` and `/sys/fs/cgroup/*` reads it needs at startup. Added
  `file,`/`capability,`/`signal,` (network stays constrained).

## 15.2.0.e

- Initialize Technitium's web service bind address with
  `DNS_SERVER_WEB_SERVICE_LOCAL_ADDRESSES=0.0.0.0` so the web UI is reachable on
  Home Assistant's IPv4 Docker network.
- Add `web_service_local_addresses` and one-shot `reset_webservice_config`
  options for recovering installs that already saved an IPv6-only
  `webservice.config`.

## 15.2.0.d

- Expose the Home Assistant `/ssl` directory **read-only** (reverted from
  read-write); Technitium reads certificates from it for DoT/DoH.

## 15.2.0.c

- Expose the Home Assistant `/ssl` directory read-write so Technitium can use
  (and manage) certificates for DoT/DoH.
- Publish port **53443/tcp** for DNS-over-HTTPS on an alternate port.
- Grant the AppArmor profile access to `/etc/s6-overlay` so `s6-rc-compile` can
  read the service database at boot (fixes "s6-rc-compile: fatal: unable to
  opendir /etc/s6-overlay/s6-rc.d: Permission denied" under enforcement), and
  allow writing to `/ssl`.

## 15.2.0.b

- Run s6-overlay as PID 1 (`init: false`) so the process supervisor owns the
  tree and reaps children correctly.
- Grant the AppArmor profile read access to `/init` and the s6/bashio scripts
  (`ix` → `rix`), fixing "can't open /init: permission denied" under enforcement.

## 15.2.0.a

- Refresh the AppArmor profile (`apparmor.txt`) so Technitium runs confined under
  Home Assistant — covers the .NET 10 runtime, `/opt/technitium`, `/etc/dns`,
  `/data`, DNS/web networking and `net_bind_service` (added `network unix
  stream`). Set `apparmor: false` in the app config to fall back to the
  default profile if needed.

## 15.2.0

- Update Technitium DNS Server from 14.3.0 to 15.2.0.
- Switch the runtime to `aspnetcore10-runtime` — Technitium 15.x targets .NET 10
  (14.x targeted .NET 9), so the older runtime would no longer start the server.
- Publish the image to the private Forgejo registry
  (`git.lan.cst.wtf/charlestephen/hassio-addons-technitium-{arch}`).

## 14.3.1

- Add icon.png and logo.png for Home Assistant UI
- Fix init: set to true for proper s6-overlay startup
- Fix /init permission denied error by ensuring execute permission after COPY
- Add AppArmor security profile

## 14.3.0

- Initial release
- Technitium DNS Server with web management UI
- Multi-stage Docker build from official image
- Persistent configuration in /data/technitium
- DNS, DNS-over-TLS, and DNS-over-HTTPS support
