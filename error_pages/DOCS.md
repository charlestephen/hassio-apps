# Home Assistant App: Error Pages

## Overview

[error-pages](https://github.com/tarampampam/error-pages) is a tiny HTTP server
that renders good-looking error pages (404, 500, 502, …) in a range of themes.
It's meant to sit behind a **reverse proxy** (Traefik, nginx, Caddy, HAProxy):
when an upstream returns an error, the proxy fetches the matching page from this
app and shows it to the visitor.

The server listens on port **8080** inside the container; set the host port under
the app's **Network** tab (default 8080).

## Configuration

All options map to error-pages environment variables and take effect on restart.

| Option | Default | Description |
|--------|---------|-------------|
| `theme` | `app-down` | Built-in theme (see list below). |
| `default_error_page` | `404` | HTTP code rendered for the root / when no code is given. |
| `send_same_http_code` | `false` | Respond with the rendered page's HTTP status code (not always 200). Useful so proxies see the real code. |
| `show_details` | `false` | Show request details (host, original URI, request ID, …) on the page. |
| `rotation_mode` | `disabled` | Rotate the theme: `disabled`, `random-on-startup`, `random-on-each-request`, `random-hourly`, `random-daily`. |
| `disable_l10n` | `false` | Disable localization (always render in English). |
| `proxy_headers` | `X-Request-Id,X-Trace-Id,X-Correlation-Id,X-Amzn-Trace-Id` | Comma-separated request headers to surface on the page (with `show_details`). |
| `log_level` | `info` | `debug`, `info`, `warn`, `error`. |
| `log_format` | `console` | `console` or `json`. |

### Themes

`app-down`, `cats`, `connection`, `ghost`, `hacker-terminal`, `l7`,
`lost-in-space`, `matrix`, `noise`, `orient`, `shuffle`, `win98`.

### Example

```yaml
theme: ghost
default_error_page: "404"
send_same_http_code: true
show_details: false
rotation_mode: disabled
log_level: info
log_format: json
```

## Previewing pages

Each error page is served at `/{code}.html`, e.g.:

- `http://<home-assistant-ip>:8080/404.html`
- `http://<home-assistant-ip>:8080/500.html`

(The root `/` is just a minimal index — open a specific code to see the theme.)

## Using it from a reverse proxy

### Traefik

Define an `errors` middleware that points at this app and attach it to your
routers:

```yaml
http:
  middlewares:
    error-pages:
      errors:
        status:
          - "400-599"
        service: error-pages
        query: "/{status}.html"
  services:
    error-pages:
      loadBalancer:
        servers:
          - url: "http://<home-assistant-ip>:8080"
# then add `error-pages` to a router's middlewares list
```

### nginx

```nginx
error_page 404 500 502 503 504 = @error_pages;
location @error_pages {
    proxy_pass http://<home-assistant-ip>:8080/$status.html;
    internal;
}
```

With `send_same_http_code: true` the app returns the real status code, so the
client sees e.g. a genuine `404` rather than `200`.
