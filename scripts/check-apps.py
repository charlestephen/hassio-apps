#!/usr/bin/env python3
"""Static consistency checks for the apps in this repository.

Usage: python3 scripts/check-apps.py [--base GIT_REF]

With --base, an app whose config.yaml, Dockerfile, build.yaml or rootfs/ changed since that ref must also have a new
`version`, because Supervisor does not re-pull an unchanged version and CI would overwrite its image tag.
"""
import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_KEYS = ("name", "version", "slug", "description", "arch")
VERSION_RE = re.compile(r"^[0-9][0-9A-Za-z._+-]*$")
# Default host ports that two apps already share. Anything not listed here fails.
KNOWN_PORT_CLASHES = {
    ("tcp", 8080): {"traefik", "ultimate-ca-manager"},
    ("tcp", 8888): {"gluetun", "tang"},
}
# Changing these rebuilds the image under the same tag unless the version changes.
REBUILD_INPUTS = ("config.yaml", "Dockerfile", "build.yaml", "rootfs/")

errors: list[str] = []
warnings: list[str] = []


def report(kind: str, app: str, message: str, file: str = "") -> None:
    (errors if kind == "error" else warnings).append(f"{app}: {message}")
    if os.environ.get("GITHUB_ACTIONS"):
        target = f" file={file}" if file else ""
        print(f"::{kind}{target}::{app}: {message}")


def load_yaml(path: Path):
    with path.open(encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def apps() -> list[Path]:
    return sorted(p.parent for p in ROOT.glob("*/config.yaml"))


def check_app(app: Path, config: dict, readme: str) -> None:
    name = app.name
    rel = f"{name}/config.yaml"

    for key in REQUIRED_KEYS:
        if key not in config:
            report("error", name, f"config.yaml is missing `{key}`", rel)

    version = str(config.get("version", ""))
    if not VERSION_RE.match(version):
        report("error", name, f"version {version!r} is not a plain version string", rel)

    image = str(config.get("image", ""))
    if image and "{arch}" not in image:
        report("error", name, "`image` has no {arch} placeholder", rel)

    for asset in ("icon.png", "logo.png", "DOCS.md", "CHANGELOG.md", "README.md"):
        if not (app / asset).exists():
            report("error", name, f"missing {asset}")

    slug = str(config.get("slug", ""))
    profile = app / "apparmor.txt"
    if not profile.exists():
        report("error", name, "missing apparmor.txt")
    else:
        match = re.search(r"(?m)^profile\s+(\S+)", profile.read_text(encoding="utf-8"))
        if not match or match.group(1) != slug:
            report("error", name, f"apparmor profile {match.group(1) if match else None!r} does not match slug {slug!r}", f"{name}/apparmor.txt")

    url = str(config.get("url", ""))
    tree = url.split("/tree/main/", 1)
    if len(tree) == 2 and not (ROOT / tree[1]).is_dir():
        report("error", name, f"`url` points at {tree[1]!r}, which is not a directory", rel)

    if f"]({name}/)" not in readme:
        report("error", name, "is not listed in README.md", "README.md")

    options = config.get("options") or {}
    schema = config.get("schema") or {}
    if schema:
        for key in options:
            if key not in schema:
                report("error", name, f"option `{key}` has no schema entry", rel)

    translations = app / "translations" / "en.yaml"
    if translations.exists():
        try:
            names = (load_yaml(translations).get("configuration") or {}).keys()
        except yaml.YAMLError as exc:
            report("error", name, f"translations/en.yaml does not parse: {exc}", f"{name}/translations/en.yaml")
        else:
            missing = [k for k in schema if k not in names]
            if missing:
                report("warning", name, f"no translation for option(s): {', '.join(missing)}", f"{name}/translations/en.yaml")
    elif schema:
        report("warning", name, "has options but no translations/en.yaml", rel)

    watchdog = str(config.get("watchdog", ""))
    port = re.search(r"\[PORT:(\d+)\]", watchdog)
    if port and not config.get("host_network"):
        published = {str(k).split("/")[0] for k, v in (config.get("ports") or {}).items() if v is not None}
        if port.group(1) not in published:
            report("error", name, f"watchdog uses container port {port.group(1)}, which is not published", rel)


def check_ports(configs: dict[str, dict]) -> None:
    owners: dict[tuple[str, int], set[str]] = {}
    for name, config in configs.items():
        if config.get("host_network"):
            continue
        for spec, host in (config.get("ports") or {}).items():
            if host is None:
                continue
            proto = str(spec).split("/")[1] if "/" in str(spec) else "tcp"
            owners.setdefault((proto, int(host)), set()).add(name)
    for (proto, host), names in sorted(owners.items()):
        if len(names) > 1 and names != KNOWN_PORT_CLASHES.get((proto, host)):
            report("error", ", ".join(sorted(names)), f"share default host port {host}/{proto}; give each app its own")


def check_slugs(configs: dict[str, dict]) -> None:
    seen: dict[str, str] = {}
    for name, config in configs.items():
        slug = str(config.get("slug", ""))
        if slug in seen:
            report("error", name, f"slug {slug!r} is also used by {seen[slug]}")
        seen[slug] = name


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True).stdout


def version_in(text: str) -> str:
    match = re.search(r"""(?m)^version\s*:\s*["']?([^"'#\n]+?)["']?\s*$""", text)
    return match.group(1).strip() if match else ""


def check_version_bumps(base: str) -> None:
    # base against the working tree, so uncommitted edits count locally and a clean CI checkout behaves the same
    changed = [f for f in git("diff", "--name-only", base).splitlines() if "/" in f]
    by_app: dict[str, list[str]] = {}
    for path in changed:
        app, rest = path.split("/", 1)
        if any(rest == item or rest.startswith(item) for item in REBUILD_INPUTS):
            by_app.setdefault(app, []).append(rest)
    for app, files in sorted(by_app.items()):
        if not (ROOT / app / "config.yaml").exists():
            continue
        old = version_in(git("show", f"{base}:{app}/config.yaml"))
        if not old:
            continue  # new app
        new = version_in((ROOT / app / "config.yaml").read_text(encoding="utf-8"))
        if new == old:
            report("error", app, f"{', '.join(sorted(files))} changed but version is still {old}; bump it so Supervisor re-pulls", f"{app}/config.yaml")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--base", help="git ref to compare against for version bumps")
    args = parser.parse_args()

    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    configs: dict[str, dict] = {}
    for app in apps():
        try:
            configs[app.name] = load_yaml(app / "config.yaml")
        except yaml.YAMLError as exc:
            report("error", app.name, f"config.yaml does not parse: {exc}", f"{app.name}/config.yaml")
            continue
        check_app(app, configs[app.name], readme)
    check_ports(configs)
    check_slugs(configs)
    if args.base:
        check_version_bumps(args.base)

    for line in warnings:
        print(f"warning: {line}")
    for line in errors:
        print(f"error: {line}")
    print(f"{len(configs)} apps checked: {len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
