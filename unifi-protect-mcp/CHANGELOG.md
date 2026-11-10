# Changelog

## 0.12.0-1

- The bearer token is now required and is no longer generated, so it is never written to the log. Set **Bearer token** to at least 32 characters, for example the output of `openssl rand -hex 32`.

## 0.12.0

- First release: UniFi Protect MCP 0.12.0 over Streamable HTTP with a bearer token.
