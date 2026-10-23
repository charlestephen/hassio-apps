# Changelog

## 0.1.0

- Initial Home Assistant app wrapping
  [unifi-blocklist-chunker](https://github.com/charlestephen/unifi-blocklist-chunker)
  `0.1.0`.
- Config UI for blocklist URLs, chunk size, refresh interval, public base URL,
  admin token, and seed exclusions.
- Persisted exclusions on `/data`; `/manage` UI documented for reverse-proxy
  use.
- AppArmor profile, upstream version tracking, and Renovate pin.
