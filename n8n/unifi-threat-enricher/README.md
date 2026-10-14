# UniFi threat enricher (n8n)

An n8n workflow that sits between UniFi Alarm Manager and Slack.

1. A **Threats Detected** alarm calls the `UniFi alarm` webhook.
2. The workflow waits for the burst to settle, logs in to the gateway, and
   reads every threat from the last 15 minutes plus each threat's
   inspection log (signature, risk, direction, country, client, action).
3. It skips threats it already reported and muted signatures, groups the
   rest by signature, source IP, and client, and posts one Block Kit
   message to Slack.
4. Slack buttons call the `Slack actions` webhook, which verifies the Slack
   signature and then blocks a client, adds a source IP to a block list,
   mutes a signature, or sounds a Protect siren. The result is posted back
   into the channel.

Tested on n8n 2.43.4.

## Setup

### n8n environment

The `Verify Slack` Code node needs these variables. When task runners run
in external mode, set them on the runner as well.

```sh
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
NODE_FUNCTION_ALLOW_BUILTIN=crypto
SLACK_SIGNING_SECRET=<Slack app → Basic Information → Signing Secret>
```

### Import and credentials

Import `workflow.json`, then attach credentials:

| Node | Credential type | Value |
| --- | --- | --- |
| `UniFi login` | Custom Auth | `{"body": {"username": "...", "password": "..."}}` for a local-only UniFi account. The Block buttons need a Network role that can edit settings. |
| `Post to Slack` | Slack API | Bot token with `chat:write`. Invite the bot to the channel. |
| `Sound siren` | Header Auth | Name `X-API-KEY`, value a Protect API key (UniFi OS → Integrations). |

Edit the values at the top of the `Config` node: gateway URL, site, Slack
channel, lookback window, and the optional `firewallGroupId`,
`protectWebhookId`, and `allowedSlackUserIds`. `allowUnauthorizedCerts` is
enabled on the UniFi requests for the gateway's self-signed certificate.

- **Block IP** appends to an existing IPv4 address group. The group must
  already be used by a block policy. Its `_id` is listed by
  `GET /proxy/network/api/s/<site>/rest/firewallgroup`.
- **Sound siren** calls a Protect Alarm Manager incoming webhook. Set
  `protectWebhookId` to show the button.

### Webhooks

- **UniFi**: change `CHANGE-ME` in the `UniFi alarm` path to a long random
  string, and publish the workflow. In Network → Alarm Manager, add a
  **Webhook (POST)** action to the Threats Detected alarm that points at
  `https://<n8n>/webhook/unifi-threat/<token>`, and enable
  **Ignore Repeated Actions**. Keep the existing push or email action as a
  fallback for when n8n is down.
- **Slack**: in the Slack app, enable **Interactivity** with the Request URL
  `https://<public n8n>/webhook/unifi-threat-slack`. Slack must be able to
  reach it, so expose only that path (for example with a Cloudflare Tunnel
  ingress rule) and keep the UniFi webhook internal.

## Notes

- The threat-alert and inspection-log endpoints are the internal
  `/proxy/network/v2` API the UniFi web app uses. They are undocumented
  and can change with Network updates.
- Already-reported threat IDs and muted signatures live in the workflow's
  static data, which n8n only saves for published (production) executions.
