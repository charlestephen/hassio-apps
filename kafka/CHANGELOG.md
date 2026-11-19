# Changelog

## 4.4.0-1

- Fix: the Dockerfile tried `microdnf`/`apt-get` to install `jq`, but
  `apache/kafka` is Alpine-based — neither exists. The image never
  actually built. Uses `apk` instead.

## 4.4.0

- Initial release.
- Apache Kafka 4.4.0, thin wrapper on the official `apache/kafka` image,
  single-node KRaft broker (no Zookeeper).
- `node_id`, `log_retention_hours`, `auto_create_topics_enable` and
  `heap_opts` options; broker data persisted under `/data/kafka`.
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` are cropped from Apache Kafka's own official logo
  assets (kafka.apache.org/logos).
