# Home Assistant App: Authentik

[![Build][build-shield]][build]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Identity provider (OpenID Connect, OAuth 2.0, SAML, LDAP) — thin wrapper on
the official [authentik](https://goauthentik.io) image._

## About

[authentik](https://github.com/goauthentik/authentik) is an open-source identity
provider. This app maps Home Assistant options to `AUTHENTIK_*` variables and
runs the upstream entrypoint in `allinone` mode, so the server and the worker
share one container. It uses the PostgreSQL app in this repository for its
database instead of bundling one.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [authentik](https://github.com/goauthentik/authentik) (MIT)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
