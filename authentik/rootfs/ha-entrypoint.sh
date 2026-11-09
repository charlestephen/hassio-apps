#!/usr/bin/env bash
# Home Assistant wrapper for authentik (goauthentik/authentik).
# Exports AUTHENTIK_* variables from /data/options.json, creates the database
# when admin credentials are given, then runs the upstream entrypoint.
set -euo pipefail

export OPTIONS=/data/options.json

if [[ ! -f "${OPTIONS}" ]]; then
    echo "[authentik-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

eval "$(python - <<'PY'
import json, os, pathlib, re, secrets, shlex, sys

o = json.load(open(os.environ["OPTIONS"]))
env = {}


def log(msg):
    print(f"[authentik-app] {msg}", file=sys.stderr)


def put(name, value, hidden=False):
    if value in (None, ""):
        return
    env[name] = str(value)
    log(f"set {name}" + (" (hidden)" if hidden else f"={value}"))


key = o.get("secret_key") or ""
key_file = pathlib.Path("/data/.secret_key")
if not key:
    if not key_file.exists():
        key_file.write_text(secrets.token_urlsafe(60))
        key_file.chmod(0o600)
        log("generated a secret key in /data/.secret_key")
    key = key_file.read_text().strip()
put("AUTHENTIK_SECRET_KEY", key, hidden=True)

if not o.get("db_password"):
    log("ERROR: db_password is required")
    print("exit 1")
    sys.exit(0)

put("AUTHENTIK_POSTGRESQL__HOST", o.get("db_host"))
put("AUTHENTIK_POSTGRESQL__PORT", o.get("db_port"))
put("AUTHENTIK_POSTGRESQL__NAME", o.get("db_name"))
put("AUTHENTIK_POSTGRESQL__USER", o.get("db_user"))
put("AUTHENTIK_POSTGRESQL__PASSWORD", o.get("db_password"), hidden=True)
put("AUTHENTIK_BOOTSTRAP_EMAIL", o.get("bootstrap_email"))
put("AUTHENTIK_BOOTSTRAP_PASSWORD", o.get("bootstrap_password"), hidden=True)
put("AUTHENTIK_LOG_LEVEL", o.get("log_level"))

for row in o.get("env_vars") or []:
    name = row.get("name") or ""
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
        log("skip invalid env name")
        continue
    secret = row.get("secret") or re.search(r"PASSWORD|SECRET|KEY|TOKEN", name)
    put(name, row.get("value") or "", hidden=bool(secret))

for name, value in env.items():
    print(f"export {name}={shlex.quote(value)}")
PY
)"

# Create the role and database on the PostgreSQL app when admin credentials are set.
if [[ -n "$(python -c 'import json,os;print(json.load(open(os.environ["OPTIONS"])).get("db_admin_password") or "")')" ]]; then
    python - <<'PY'
import json, os, sys, time

import psycopg
from psycopg import sql

o = json.load(open(os.environ["OPTIONS"]))
conn = None
for _ in range(60):
    try:
        conn = psycopg.connect(
            host=o["db_host"], port=o["db_port"], dbname="postgres", autocommit=True,
            user=o.get("db_admin_user") or "postgres", password=o["db_admin_password"],
        )
        break
    except psycopg.OperationalError as exc:
        print(f"[authentik-app] waiting for PostgreSQL: {exc}", file=sys.stderr)
        time.sleep(2)
if conn is None:
    print("[authentik-app] ERROR: could not reach PostgreSQL with the admin credentials", file=sys.stderr)
    sys.exit(1)

user, password, name = o["db_user"], o["db_password"], o["db_name"]
cur = conn.cursor()
cur.execute("SELECT 1 FROM pg_roles WHERE rolname = %s", (user,))
verb = "ALTER" if cur.fetchone() else "CREATE"
cur.execute(sql.SQL(verb + " ROLE {} LOGIN PASSWORD {}").format(sql.Identifier(user), sql.Literal(password)))
cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (name,))
if not cur.fetchone():
    cur.execute(sql.SQL("CREATE DATABASE {} OWNER {}").format(sql.Identifier(name), sql.Identifier(user)))
    print(f"[authentik-app] created database {name}", file=sys.stderr)
PY
fi

echo "[authentik-app] Starting authentik ${AUTHENTIK_VERSION:-unknown}"
exec dumb-init -- ak allinone
