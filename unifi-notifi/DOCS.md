# Home Assistant App: UniFi Notifi

Enriches UniFi Network **Alarm Manager** threat webhooks into a single Slack
Block Kit message with signature, source, client, severity, site, and time.

## How it works

1. Alarm Manager POSTs to `http://<host>:8099/webhook/<webhook_token>` (sparse body).
2. The app resets a settle timer (`settle_seconds`, default 45).
3. After the burst settles it authenticates to the UniFi gateway, reads threat
   alerts from the last `lookback_minutes`, skips IDs already reported in the
   last 24h, loads each threat’s inspection log, and posts one Slack message.

State (seen threat IDs + muted signatures) is stored under `/data/state.json`.

## Setup

### App options

| Option | Required | Description |
| --- | --- | --- |
| `gateway_url` | yes | UniFi OS / Network console base URL |
| `site` | yes | Network site name (usually `default`) |
| `unifi_api_key` | preferred | UniFi OS API key (`X-API-KEY`) |
| `unifi_username` / `unifi_password` | alt | Local account when no API key |
| `slack_webhook_url` | yes | Slack incoming webhook |
| `webhook_token` | yes | Shared secret in the webhook path |
| `settle_seconds` | no | Burst settle window (default 45) |
| `lookback_minutes` | no | Threat log lookback (default 15) |
| `verify_tls` | no | Verify gateway TLS (default off) |
| `alarm_name_fallback` | no | Label when the webhook omits a name |
| `log_level` | no | `debug` / `info` / `warn` / `error` |

### Alarm Manager

1. Create or edit a **Threats Detected** (and optionally honeypot) alarm.
2. Action → **Webhook** → **Custom Webhook** → POST.
3. Delivery URL: `http://<home-assistant-host>:8099/webhook/<webhook_token>`.
4. Enable **Ignore Repeated Actions**.
5. Remove or mute any direct Slack Post on the same alarm to avoid double posts.

Point the alarm at the HA host (or a reverse-proxy path that reaches port
8099). Keep the webhook internal when possible.

### Health

`GET /health` returns `{"status":"ok","app":"unifi-notifi"}`.

## Slack fields

Each message includes (only when UniFi provides them):

- Header with threat count + lookback window
- Highest risk, blocked/total, alarm name, site, timestamp, Open UniFi link
- Top signatures (count, risk, signature type)
- Top source IPs (location/country, direction, action)
- Top clients (friendly name + MAC)
- Sparse extras from the first threat: protocol, port, host

No interactive Block / Mute / Siren buttons in 1.0.0 — those lived in the
old n8n workflow and can return later if needed.

## Notes

- Threat and inspection-log endpoints are the undocumented UniFi Network v2
  APIs the console UI uses; they can change with Network updates.
- Prefer an API key over a password when your console supports Integrations.
- Do not also run a copy of the deleted n8n enricher against the same alarm.
