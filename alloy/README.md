# Home Assistant Add-on: Grafana Alloy

Ship the logs of **every container** on your Home Assistant host to Loki with
[Grafana Alloy](https://grafana.com/docs/alloy/latest/) — the supported successor
to Promtail. Bring your own Alloy config when you need to, or use the built-in
default that just works.

## Features

- Tails all host container logs via the Docker socket and forwards them to Loki.
- Fully overridable: paste a complete Alloy config on the Configuration page, or
  drop a `config.alloy` into the add-on config directory.
- Built-in Alloy web UI / metrics endpoint on port `12345`.
- Persistent WAL/state in `/data` so logs aren't re-sent after a restart.

## Quick start

1. Install the add-on from this repository.
2. **Turn off Protection mode** on the add-on's Info tab (required for Docker log
   access — see [DOCS.md](DOCS.md)).
3. Set **Loki push URL** to your Loki endpoint and start the add-on.

See [DOCS.md](DOCS.md) for full configuration details.

## Architectures

`amd64`, `aarch64`.
