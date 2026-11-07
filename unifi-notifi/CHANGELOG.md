# Changelog

## 1.0.1

- Replace private-IP placeholder in default `gateway_url` / translations with `https://unifi.example.com`.

## 1.0.0

- Initial release: first-party replacement for the deleted `n8n/unifi-threat-enricher` workflow.
- Receives UniFi Alarm Manager **Custom Webhook** POSTs, waits for the burst to settle, logs into the gateway (API key or local user), reads recent threat / honeypot inspection logs, dedupes threat IDs for 24h, and posts one Slack Block Kit message with:
  - highest risk + blocked count
  - alarm name, site, timestamp, Open UniFi link
  - top signatures (risk / type)
  - top source IPs (location, direction, action)
  - top clients (name + MAC)
  - sparse extras from the first threat (protocol / port / host when present)
- Keeps noise down: settle window, 24h seen-ID dedupe, muted-signature skip, top-5 group lines only. No interactive Slack buttons in this release.
