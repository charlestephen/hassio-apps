# Changelog

## 26.8.40.7

- Initial release.
- ClickHouse 26.8.40.7 (26.8 LTS line), thin wrapper on the official
  `clickhouse/clickhouse-server` Alpine image.
- `default_user_password`, `max_server_memory_usage_to_ram_ratio` and
  `log_level` options; all data redirected under `/data/clickhouse`.
- Ships an AppArmor profile (`apparmor.txt`), including `SYS_NICE` (used by
  ClickHouse to prioritize its own threads).
- `icon.png`/`logo.png` use ClickHouse's own mark (from its GitHub
  organization avatar), composited with the project name for the logo.
