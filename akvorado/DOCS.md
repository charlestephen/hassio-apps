# Home Assistant App: Akvorado

## Overview

This app wraps [akvorado/akvorado](https://github.com/akvorado/akvorado)
`2026.10.1` (AGPL-3.0). Akvorado collects flow export protocols (NetFlow v9,
IPFIX, sFlow), enriches them, stores them in ClickHouse, and visualizes them
in a web console.

Upstream's own image is a `distroless/static` build with no shell — it can't
run Supervisor's options templating or supervise its own four cooperating
processes. This app's base is the Home Assistant base image instead (same as
most other apps here); only the compiled `akvorado` binary is copied in from
upstream's image at build time. The four processes
(**orchestrator**, **inlet**, **outlet**, **console**) each run as their own
s6 service inside this one container — upstream's own `docker-compose.yml`
runs them as four separate containers instead, which isn't possible for a
single Home Assistant app.

## Required dependencies

This app does not work standalone. Install and start these three apps from
this repository first:

| Dependency | App | Used for |
|---|---|---|
| Message bus | [Kafka](../kafka/) | Buffers flows between inlet and outlet |
| Flow storage | [ClickHouse](../clickhouse/) | Stores enriched flow records |
| Console cache | [Valkey](../valkey/) | Session/query cache for the web console |

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `kafka_host` | string | `dd815a57-kafka` | Hostname of the Kafka app. |
| `kafka_port` | port | `9092` | Kafka client port. |
| `clickhouse_host` | string | `dd815a57-clickhouse` | Hostname of the ClickHouse app. |
| `clickhouse_port` | port | `9000` | ClickHouse **native protocol** port (not the HTTP port) as seen by other containers. |
| `clickhouse_password` | password | empty | Must match the ClickHouse app's `default_user_password`. |
| `redis_host` | string | `dd815a57-valkey` | Hostname of the Valkey app. |
| `redis_port` | port | `6379` | Valkey port. |

## Architecture inside this app

| Process | Internal HTTP port | Role |
|---|---|---|
| orchestrator | `8080` | Serves merged config to the other three processes; not published outside the container. |
| inlet | `8081` | Receives flows on `2055/udp`, `4739/udp`, `6343/udp`; metrics only, not published. |
| outlet | `8082` | Enriches flows and writes them to ClickHouse; metrics only, not published. |
| console | `8083` | Web UI — this is the published `webui:` port. |

inlet/outlet/console each wait for the orchestrator's `/api/v0/metrics`
endpoint to answer before starting, since all four start concurrently under
s6.

## Scope of this release

This app wires the core pipeline (flows in → Kafka → ClickHouse → console
out) with upstream's documented defaults for everything else. Not yet
configured: SNMP interface-name enrichment, GeoIP, BGP/BMP-based AS-path
enrichment, and custom network/exporter classifiers — add
`outlet.metadata`/`outlet.routing`/`outlet.networks`/`outlet.core` keys to
`/etc/templates/akvorado.yaml`'s `outlet:` block (currently `{}`, i.e.
upstream defaults) when you need them. See upstream's
[configuration reference](https://github.com/akvorado/akvorado/blob/main/console/data/docs/50-configuration.md).

## Web UI

After the orchestrator and console are both up, access the console at
`http://<supervisor-hostname>:8083`.

## Data

The console's SQLite database lives at `/data/console.sqlite`; flow data
itself is stored in the ClickHouse app, not here. `/data` is included in
Home Assistant backups.
