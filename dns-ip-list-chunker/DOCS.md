# DNS/IP List Chunker

Wraps [dns-ip-list-chunker](https://github.com/charlestephen/dns-ip-list-chunker)
`1.3.0`. Chunk oversized blocklists and allowlists for DNS servers and routers.

## Quick start

1. Set `blocklist_urls` and/or `custom_blocklists` (multiline entries, one per line).
2. Optionally add `exclusion_lists` with `output_allowlist: true` for subscribe-able allowlists.
3. Set `admin_token` for `/manage`.
4. Open `http://<host>:8080/` and paste chunk URLs into your DNS/router.

## Example

```yaml
blocklist_urls:
  - "threat:https://example.com/threat.txt"
custom_blocklists:
  - name: corp
    category: custom
    entries: |
      ads.example.com
      203.0.113.10
exclusion_lists:
  - name: family
    category: allow-family
    output_allowlist: true
    entries: |
      school.edu
      10.0.0.0/8
admin_token: "replace-with-a-long-random-secret"
```
