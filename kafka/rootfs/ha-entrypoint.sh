#!/usr/bin/env bash
# Home Assistant wrapper for Apache Kafka (apache/kafka), single-node KRaft
# mode (combined controller+broker, no Zookeeper). Maps app options to
# KAFKA_* environment variables the official image's own start script reads,
# then execs it.
# Reference: https://github.com/apache/kafka/blob/trunk/docker/examples/README.md
set -euo pipefail

OPTIONS=/data/options.json
CLUSTER_ID_FILE=/data/.cluster_id
mkdir -p /data/kafka

get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }

# A KRaft cluster ID is generated once and must survive restarts, or the
# broker refuses to reuse its existing log directory.
if [ ! -s "${CLUSTER_ID_FILE}" ]; then
    kafka-storage.sh random-uuid > "${CLUSTER_ID_FILE}"
    echo "[kafka-app] generated a new CLUSTER_ID"
fi
CLUSTER_ID="$(cat "${CLUSTER_ID_FILE}")"
export CLUSTER_ID

# Sibling add-ons reach this broker by its Supervisor hostname.
ADVERTISED_HOST="$(hostname)"

NODE_ID="$(get node_id)"
export KAFKA_NODE_ID="${NODE_ID:-1}"
export KAFKA_PROCESS_ROLES="controller,broker"
export KAFKA_LISTENERS="CLIENT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093"
export KAFKA_ADVERTISED_LISTENERS="CLIENT://${ADVERTISED_HOST}:9092"
export KAFKA_LISTENER_SECURITY_PROTOCOL_MAP="CLIENT:PLAINTEXT,CONTROLLER:PLAINTEXT"
export KAFKA_CONTROLLER_LISTENER_NAMES="CONTROLLER"
export KAFKA_INTER_BROKER_LISTENER_NAME="CLIENT"
export KAFKA_CONTROLLER_QUORUM_VOTERS="${KAFKA_NODE_ID}@localhost:9093"
export KAFKA_LOG_DIRS="/data/kafka"
declare KAFKA_LOG_RETENTION_HOURS KAFKA_AUTO_CREATE_TOPICS_ENABLE KAFKA_HEAP_OPTS
KAFKA_LOG_RETENTION_HOURS="$(get log_retention_hours)"
KAFKA_AUTO_CREATE_TOPICS_ENABLE="$(get auto_create_topics_enable)"
KAFKA_HEAP_OPTS="$(get heap_opts)"
export KAFKA_LOG_RETENTION_HOURS KAFKA_AUTO_CREATE_TOPICS_ENABLE KAFKA_HEAP_OPTS
export KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
export KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1
export KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1

echo "[kafka-app] starting Apache Kafka ${KAFKA_VERSION:-unknown} (node ${KAFKA_NODE_ID}, KRaft)"
exec /etc/kafka/docker/run
