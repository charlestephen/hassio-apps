# Home Assistant App: Pocket ID

[![Build][build-shield]][build]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_OpenID Connect Certified™ IdP with passkey-only sign-in — thin wrapper on the
official [Pocket ID](https://pocket-id.org) image._

## About

[Pocket ID](https://github.com/pocket-id/pocket-id) is a simple OIDC / OAuth 2.0
provider. Users authenticate with passkeys (no passwords). This app maps HA
options to Pocket ID environment variables, persists `/app/data` on the
Supervisor `/data` volume, then `exec`s the upstream entrypoint.

The app version tracks upstream releases via `upstream_repo`.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [Pocket ID](https://github.com/pocket-id/pocket-id) (BSD-2-Clause)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
