# Home Assistant App: PgBouncer

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Connection pooler for PostgreSQL, built from the upstream
[PgBouncer](https://www.pgbouncer.org) source._

## About

PgBouncer sits between your apps and the PostgreSQL app and shares a small number
of server connections between many clients. It finds the PostgreSQL app on its
own and checks logins against the server's own password hashes, so the logins
and rights you set up in the PostgreSQL app work through it unchanged.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [PgBouncer](https://github.com/pgbouncer/pgbouncer) (ISC)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fpgbouncer%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/pgbouncer
