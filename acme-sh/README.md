# Home Assistant App: Acme.sh

[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Certificate client built on the official `ghcr.io/acmesh-official/acme.sh`
image. Issues and renews certificates, runs deploy hooks, and copies the
results into `/ssl`.

acme.sh upgrades itself on start and before each renewal. The image is not
pinned to a release.

See [DOCS.md](DOCS.md) for setup.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v1.0.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/acme-sh
