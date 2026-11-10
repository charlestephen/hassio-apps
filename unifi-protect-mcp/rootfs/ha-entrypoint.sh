#!/usr/bin/env bash
# Home Assistant wrapper for the UniFi Protect MCP server (sirkirby/unifi-mcp).
# Maps /data/options.json to the server's variables and serves MCP over
# Streamable HTTP behind a bearer token, then runs the image's own command.
set -euo pipefail

export OPTIONS=/data/options.json
if [[ ! -f "${OPTIONS}" ]]; then
    echo "[unifi-protect-mcp-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

env_file="$(mktemp)"
python3 - > "${env_file}" <<'PY'
import json, os, re, secrets, shlex, sys, pathlib

APP = "unifi-protect-mcp"
o = json.load(open(os.environ["OPTIONS"]))
env = {}


def log(msg):
    print(f"[{APP}-app] {msg}", file=sys.stderr)


def put(name, value, hidden=False):
    if value in (None, ""):
        return
    env[name] = str(value)
    log(f"set {name}" + (" (hidden)" if hidden else f"={value}"))


def flag(name, value):
    env[name] = "true" if value else "false"
    log(f"set {name}={env[name]}")


if not o.get("unifi_host"):
    log("ERROR: set the UniFi host")
    sys.exit(1)
if not (o.get("unifi_api_key") or (o.get("unifi_username") and o.get("unifi_password"))):
    log("ERROR: set a UniFi API key, or a username and password")
    sys.exit(1)

put("UNIFI_HOST", o.get("unifi_host"))
put("UNIFI_PORT", o.get("unifi_port"))
put("UNIFI_USERNAME", o.get("unifi_username"))
put("UNIFI_PASSWORD", o.get("unifi_password"), hidden=True)
put("UNIFI_API_KEY", o.get("unifi_api_key"), hidden=True)
flag("UNIFI_VERIFY_SSL", o.get("verify_ssl"))
put("UNIFI_SSL_FINGERPRINT", o.get("ssl_fingerprint"))

token = o.get("http_auth_token") or ""
token_file = pathlib.Path("/data/.http_auth_token")
if not token:
    if not token_file.exists():
        token_file.write_text(secrets.token_hex(32))
        token_file.chmod(0o600)
        log("generated an HTTP bearer token; it is kept in /data/.http_auth_token")
        log("bearer token (shown once): " + token_file.read_text().strip())
    token = token_file.read_text().strip()
put("UNIFI_MCP_HTTP_AUTH_TOKEN", token, hidden=True)

env["UNIFI_MCP_HTTP_ENABLED"] = "true"
env["UNIFI_MCP_HTTP_TRANSPORT"] = "streamable-http"
env["UNIFI_MCP_HOST"] = "0.0.0.0"
env["UNIFI_MCP_PORT"] = "3001"
hosts = ["localhost", "127.0.0.1", "localhost:3001", "127.0.0.1:3001"]
hosts += [h.strip() for h in (o.get("allowed_hosts") or "").split(",") if h.strip()]
put("UNIFI_MCP_ALLOWED_HOSTS", ",".join(hosts))
put("UNIFI_TOOL_PERMISSION_MODE", o.get("permission_mode"))
if o.get("read_only"):
    flag("UNIFI_READ_ONLY", True)
put("OTEL_EXPORTER_OTLP_ENDPOINT", o.get("otel_endpoint"))

for row in o.get("env_vars") or []:
    name = row.get("name") or ""
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
        log("skip an env_vars entry with an invalid name")
        continue
    secret = row.get("secret") or re.search(r"PASSWORD|SECRET|KEY|TOKEN", name)
    put(name, row.get("value") or "", hidden=bool(secret))

for name, value in env.items():
    print(f"export {name}={shlex.quote(value)}")
PY
# shellcheck disable=SC1090
. "${env_file}"
rm -f "${env_file}"

echo "[unifi-protect-mcp-app] starting UniFi Protect MCP ${UNIFI_PROTECT_MCP_VERSION:-} on port 3001"
exec "$@"
