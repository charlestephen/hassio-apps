# Home Assistant App: ClickHouse

## Overview

This app is a thin wrapper on the official
[`clickhouse/clickhouse-server`](https://github.com/ClickHouse/ClickHouse)
image, `26.8.40.7` (Apache-2.0), tracking the `26.8` LTS line. The wrapper
only sets the `CLICKHOUSE_*` environment variables upstream's own entrypoint
already understands and redirects all data/config paths under `/data`, then
runs upstream's own `/entrypoint.sh`.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `default_user_password` | password | empty | Password for the `default` user. **Set this before exposing the server.** |
| `max_server_memory_usage_to_ram_ratio` | float | `0.8` | Fraction of host RAM ClickHouse may use. |
| `log_level` | list | `information` | Server log verbosity. |

### Example

```yaml
default_user_password: "a-strong-password"
max_server_memory_usage_to_ram_ratio: 0.6
```

## Connecting

From another app on the Home Assistant network (e.g. Akvorado's outlet/console):

```
HTTP:    http://<supervisor-hostname>:8123
Native:  <supervisor-hostname>:9100   (container port 9000, remapped on the host)
user:    default
password: <default_user_password, if set>
```

Other apps in this repository that use ClickHouse (e.g. Akvorado) default
their `clickhouse_host`/`clickhouse_port` options to this app's Supervisor
hostname and the HTTP port (8123).

## Data

All databases, logs, and user files live under `/data/clickhouse` and are
included in Home Assistant backups. For large flow-storage workloads,
consider the same external-drive approach documented for the PostgreSQL app.
