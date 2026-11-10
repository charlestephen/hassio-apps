#!/usr/bin/env bash
# Home Assistant wrapper for traefik-certs-dumper (kereis/traefik-certs-dumper).
# Maps /data/options.json to the image's variables and points the output at the
# ssl folder, then runs the image's dump script.
set -euo pipefail

OPTIONS=/data/options.json
log() { echo "[traefik-cert-dumper-app] $*"; }
warn() { echo "[traefik-cert-dumper-app] WARNING: $*"; }
get() { jq -r --arg k "$1" '.[$k] // empty' "${OPTIONS}"; }
is_true() { [ "$(jq -r --arg k "$1" '.[$k] // false' "${OPTIONS}")" = "true" ]; }

if [ ! -f "${OPTIONS}" ]; then
    echo "[traefik-cert-dumper-app] ERROR: ${OPTIONS} is missing" >&2
    exit 1
fi

relative_path() { # option -> path under /ssl, refusing absolute or parent paths
    local value
    value="$(get "$1")"
    case "${value}" in
        ''|/*|*..*) echo "[traefik-cert-dumper-app] ERROR: '$1' must be a path inside the ssl folder" >&2; exit 1 ;;
    esac
    printf '%s' "${value}"
}

ACME_FILE_PATH="/ssl/$(relative_path acme_file)"
OUTPUT_DIR="/ssl/$(relative_path output_dir)"
export ACME_FILE_PATH OUTPUT_DIR
mkdir -p "${OUTPUT_DIR}"
log "reading ${ACME_FILE_PATH}, writing to ${OUTPUT_DIR}"
if [ ! -f "${ACME_FILE_PATH}" ]; then
    warn "${ACME_FILE_PATH} does not exist yet"
fi

export_if_set() { # option variable
    local value
    value="$(get "$1")"
    if [ -n "${value}" ]; then
        export "$2=${value}"
        case "$2" in
            *PASSWORD*) log "set $2 (hidden)" ;;
            *) log "set $2=${value}" ;;
        esac
    fi
}
export_if_set domain DOMAIN
export_if_set certificate_file_name CERTIFICATE_FILE_NAME
export_if_set private_key_file_name PRIVATE_KEY_FILE_NAME
export_if_set combined_pem COMBINED_PEM
export_if_set pkcs12_password PKCS12_PASSWORD
if is_true convert_keys_to_rsa; then export CONVERT_KEYS_TO_RSA=yes; fi
if is_true combine_pkcs12; then export COMBINE_PKCS12=yes; fi

uid="$(get override_uid)"
gid="$(get override_gid)"
if [ -n "${uid}" ] && [ -n "${gid}" ]; then
    export OVERRIDE_UID="${uid}" OVERRIDE_GID="${gid}"
    log "files will be owned by ${uid}:${gid}"
elif [ -n "${uid}" ] || [ -n "${gid}" ]; then
    warn "set both the owner user ID and group ID; ignoring the owner"
fi

# ---- Extra environment variables ----------------------------------------------
while IFS= read -r line; do
    [ -n "${line}" ] || continue
    key="${line%%=*}"
    value="${line#*=}"
    case "${key}" in
        ''|*[!A-Za-z0-9_]*|[0-9]*) warn "skipping an env_vars entry with an invalid name"; continue ;;
    esac
    export "${key}=${value}"
    case "${key}" in
        *PASSWORD*|*SECRET*|*KEY*|*TOKEN*) log "set ${key} from env_vars (hidden)" ;;
        *) log "set ${key} from env_vars" ;;
    esac
done <<EOF
$(jq -r '(.env_vars // [])[] | select((.name // "") != "") | .name + "=" + (.value // "")' "${OPTIONS}")
EOF

log "starting traefik-certs-dumper ${TRAEFIK_CERTS_DUMPER_VERSION:-}"
# Forward SIGTERM and exit 0 once it stops: the Supervisor reports an app that
# exits 143 on stop as an error.
/usr/bin/dump "$@" &
child=$!
stopping=0
trap 'stopping=1; kill -TERM "${child}" 2>/dev/null' TERM INT
code=0
wait "${child}" || code=$?
if [ "${stopping}" = 1 ]; then
    wait "${child}" 2>/dev/null || true
    exit 0
fi
exit "${code}"
