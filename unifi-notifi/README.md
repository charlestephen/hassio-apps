# UniFi Notifi

Home Assistant app that sits between **UniFi Alarm Manager** and **Slack**.

Alarm Manager threat webhooks are sparse (often just an `alert_key` and site).
This app settles the burst, reads the gateway threat / inspection logs, and
posts one enriched Slack Block Kit message per burst.

## Why

UniFi’s built-in Slack Post action is a one-liner. This app enriches inside
hassio-apps; the matching n8n workflow is
[`n8n/unifi-threat-enricher`](../n8n/unifi-threat-enricher/) (do not run both
against the same alarm).

## Quick start

1. Install the app and set `gateway_url`, UniFi credentials (API key preferred),
   `slack_webhook_url`, and a long random `webhook_token`.
2. In Network → Alarm Manager, point a **Threats Detected** alarm at
   `http://<ha-host>:8099/webhook/<token>` (Custom Webhook, POST).
3. Enable **Ignore Repeated Actions** on the UniFi side so the console does
   not spam the settle window.

See [DOCS.md](DOCS.md) for options and payload details.
