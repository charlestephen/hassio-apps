#!/usr/bin/env bash
# Home Assistant wrapper for the UniFi API Server (sirkirby/unifi-mcp, apps/api).
# Maps /data/options.json to UNIFI_API_* variables, keeps the state database
# under /data, then runs the image's own command as its unprivileged user.
set -euo pipefail

export OPTIONS=/data/options.json
if [[ ! -f "${OPTIONS}" ]]; then
    echo "[unifi-api-server-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

env_file="$(mktemp)"
python3 - > "${env_file}" <<'PY'
import json, os, re, shlex, sys

o = json.load(open(os.environ["OPTIONS"]))
env = {}


def log(msg):
    print(f"[unifi-api-server-app] {msg}", file=sys.stderr)


def put(name, value, hidden=False):
    if value in (None, ""):
        return
    env[name] = str(value)
    log(f"set {name}" + (" (hidden)" if hidden else f"={value}"))


put("UNIFI_API_STATE_DIR", "/data")
put("UNIFI_API_DB_PATH", "/data/state.db")
put("UNIFI_API_HTTP_HOST", "0.0.0.0")
put("UNIFI_API_HTTP_PORT", "8080")
put("UNIFI_API_DB_KEY", o.get("db_key"), hidden=True)
put("UNIFI_API_LOGGING_LEVEL", o.get("log_level"))
if o.get("allow_sensitive_fields"):
    put("UNIFI_API_REDACT_SENSITIVE_FIELDS", "false")
if o.get("read_only"):
    put("UNIFI_READ_ONLY", "true")

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

chown -R 1000:1000 /data
echo "[unifi-api-server-app] starting UniFi API Server ${UNIFI_API_SERVER_VERSION:-}"
exec setpriv --reuid=1000 --regid=1000 --init-groups "$@"
