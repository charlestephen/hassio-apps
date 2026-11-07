#!/usr/bin/env python3
"""UniFi Notifi — enrich Alarm Manager webhooks into Slack Block Kit."""

from __future__ import annotations

import json
import logging
import os
import ssl
import threading
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import parse_qs, urlparse

LOG = logging.getLogger("unifi-notifi")

STATE_PATH = Path(os.environ.get("UNIFI_NOTIFI_STATE", "/data/state.json"))
SEEN_TTL_S = 24 * 3600
MUTE_TTL_S = 24 * 3600
MAX_GROUP_LINES = 5


def env(name: str, default: str = "") -> str:
    return os.environ.get(name, default).strip()


def env_int(name: str, default: int) -> int:
    raw = env(name)
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def env_bool(name: str, default: bool = False) -> bool:
    raw = env(name).lower()
    if not raw:
        return default
    return raw in ("1", "true", "yes", "on")


class Config:
    def __init__(self) -> None:
        self.listen_port = env_int("LISTEN_PORT", 8099)
        self.webhook_token = env("WEBHOOK_TOKEN")
        self.gateway_url = env("GATEWAY_URL").rstrip("/")
        self.site = env("SITE", "default") or "default"
        self.username = env("UNIFI_USERNAME")
        self.password = env("UNIFI_PASSWORD")
        self.api_key = env("UNIFI_API_KEY")
        self.slack_webhook_url = env("SLACK_WEBHOOK_URL")
        self.settle_seconds = env_int("SETTLE_SECONDS", 45)
        self.lookback_minutes = env_int("LOOKBACK_MINUTES", 15)
        self.verify_tls = env_bool("VERIFY_TLS", False)
        self.alarm_name_fallback = env("ALARM_NAME_FALLBACK", "Threat Detected")

    def validate(self) -> None:
        missing = []
        if not self.webhook_token:
            missing.append("webhook_token")
        if not self.gateway_url:
            missing.append("gateway_url")
        if not self.slack_webhook_url:
            missing.append("slack_webhook_url")
        if not self.api_key and not (self.username and self.password):
            missing.append("unifi_api_key or unifi_username+unifi_password")
        if missing:
            raise SystemExit(f"Missing required options: {', '.join(missing)}")


class State:
    def __init__(self, path: Path) -> None:
        self.path = path
        self.lock = threading.Lock()
        self.seen: dict[str, float] = {}
        self.muted: dict[str, float] = {}
        self._load()

    def _load(self) -> None:
        if not self.path.exists():
            return
        try:
            data = json.loads(self.path.read_text())
            self.seen = {str(k): float(v) for k, v in (data.get("seen") or {}).items()}
            self.muted = {str(k): float(v) for k, v in (data.get("muted") or {}).items()}
        except (OSError, ValueError, TypeError) as exc:
            LOG.warning("Could not load state from %s: %s", self.path, exc)

    def _save(self) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.path.with_suffix(".tmp")
        tmp.write_text(json.dumps({"seen": self.seen, "muted": self.muted}))
        tmp.replace(self.path)

    def prune(self, now: float | None = None) -> None:
        now = now or time.time()
        self.seen = {k: v for k, v in self.seen.items() if now - v < SEEN_TTL_S}
        self.muted = {k: v for k, v in self.muted.items() if v > now}

    def mark_seen(self, ids: list[str]) -> list[str]:
        now = time.time()
        with self.lock:
            self.prune(now)
            fresh = [i for i in ids if i not in self.seen]
            for i in fresh:
                self.seen[i] = now
            self._save()
            return fresh

    def is_muted(self, signature: str) -> bool:
        with self.lock:
            self.prune()
            return signature in self.muted


class UniFiClient:
    def __init__(self, cfg: Config) -> None:
        self.cfg = cfg
        self.cookie = ""
        self.csrf = ""
        ctx = ssl.create_default_context()
        if not cfg.verify_tls:
            ctx.check_hostname = False
            ctx.verify_mode = ssl.CERT_NONE
        self.ssl_context = ctx

    def _headers(self, extra: dict[str, str] | None = None) -> dict[str, str]:
        headers = {"Accept": "application/json", "Content-Type": "application/json"}
        if self.cfg.api_key:
            headers["X-API-KEY"] = self.cfg.api_key
        if self.cookie:
            headers["Cookie"] = self.cookie
        if self.csrf:
            headers["X-CSRF-Token"] = self.csrf
        if extra:
            headers.update(extra)
        return headers

    def _request(
        self,
        method: str,
        url: str,
        body: dict[str, Any] | None = None,
        extra_headers: dict[str, str] | None = None,
    ) -> tuple[Any, dict[str, str]]:
        data = None if body is None else json.dumps(body).encode()
        req = urllib.request.Request(
            url, data=data, headers=self._headers(extra_headers), method=method
        )
        try:
            with urllib.request.urlopen(req, context=self.ssl_context, timeout=30) as resp:
                raw = resp.read()
                headers = {k.lower(): v for k, v in resp.headers.items()}
                if not raw:
                    return None, headers
                try:
                    return json.loads(raw), headers
                except json.JSONDecodeError:
                    return raw.decode(errors="replace"), headers
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode(errors="replace")[:500]
            raise RuntimeError(f"UniFi {method} {url} -> HTTP {exc.code}: {detail}") from exc

    def login(self) -> None:
        if self.cfg.api_key:
            LOG.debug("Using UniFi API key auth")
            return
        import http.cookiejar

        body = {
            "username": self.cfg.username,
            "password": self.cfg.password,
            "rememberMe": False,
        }
        jar = http.cookiejar.CookieJar()
        opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(jar),
            urllib.request.HTTPSHandler(context=self.ssl_context),
        )
        req = urllib.request.Request(
            f"{self.cfg.gateway_url}/api/auth/login",
            data=json.dumps(body).encode(),
            headers={"Accept": "application/json", "Content-Type": "application/json"},
            method="POST",
        )
        with opener.open(req, timeout=30) as resp:
            self.csrf = (
                resp.headers.get("X-CSRF-Token")
                or resp.headers.get("x-csrf-token")
                or ""
            )
        self.cookie = "; ".join(f"{c.name}={c.value}" for c in jar)
        if not self.cookie:
            raise RuntimeError("UniFi login did not return a session cookie")
        LOG.info("Logged in to UniFi gateway")

    def recent_threat_ids(self) -> list[str]:
        now_ms = int(time.time() * 1000)
        body = {
            "timestampFrom": now_ms - self.cfg.lookback_minutes * 60_000,
            "timestampTo": now_ms,
            "pageSize": 100,
            "pageNumber": 0,
            "threatTypes": ["THREAT", "HONEYPOT"],
        }
        url = (
            f"{self.cfg.gateway_url}/proxy/network/v2/api/site/"
            f"{self.cfg.site}/system-log/threat-alert"
        )
        payload, _ = self._request("POST", url, body)
        entries: list[Any]
        if isinstance(payload, dict):
            entries = payload.get("data") or payload.get("items") or []
            if payload.get("id") and not entries:
                entries = [payload]
        elif isinstance(payload, list):
            entries = payload
        else:
            entries = []
        ids: list[str] = []
        for e in entries:
            if not isinstance(e, dict):
                continue
            params = e.get("parameters") or {}
            threat = params.get("THREAT_LOG_ID") if isinstance(params, dict) else None
            tid = None
            if isinstance(threat, dict):
                tid = threat.get("id")
            tid = tid or e.get("id")
            if tid:
                ids.append(str(tid))
        # preserve order, unique
        seen: set[str] = set()
        out: list[str] = []
        for i in ids:
            if i not in seen:
                seen.add(i)
                out.append(i)
        return out

    def threat_detail(self, threat_id: str) -> dict[str, Any] | None:
        url = (
            f"{self.cfg.gateway_url}/proxy/network/v2/api/site/"
            f"{self.cfg.site}/inspection-logs/threats/{threat_id}"
        )
        payload, _ = self._request("GET", url)
        if isinstance(payload, dict):
            data = payload.get("data", payload)
            if isinstance(data, list):
                return data[0] if data and isinstance(data[0], dict) else None
            if isinstance(data, dict):
                return data
        return None


def esc(s: Any) -> str:
    return (
        str(s if s is not None else "")
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def fmt_ts(ms: Any) -> str:
    try:
        value = float(ms)
        if value > 1e12:
            value /= 1000.0
        dt = datetime.fromtimestamp(value, tz=timezone.utc)
        return dt.strftime("%Y-%m-%d %H:%M:%S UTC")
    except (TypeError, ValueError, OSError):
        return "—"


def tally(threats: list[dict[str, Any]], key_fn) -> list[dict[str, Any]]:
    groups: dict[str, dict[str, Any]] = {}
    for t in threats:
        k = key_fn(t)
        if not k:
            continue
        g = groups.get(k)
        if not g:
            groups[k] = {"key": k, "count": 1, "t": t}
        else:
            g["count"] += 1
    return sorted(groups.values(), key=lambda g: g["count"], reverse=True)


def top_lines(groups: list[dict[str, Any]], line_fn) -> str:
    lines = [line_fn(g) for g in groups[:MAX_GROUP_LINES]]
    if len(groups) > MAX_GROUP_LINES:
        lines.append(f"_+{len(groups) - MAX_GROUP_LINES} more_")
    return "\n".join(lines) if lines else "_none_"


def build_slack_payload(
    cfg: Config,
    threats: list[dict[str, Any]],
    alarm_name: str,
    alarm_ts: Any,
) -> dict[str, Any]:
    signatures = tally(threats, lambda t: t.get("signature"))
    sources = tally(threats, lambda t: t.get("server_ip"))
    clients = tally(threats, lambda t: t.get("client_mac"))
    risks = ["high", "medium", "low"]
    highest = next((r for r in risks if any(t.get("risk") == r for t in threats)), "unknown")
    dot = {
        "high": ":red_circle:",
        "medium": ":large_orange_circle:",
        "low": ":large_yellow_circle:",
    }.get(highest, ":white_circle:")
    blocked = sum(1 for t in threats if t.get("action") == "blocked")
    plural = "" if len(threats) == 1 else "s"
    text = (
        f"{len(threats)} threat{plural} in the last {cfg.lookback_minutes} min "
        f"(highest risk: {highest})"
    )
    gateway_link = f"<{cfg.gateway_url}|Open UniFi>"
    site_line = f"site `{esc(cfg.site)}`"
    when = fmt_ts(alarm_ts) if alarm_ts else "—"

    blocks: list[dict[str, Any]] = [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": f"{len(threats)} threat{plural} in the last {cfg.lookback_minutes} min",
            },
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": (
                        f"{dot} Highest risk *{esc(highest)}*  |  "
                        f"Blocked {blocked}/{len(threats)}  |  "
                        f"{esc(alarm_name)}  |  {site_line}  |  {when}  |  {gateway_link}"
                    ),
                }
            ],
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Signatures*\n"
                + top_lines(
                    signatures,
                    lambda g: (
                        f"• *{g['count']}×* {esc(g['t'].get('signature'))} "
                        f"_({esc(g['t'].get('risk'))}, {esc(g['t'].get('signature_type') or g['t'].get('category') or 'threat')})_"
                    ),
                ),
            },
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Sources*\n"
                + top_lines(
                    sources,
                    lambda g: (
                        f"• *{g['count']}×* `{esc(g['key'])}` "
                        f"{esc(g['t'].get('counterpart_location') or g['t'].get('counterpart_country_code') or '')}"
                        f" · {esc(g['t'].get('threat_direction') or g['t'].get('direction') or '')}"
                        f" · {esc(g['t'].get('action') or '')}"
                    ),
                ),
            },
        },
    ]
    if clients:
        blocks.append(
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*Clients*\n"
                    + top_lines(
                        clients,
                        lambda g: (
                            f"• *{g['count']}×* {esc(g['t'].get('client_name') or 'unknown')} "
                            f"`{esc(g['key'])}`"
                        ),
                    ),
                },
            }
        )
    # One sample threat for actionable extras without spamming every field
    sample = threats[0]
    extras = []
    proto = sample.get("protocol") or sample.get("app_proto")
    if proto:
        extras.append(f"*Protocol:* {esc(proto)}")
    dst = sample.get("dest_port") or sample.get("dst_port")
    if dst:
        extras.append(f"*Port:* `{esc(dst)}`")
    if sample.get("host") or sample.get("hostname"):
        extras.append(f"*Host:* `{esc(sample.get('host') or sample.get('hostname'))}`")
    if extras:
        blocks.append(
            {
                "type": "section",
                "text": {"type": "mrkdwn", "text": " · ".join(extras)},
            }
        )
    return {"text": text, "blocks": blocks, "unfurl_links": False}


def post_slack(webhook_url: str, payload: dict[str, Any]) -> None:
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        webhook_url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    # Slack webhooks need normal TLS verification
    ctx = ssl.create_default_context()
    try:
        with urllib.request.urlopen(req, context=ctx, timeout=30) as resp:
            body = resp.read().decode(errors="replace")
            if resp.status >= 300:
                raise RuntimeError(f"Slack HTTP {resp.status}: {body[:300]}")
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")[:500]
        raise RuntimeError(f"Slack HTTP {exc.code}: {detail}") from exc


class Enricher:
    def __init__(self, cfg: Config, state: State) -> None:
        self.cfg = cfg
        self.state = state
        self.lock = threading.Lock()
        self.timer: threading.Timer | None = None
        self.pending_meta: dict[str, Any] = {}
        self.unifi = UniFiClient(cfg)

    def schedule(self, meta: dict[str, Any]) -> None:
        with self.lock:
            # Keep the richest alarm name / timestamp from the burst
            if meta.get("name"):
                self.pending_meta["name"] = meta["name"]
            if meta.get("timestamp"):
                self.pending_meta["timestamp"] = meta["timestamp"]
            if self.timer:
                self.timer.cancel()
            self.timer = threading.Timer(self.cfg.settle_seconds, self._run_safe)
            self.timer.daemon = True
            self.timer.start()
            LOG.info(
                "Webhook accepted; settling %ss before enrichment",
                self.cfg.settle_seconds,
            )

    def _run_safe(self) -> None:
        try:
            self.run()
        except Exception:
            LOG.exception("Enrichment failed")

    def run(self) -> None:
        with self.lock:
            meta = dict(self.pending_meta)
            self.pending_meta = {}
            self.timer = None

        alarm_name = (
            meta.get("name")
            or meta.get("alarm_name")
            or self.cfg.alarm_name_fallback
        )
        alarm_ts = meta.get("timestamp")

        self.unifi.login()
        ids = self.unifi.recent_threat_ids()
        fresh = self.state.mark_seen(ids)
        LOG.info("Threat lookback: %d ids, %d new", len(ids), len(fresh))
        if not fresh:
            LOG.info("No new threats to report")
            return

        threats: list[dict[str, Any]] = []
        for tid in fresh:
            detail = self.unifi.threat_detail(tid)
            if not detail:
                continue
            sig = detail.get("signature")
            if not sig:
                continue
            if self.state.is_muted(str(sig)):
                continue
            detail["_id"] = tid
            threats.append(detail)

        if not threats:
            LOG.info("All new threats muted or lacked signatures")
            return

        payload = build_slack_payload(self.cfg, threats, str(alarm_name), alarm_ts)
        post_slack(self.cfg.slack_webhook_url, payload)
        LOG.info("Posted Slack enrichment for %d threat(s)", len(threats))


def parse_alarm_meta(body: Any) -> dict[str, Any]:
    meta: dict[str, Any] = {}
    if not isinstance(body, dict):
        return meta
    alarm = body.get("alarm") if isinstance(body.get("alarm"), dict) else {}
    meta["name"] = (
        body.get("name")
        or alarm.get("name")
        or body.get("alarm_name")
    )
    meta["timestamp"] = body.get("timestamp") or body.get("@timestamp")
    meta["alarm_id"] = body.get("alarm_id") or alarm.get("id")
    events = body.get("events")
    if isinstance(events, list) and events:
        first = events[0] if isinstance(events[0], dict) else {}
        meta["alert_key"] = first.get("alert_key")
        scope = first.get("scope") if isinstance(first.get("scope"), dict) else {}
        if scope.get("site_id"):
            meta["site_id"] = scope["site_id"]
    return {k: v for k, v in meta.items() if v is not None}


def make_handler(cfg: Config, enricher: Enricher):
    class Handler(BaseHTTPRequestHandler):
        server_version = "unifi-notifi/1.0"

        def log_message(self, fmt: str, *args: Any) -> None:
            LOG.debug("%s - " + fmt, self.address_string(), *args)

        def _read_json(self) -> Any:
            length = int(self.headers.get("Content-Length") or 0)
            raw = self.rfile.read(length) if length else b""
            if not raw:
                return {}
            try:
                return json.loads(raw)
            except json.JSONDecodeError:
                return {"_raw": raw.decode(errors="replace")}

        def _unauthorized(self) -> None:
            self.send_response(401)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"error":"unauthorized"}')

        def _ok(self, payload: dict[str, Any] | None = None) -> None:
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(payload or {"ok": True}).encode())

        def _token_ok(self, path: str, query: dict[str, list[str]]) -> bool:
            expected = cfg.webhook_token
            if not expected:
                return False
            # /webhook/<token> or ?token=
            parts = [p for p in path.strip("/").split("/") if p]
            if len(parts) >= 2 and parts[0] == "webhook" and parts[1] == expected:
                return True
            tokens = query.get("token") or []
            return bool(tokens) and tokens[0] == expected

        def do_GET(self) -> None:  # noqa: N802
            parsed = urlparse(self.path)
            if parsed.path in ("/health", "/"):
                self._ok({"status": "ok", "app": "unifi-notifi"})
                return
            self.send_response(404)
            self.end_headers()

        def do_POST(self) -> None:  # noqa: N802
            parsed = urlparse(self.path)
            query = parse_qs(parsed.query)
            if not parsed.path.startswith("/webhook"):
                self.send_response(404)
                self.end_headers()
                return
            if not self._token_ok(parsed.path, query):
                self._unauthorized()
                return
            body = self._read_json()
            meta = parse_alarm_meta(body)
            enricher.schedule(meta)
            self._ok({"accepted": True, "settle_seconds": cfg.settle_seconds})

    return Handler


def main() -> None:
    level = env("LOG_LEVEL", "info").upper()
    if level == "WARN":
        level = "WARNING"
    logging.basicConfig(
        level=getattr(logging, level, logging.INFO),
        format="%(asctime)s %(levelname)s %(message)s",
    )
    cfg = Config()
    cfg.validate()
    state = State(STATE_PATH)
    enricher = Enricher(cfg, state)
    handler = make_handler(cfg, enricher)
    server = ThreadingHTTPServer(("0.0.0.0", cfg.listen_port), handler)
    LOG.info(
        "UniFi Notifi listening on :%s (site=%s, settle=%ss, lookback=%sm)",
        cfg.listen_port,
        cfg.site,
        cfg.settle_seconds,
        cfg.lookback_minutes,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        LOG.info("Shutting down")
        server.shutdown()


if __name__ == "__main__":
    main()
