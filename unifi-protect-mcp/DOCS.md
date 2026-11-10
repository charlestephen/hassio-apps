# UniFi Protect MCP

Thin Home Assistant wrapper around the official
[UniFi Protect MCP](https://github.com/sirkirby/unifi-mcp) server (`0.12.0`). It
lets MCP clients such as Claude manage UniFi cameras, recordings, sensors and smart detections.

The MCP server keeps no state and uses no database, so this app has no
PostgreSQL options.

## Quick start

1. In the UniFi console, create an API key (or a local admin user) for the
   assistant.
2. Install **UniFi Protect MCP** and set **UniFi host** and **UniFi API key**.
3. Start the app. Open the log once and copy the line `bearer token (shown
   once)`, or set **Bearer token** to a value of your own with at least 32
   characters.
4. Set **Allowed hosts** to the address clients use, with the port, for example
   `192.168.1.10:3111`.
5. Add the server to your MCP client at `http://<home-assistant>:3111/mcp`
   with the header `Authorization: Bearer <token>`.

For Claude Code:

```
claude mcp add --transport http unifi-protect http://192.168.1.10:3111/mcp \
  --header "Authorization: Bearer <token>"
```

## Security

The endpoint carries the controller privileges of the API key or user you give
it. The app always requires a bearer token, but the token travels in clear text
over plain HTTP. Keep the port on your LAN, or put the app behind a TLS reverse
proxy such as Traefik before you expose it anywhere else.

By default every change returns a preview and needs `confirm=true`. Set
**Read-only mode** to block changes completely.

## TLS to the console

Consoles use a self-signed certificate. The server does not check it unless you
pin a fingerprint or turn on **Verify TLS certificate**. To read the fingerprint:

```
openssl s_client -connect 192.168.1.1:443 </dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256
```

## Options

| Option | Variable |
| --- | --- |
| UniFi host / port / API key / username / password | `UNIFI_HOST`, `UNIFI_PORT`, `UNIFI_API_KEY`, `UNIFI_USERNAME`, `UNIFI_PASSWORD` |
| Verify TLS certificate / Certificate fingerprint | `UNIFI_VERIFY_SSL`, `UNIFI_SSL_FINGERPRINT` |
| Bearer token | `UNIFI_MCP_HTTP_AUTH_TOKEN` |
| Allowed hosts | `UNIFI_MCP_ALLOWED_HOSTS` |
| Permission mode / Read-only mode | `UNIFI_TOOL_PERMISSION_MODE`, `UNIFI_READ_ONLY` |
| OpenTelemetry endpoint | `OTEL_EXPORTER_OTLP_ENDPOINT` |

The app always sets `UNIFI_MCP_HTTP_ENABLED=true`, `UNIFI_MCP_HTTP_TRANSPORT=streamable-http`,
`UNIFI_MCP_HOST=0.0.0.0` and `UNIFI_MCP_PORT=3001`.

## Extra environment variables

The box at the bottom of the options adds any other `UNIFI_*` variable, such as
the policy gates described in the upstream
[permissions guide](https://github.com/sirkirby/unifi-mcp/blob/main/docs/permissions.md).
Rows marked secret stay masked in the UI and the log. They are applied last, so
they override the options above.
