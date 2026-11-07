# UniFi threat enricher (n8n)

n8n workflow with **v1 parity** to the Home Assistant
[`unifi-notifi`](../../unifi-notifi/) app: Alarm Manager threat webhooks →
settle → UniFi lookback → Slack Block Kit.

Use **either** this workflow **or** `unifi-notifi` on the same alarm — not both.

Tested against the same enrichment fields as `unifi-notifi` 1.0.0. Targeted at
n8n 1.x / 2.x (Wait + Webhook + Code + HTTP Request).

## What it posts

One Slack message per settled burst:

- Header: threat count + lookback window
- Context: highest risk, blocked/total, alarm name, site, timestamp, Open UniFi
- Top signatures (risk / type), sources (location, direction, action), clients
- Sparse extras when present: protocol, port, host

Noise controls: settle wait, 24h seen-ID dedupe (workflow static data), muted
signature skip (static data; no Slack mute buttons in v1 — same as the HA app).

Interactive Block / Mute / Siren buttons from the pre-deletion workflow are
**out of scope** for v1 (HA `unifi-notifi` 1.0.0 also omits them).

## Import

1. In n8n: **Workflows → Import from File** → select `workflow.json`.
2. Open the **Config** Code node and set:
   - `gatewayUrl`, `site`
   - `apiKey` **or** leave empty and attach a login credential (below)
   - `slackWebhookUrl` (Slack Incoming Webhook)
   - `settleSeconds` / `lookbackMinutes` if you want non-defaults
   - `verifyTls` (`false` for typical self-signed gateways)
3. Change `CHANGE-ME` in the **UniFi alarm** webhook path to a long random
   token, then **Publish** the workflow (static data only persists for
   production executions).

### Credentials

| When | Node | Credential |
| --- | --- | --- |
| `apiKey` set in Config | — | None for UniFi (key sent as `X-API-KEY`) |
| `apiKey` empty | `UniFi login` | **Custom Auth** body `{"username":"...","password":"..."}` for a local UniFi account |
| Always | — | Slack Incoming Webhook URL in Config (`slackWebhookUrl`) — no Slack OAuth bot |

### Alarm Manager

1. Network → Alarm Manager → **Threats Detected** (and optionally honeypot).
2. Action → Webhook (POST) →
   `https://<n8n>/webhook/unifi-threat/<token>`.
3. Enable **Ignore Repeated Actions** (n8n Wait is per execution; it does not
   reset a shared timer the way the HA app does).
4. Keep push/email as fallback; do not also point Slack Post or `unifi-notifi`
   at the same alarm.

## Parity vs `unifi-notifi` (v1)

| Behavior | HA app | This workflow |
| --- | --- | --- |
| Settle before lookback | yes (resetting timer) | yes (Wait per webhook; pair with Ignore Repeated Actions) |
| Lookback threats + inspection logs | yes | yes |
| 24h seen-ID dedupe | `/data/state.json` | workflow static data |
| Muted signature skip | yes (no UI in 1.0.0) | yes (static `muted`; no UI) |
| Slack via incoming webhook | yes | yes |
| Risk / blocked / alarm / site / time / UniFi link | yes | yes |
| Top signatures / sources / clients + proto/port/host | yes | yes |
| API key or username/password | yes | yes |
| Block / Mute / Siren buttons | no | no |

## Notes

- Threat-alert and inspection-log URLs are undocumented UniFi Network v2 APIs
  and can change with Network updates.
- Broader parameterization (env-driven Config, multi-site, etc.) is left for a
  later revision — keep edits in the Config node for now.
