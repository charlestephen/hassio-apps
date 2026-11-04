# Home Assistant App: DNS/IP List Chunker

[![Release][release-shield]][release]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Merges DNS/IP blocklists (and optional allowlists) into sized plain-text chunks
for DNS servers and routers that reject oversized external lists. Powered by
[charlestephen/dns-ip-list-chunker][upstream] `1.3.0`.

## Configuration highlights

| Option | Description |
| --- | --- |
| `blocklist_urls` | Upstream URLs; optional `category:https://…` tag |
| `custom_blocklists` | Named inline lists (`name`, `category`, multiline `entries`) |
| `exclusion_lists` | Named exclude/allow lists; `output_allowlist` publishes `/allowlists/…` |
| `exclusions_urls` | Remote exclusion list URLs |
| `admin_token` | Gates `/manage` |

Open `/` for block + allowlist chunk URLs to paste into your DNS/router.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[release-shield]: https://img.shields.io/badge/version-v1.3.0-blue.svg
[release]: https://github.com/charlestephen/hassio-apps/tree/main/dns-ip-list-chunker
[upstream]: https://github.com/charlestephen/dns-ip-list-chunker
