# Home Assistant App: Grafana Alloy

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Ship the logs of **every container** on your Home Assistant host to Loki with
[Grafana Alloy](https://grafana.com/docs/alloy/latest/) — the supported successor
to Promtail. Bring your own Alloy config when you need to, or use the built-in
default that just works.

## Features

- Tails all host container logs via the Docker socket and forwards them to Loki.
- Fully overridable: paste a complete Alloy config on the Configuration page, or
  drop a `config.alloy` into the app config directory.
- Built-in Alloy web UI / metrics endpoint on port `12345`.
- Persistent WAL/state in `/data` so logs aren't re-sent after a restart.

## Quick start

1. Install the app from this repository.
2. **Turn off Protection mode** on the app's Info tab (required for Docker log
   access — see [DOCS.md](DOCS.md)).
3. Set **Loki push URL** to your Loki endpoint and start the app.

See [DOCS.md](DOCS.md) for full configuration details.

## Architectures

`amd64`, `aarch64`.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Falloy%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/alloy
