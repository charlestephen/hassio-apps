# Home Assistant App: UniFi Access MCP

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_UniFi Access MCP server - thin wrapper on the official image._

## About

[unifi-mcp](https://github.com/sirkirby/unifi-mcp) exposes UniFi doors, users, credentials, visitors and access logs to MCP clients. This app maps Home Assistant options to the server's variables, serves it over Streamable HTTP behind a bearer token, and runs the image's own command. The server is stateless, so there are no PostgreSQL options.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [unifi-mcp](https://github.com/sirkirby/unifi-mcp) (MIT)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Funifi-access-mcp%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/unifi-access-mcp
