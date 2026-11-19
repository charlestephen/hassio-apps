# Home Assistant App: UDP Mirror

## Overview

This app is a thin wrapper on the official
[`czerwonk/udp-mirror`](https://github.com/czerwonk/udp-mirror) image, `0.1.1`
(MIT License). It listens for UDP packets on one address and sends a copy of
every packet to each configured receiver — useful for pointing more than one
UDP-based analysis tool (e.g. a NetFlow/sFlow collector) at the same flow
export stream. The wrapper builds upstream's CLI flags from app options and
execs the binary directly.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `listen_address` | string | `:4560` | Address/port to listen for incoming UDP packets on. |
| `receivers` | list of strings | `["127.0.0.1:2055"]` | `host:port` targets each incoming packet is copied to. |

### Example

```yaml
listen_address: ":4560"
receivers:
  - "dd815a57-akvorado:2055"
  - "192.168.1.50:2055"
```

## Networking

Point your router/switch's flow export (NetFlow, sFlow, IPFIX) at this app's
published UDP port, then list every tool that should receive a copy in
`receivers`.
