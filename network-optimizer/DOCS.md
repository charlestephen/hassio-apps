# Home Assistant App: UniFi Network Optimizer

## Installation

1. Install the app and (recommended) the companion **Network Optimizer Speedtest** app.
2. Start the app, then open the **Log** tab to read the auto-generated admin password.
3. Open the Web UI (port `8042`). In Settings, enter your UniFi controller URL and
   create a **Local Access Only** account on the controller (Ubiquiti SSO won't work),
   then Connect and run an initial Audit.

## Data

`/app/data`, `/app/logs`, and `/app/ssh-keys` are redirected to the app's
`/data` volume, so the SQLite database, logs, and deployment SSH keys persist
across restarts and updates.

## Options

All upstream environment variables are exposed:

| Option | Env var | Notes |
|---|---|---|
| `timezone` | `TZ` | Application timezone. |
| `bind_localhost_only` | `BIND_LOCALHOST_ONLY` | Bind to localhost only (default off = network accessible). |
| `app_password` | `APP_PASSWORD` | Fallback admin password (the database setting takes precedence). |
| `host_ip` | `HOST_IP` | Server IP for speed testing and CORS. |
| `host_name` | `HOST_NAME` | Hostname for canonical URL enforcement. |
| `reverse_proxied_host_name` | `REVERSE_PROXIED_HOST_NAME` | Public hostname when behind a reverse proxy. |
| `iperf3_server_enabled` | `IPERF3_SERVER_ENABLED` | Enable the iperf3 server (port 5201). |
| `openspeedtest_port` | `OPENSPEEDTEST_PORT` | Direct speedtest port (default 3005). |
| `openspeedtest_host` | `OPENSPEEDTEST_HOST` | Alternate speedtest hostname. |
| `openspeedtest_https` | `OPENSPEEDTEST_HTTPS` | Enable HTTPS mode behind a TLS proxy. |
| `openspeedtest_https_port` | `OPENSPEEDTEST_HTTPS_PORT` | HTTPS proxy port (default 443). |
| `log_level` | `LOG_LEVEL` | Framework log level. |
| `app_log_level` | `APP_LOG_LEVEL` | Application log level. |
| `demo_mode_mappings` | `DEMO_MODE_MAPPINGS` | Demo-mode mappings (advanced). |

> Speedtest reverse proxies need HTTP/1.1, so use a separate hostname for the
> speedtest vs. the main app when terminating TLS upstream.

## Credits

Application by [Ozark-Connect](https://github.com/Ozark-Connect/NetworkOptimizer);
app approach inspired by [LOOHP/home-assistant-apps](https://github.com/LOOHP/home-assistant-apps).
