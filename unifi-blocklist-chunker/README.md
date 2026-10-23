# Home Assistant App: UniFi Blocklist Chunker

[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Merge upstream DNS/IP blocklists into UniFi-sized **domain**, **IPv4**, and
**IPv6** chunks — powered by
[charlestephen/unifi-blocklist-chunker][upstream].

Paste list URLs (and optional exclusions) in the config UI, then open `/` for
chunk links or `/manage` (behind your reverse proxy) to exclude entries on
the fly.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v0.1.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/unifi-blocklist-chunker
[upstream]: https://github.com/charlestephen/unifi-blocklist-chunker
