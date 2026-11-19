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
| `snmp_community` | password | `public` | SNMPv1/v2c read-only community string. Ignored once `snmp_v3_user` is set. |
| `snmp_v3_user` | string | empty | Set to use SNMPv3 instead of v1/v2c — takes priority over `snmp_community` whenever non-empty. |
| `snmp_v3_auth_protocol` | list | `SHA` | `none`, `MD5`, `SHA`, `SHA224`, `SHA256`, `SHA384`, `SHA512`. |
| `snmp_v3_auth_passphrase` | password | empty | Authentication passphrase for the SNMP v3 user. |
| `snmp_v3_priv_protocol` | list | `AES` | `none`, `DES`, `AES`, `AES192`, `AES256`, `AES192-C`, `AES256-C` (`-C` are Cisco variants). |
| `snmp_v3_priv_passphrase` | password | empty | Privacy (encryption) passphrase for the SNMP v3 user. |
| `default_sampling_rate` | int | `0` | Used only when an exporter doesn't report its own sampling rate in-band. `0` leaves akvorado's own default (reject the flow). See below. |

SNMP (v1/v2c or v3) is **required**, not optional enrichment — akvorado
discards a flow entirely if it can't resolve the exporter's interface name
via SNMP. The sampling rate is a **separate** requirement, resolved
in-band from the exporter's own NetFlow/IPFIX Option records when it sends
them — SNMP is not involved in it at all, despite both showing up as
`akvorado_outlet_core_flows_errors_total` errors.

## Architecture inside this app

| Process | Internal HTTP port | Role |
|---|---|---|
| orchestrator | `8080` | Serves merged config to the other three processes and dictionary data (protocol/ASN names) to the ClickHouse app; not published to the host, but reachable from sibling containers on the Supervisor's internal network. |
| inlet | `8081` | Receives flows on `2055/udp`, `4739/udp`, `6343/udp`; metrics only, not published. |
| outlet | `8082` | Enriches flows and writes them to ClickHouse; metrics only, not published. |
| console | `8083` | Web UI — this is the published `webui:` port. |

inlet/outlet/console each wait for the orchestrator's `/api/v0/metrics`
endpoint to answer before starting, since all four start concurrently under
s6.

## Scope of this release

This app wires the core pipeline (flows in → Kafka → ClickHouse → console
out) plus SNMP-based interface-name resolution (`snmp_community`). Not yet
configured: GeoIP and custom network/exporter classifiers — add
`outlet.networks`/`outlet.core` keys to `/etc/templates/akvorado.yaml`'s
`outlet:` block when you need them. The BMP provider (port `10179/tcp`,
used for AS-path enrichment) is already running on upstream's own defaults —
verified live, it listens even with no `outlet.routing` config — it's just
not published to the host; add it to this app's `ports`/`ports_description`
if you want to reach it from outside the container. See upstream's
[configuration reference](https://github.com/akvorado/akvorado/blob/main/console/data/docs/50-configuration.md).

### SNMP v1/v2c vs v3

Set `snmp_v3_user` to use SNMPv3 (authentication + optional privacy
encryption); leave it empty to use the simpler `snmp_community` (v1/v2c)
string instead. Akvorado itself picks v3 whenever a username is configured,
regardless of what `snmp_community` is set to.

### Sampling rate

Even with SNMP fully working, akvorado still rejects every flow
(`error="sampling rate missing"`) if the exporter never reports its own
sampling rate in-band (some NetFlow v9/IPFIX exporters send this via an
Option Template/Option Data record; others don't). If you see this error in
the outlet's metrics after SNMP errors have cleared, set
`default_sampling_rate` to your exporter's actual configured ratio (e.g.
`1000` for 1:1000 sampling). Getting this number wrong doesn't break
anything visibly — it silently multiplies/divides every traffic figure by
the wrong factor, so confirm the real ratio from the exporter's own flow
export configuration rather than guessing.

## Web UI

After the orchestrator and console are both up, access the console at
`http://<supervisor-hostname>:8083`.

## Data

The console's SQLite database lives at `/data/console.sqlite`; flow data
itself is stored in the ClickHouse app, not here. `/data` is included in
Home Assistant backups.
