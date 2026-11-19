# Home Assistant App: Valkey

## Overview

This app is a thin wrapper on the official [`valkey/valkey`](https://github.com/valkey-io/valkey)
image, `9.1.4`. [Valkey](https://valkey.io) is a Redis-protocol-compatible,
in-memory key-value store maintained by the Linux Foundation under the
BSD-3-Clause license. The wrapper maps app options to `valkey-server` CLI
flags and runs upstream's own binary directly; data persists under `/data`.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `password` | password | empty | `requirepass`. Leave empty only on a fully trusted network. |
| `maxmemory` | string | `0` | Memory cap, e.g. `256mb`. `0` is unlimited. |
| `maxmemory_policy` | list | `noeviction` | Eviction policy once `maxmemory` is reached. |
| `log_level` | list | `notice` | `valkey-server` log verbosity. |

### Example

```yaml
password: "a-strong-password"
maxmemory: "256mb"
maxmemory_policy: allkeys-lru
```

## Connecting

From another app on the Home Assistant network:

```
host:     <supervisor-hostname-or-ip>
port:     6379
password: <password, if set>
```

Other apps in this repository that use Valkey (e.g. Akvorado) default their
`redis_host` option to this app's Supervisor hostname.

## Data

All data lives in `/data` and is included in Home Assistant backups. Valkey's
default persistence (RDB snapshotting) is used; this is a cache, not a
system of record — treat anything stored here as disposable.
