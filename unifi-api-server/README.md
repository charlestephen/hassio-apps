# Home Assistant App: UniFi API Server

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_REST and GraphQL API for UniFi - thin wrapper on the official UniFi API Server image._

## About

The [UniFi API Server](https://github.com/sirkirby/unifi-mcp/tree/main/apps/api) offers typed REST resources, read-only GraphQL queries, SSE streams and scoped API keys over UniFi Network, Protect and Access. This app maps Home Assistant options to `UNIFI_API_*` variables, keeps the state under `/data` and runs the image's own command. Upstream stores its state in SQLite, so there are no PostgreSQL options.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [unifi-mcp](https://github.com/sirkirby/unifi-mcp) (MIT)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Funifi-api-server%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/unifi-api-server
