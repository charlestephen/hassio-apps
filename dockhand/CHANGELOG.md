# Changelog

## 1.0.59

- Upgrading from upstream version 1.0.58 -> 1.0.59

> Upstream v1.0.59: https://github.com/Finsys/dockhand/releases/tag/v1.0.59
>
> ## What's new in v1.0.59
>
> - ✨ vulnerability counts per container, image or stack in one API call (#1916, PR#1923, @raetha)
> - ✨ Bulgarian interface translation (PR#1919, @Bare7a)
> - ✨ Japanese interface translation (PR#1931, @HUNTER-TA)
> - ✨ container updates show on the Activity page (#1864, PR#1865, @peremunoz)
> - 🐛 poll mode no longer misses container events between polls (#1886, PR#1922, @raetha)
> - 🐛 Dockhand's own helper containers (scanners, backup helpers) no longer show in container lists (#1911, PR#1921, @raetha)
> - 🐛 the compose editor shows the variable badge for a ${VAR} that follows escaped $$ (#1926)
> - 🐛 scheduled and batch updates restore a missing compose service alias, so service-name DNS in the stack works again (#1928)
> - 🐛 stack deploys retry an image pull the registry rate-limits, as container updates do (#1551)
> - 🐛 additional permission and environment-variable hardening across settings and compose validation
> - 🐛 update Node.js to 24.22.3 and docker-compose to 5.7.1-r1 for security fixes
>
> ## Docker image
>
> ```bash
> docker pull fnsys/dockhand:v1.0.59
> ```
>
> Also available as `fnsys/dockhand:latest`
>
> [View on Docker Hub](https://hub.docker.com/r/fnsys/dockhand)

## 1.0.58

- Upgrading from upstream version 1.0.57-1 -> 1.0.58

> Upstream v1.0.58: https://github.com/Finsys/dockhand/releases/tag/v1.0.58
>
> ## What's new in v1.0.58
>
> - ✨ DISABLE_FRAME_PROTECTION allows embedding Dockhand in a trusted iframe (#1867)
> - ✨ Korean interface translation (PR#1910, @hw0603)
> - 🐛 self-update starts correctly on podman with cgroup v2 (#1860)
> - 🐛 reject an ssh git url paired with a username/password credential with a clear message (#1862)
> - 🐛 renaming an environment no longer leaves its stacks showing an empty compose file (#1879)
> - 🐛 no false 403 when opened by an address other than ORIGIN (#1878)
> - 🐛 repository stats no longer time out behind a reverse proxy (#1874)
> - 🐛 the disk usage panel no longer starts a new scan on every page load on slow storage (#1891, PR#1893, @elric667)
> - 🐛 image ships docker-compose 5.7.0 and an updated restic, fixing CVE-2026-116591 (#1884)
> - 🐛 stack deploys no longer write .env file contents to the log (#1890, PR#1894, @elric667)
> - 🐛 scheduled updates honour the dockhand.skip.cooldown label instead of failing at the pull (#1895)
> - 🐛 containerd image store: images no longer show as unused after a rebuild (#1896)
> - 🐛 the git stack webhook secret field shows when a secret is already set (#1898)
> - 🐛 the logs panel shows the container it is switched to while streaming is paused (#1889)
> - 🐛 a webhook arriving during a running git sync no longer sends a false git sync failed notification (PR#1899, @Totopo27)
> - 🐛 a running backup no longer writes tens of MB/s to the database (#1914)
> - 🐛 the stack editor no longer shows variables from a SOPS-encrypted env file as missing (#1913)
> - 🐛 hawser edge compose operations honour COMPOSE_TIMEOUT (#1915)
> - 🐛 stacks under a DATA_DIR inside /root are no longer refused as "Compose path is not allowed" (#1912)
>
> ## Docker image
>
> ```bash
> docker pull fnsys/dockhand:v1.0.58
> ```
>
> Also available as `fnsys/dockhand:latest`
>
> [View on Docker Hub](https://hub.docker.com/r/fnsys/dockhand)

## 1.0.57

- First release: Dockhand 1.0.57 using the PostgreSQL app for its database.

## 1.0.57-1

- Forward SIGTERM to the Dockhand entrypoint and exit 0 when it stops. Node exits 143 on SIGTERM, which the Supervisor reports as an error after every stop.
