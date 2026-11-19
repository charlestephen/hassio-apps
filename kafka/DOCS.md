# Home Assistant App: Apache Kafka

## Overview

This app is a thin wrapper on the official [`apache/kafka`](https://github.com/apache/kafka)
image, `4.4.0` (Apache-2.0, Apache Software Foundation). It runs a single
broker in **KRaft mode** — Kafka's own metadata quorum, acting as both
controller and broker — so no separate Zookeeper app is needed. The wrapper
maps app options to `KAFKA_*` environment variables and runs upstream's own
`/etc/kafka/docker/run` start script, which formats the KRaft storage
directory on first boot.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `node_id` | int | `1` | KRaft node ID. Leave at `1` for a single-node broker. |
| `log_retention_hours` | int | `168` | How long topic data is kept (7 days). |
| `auto_create_topics_enable` | bool | `true` | Create a topic automatically on first publish. |
| `heap_opts` | string | `-Xmx512M -Xms512M` | JVM heap flags passed as `KAFKA_HEAP_OPTS`. |

## Connecting

From another app on the Home Assistant network (e.g. Akvorado):

```
bootstrap.servers: <supervisor-hostname>:9092
```

Other apps in this repository that use Kafka (e.g. Akvorado) default their
`kafka_host` option to this app's Supervisor hostname.

## Data

Broker logs and the KRaft cluster metadata live in `/data/kafka` and are
included in Home Assistant backups. The cluster ID is generated once on
first start and persisted at `/data/.cluster_id` — do not delete it, or the
broker will refuse to reuse the existing log directory.

## Single-node limitations

This app runs exactly one broker with replication factor 1 throughout
(`KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR`, `KAFKA_TRANSACTION_STATE_LOG_*`).
It is suitable as a lightweight message bus for homelab workloads (e.g.
Akvorado's flow pipeline), not for production multi-broker durability.
