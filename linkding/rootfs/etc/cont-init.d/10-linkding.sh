#!/command/with-contenv sh
# =============================================================================
# Prepare linkding before the service starts:
#   1. Persist the SQLite database / data in the app's config dir (/config).
#   2. Translate app options (+ injected env_vars) into an env file the
#      service sources. Config is read with python3 (bundled in the image).
# =============================================================================
set -e

# HA always mounts the app options at /data/options.json, regardless of the
# `map:` config; the bookmark data lives in the addon_config dir (/config).
OPTIONS=/data/options.json
ENVFILE=/var/run/linkding.env
DATA=/config

# 1. Persist data: linkding's data dir is fixed at /etc/linkding/data; point it
#    at the addon_config dir (/config -> host /addon_configs/<slug>_linkding) so
#    bookmarks survive restarts/updates and are reachable via Samba/SSH.
mkdir -p "$DATA"

# (Re)point linkding's fixed data dir at $DATA. /etc/linkding/data ships in the
# image as a real dir (seed data); replace it with a symlink the first time.
if ! { [ -L /etc/linkding/data ] && [ "$(readlink /etc/linkding/data)" = "$DATA" ]; }; then
    if [ -d /etc/linkding/data ] && [ ! -L /etc/linkding/data ] && [ -n "$(ls -A /etc/linkding/data 2>/dev/null)" ]; then
        cp -an /etc/linkding/data/. "$DATA/" 2>/dev/null || true
    fi
    rm -rf /etc/linkding/data
    ln -s "$DATA" /etc/linkding/data
fi

# Own the data dir as www-data (uid 82 in the upstream alpine image), the uid
# uwsgi drops to. HA mounts /config root-owned, and the upstream image's own
# `chown -R www-data: /etc/linkding/data` (in bootstrap.sh) is a no-op here
# because that path is our symlink — `chown -R` does not follow a symlink given
# as its argument — so without this the SQLite DBs stay root-owned and the
# www-data workers hit "attempt to write a readonly database" (HTTP 500 on every
# request). The service then runs the whole stack as www-data so files created
# later (first-boot migrations, huey's tasks.sqlite3) stay writable too.
chown -R www-data:www-data "$DATA"

# 2. Build the env file.
: > "$ENVFILE"
python3 - "$OPTIONS" "$ENVFILE" <<'PY'
import json, sys
opts = json.load(open(sys.argv[1]))
out = open(sys.argv[2], "a")

def put(k, v):
    if v is not None and v != "":
        out.write(f"{k}={v}\n")

put("LD_SUPERUSER_NAME", opts.get("superuser_name"))
put("LD_SUPERUSER_PASSWORD", opts.get("superuser_password"))
if opts.get("disable_background_tasks"):
    put("LD_DISABLE_BACKGROUND_TASKS", "True")

# Arbitrary injected variables (highest precedence; can override the above).
for e in opts.get("env_vars") or []:
    name = (e.get("name") or "").strip()
    if name:
        put(name, e.get("value", ""))
out.close()
PY

echo "[linkding] configuration prepared ($(wc -l < "$ENVFILE") env vars; data -> $DATA)"
