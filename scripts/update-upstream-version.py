#!/usr/bin/env python3
"""Update one app's pinned upstream version while preserving YAML comments."""

from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

VERSION_TOKEN = "$APP_NEW_VERSION"
TEXT_FILES = ("Dockerfile", "CHANGELOG.md", "DOCS.md")


def normalize_version(release_tag: str) -> str:
    """Turn an upstream tag into the version string written into app files."""
    version = release_tag
    if version.startswith("v") and len(version) > 1 and version[1].isdigit():
        version = version[1:]
    release = re.fullmatch(r"REL-(\d+(?:_\d+)+)", version)
    if release:
        version = release.group(1).replace("_", ".")
    return version


def replace_version_token(path: Path, version: str) -> None:
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8")
    if VERSION_TOKEN not in text:
        return
    path.write_text(text.replace(VERSION_TOKEN, version), encoding="utf-8")


def replace_config_version(path: Path, version: str) -> None:
    text = path.read_text(encoding="utf-8")
    updated, count = re.subn(
        r"(?m)^version\s*:\s*.*$",
        f'version: "{version}"',
        text,
        count=1,
    )
    if count != 1:
        raise ValueError(f"Could not find top-level version in {path}")
    path.write_text(updated, encoding="utf-8")


def replace_build_arg(path: Path, key: str, version: str) -> None:
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    in_args = False
    found = False
    for index, line in enumerate(lines):
        if re.match(r"^args:\s*(?:#.*)?$", line):
            in_args = True
            continue
        if in_args and line.strip() and not line.startswith((" ", "\t", "#")):
            in_args = False
        if in_args and re.match(rf"^\s+{re.escape(key)}\s*:", line):
            ending = "\n" if line.endswith("\n") else ""
            lines[index] = f'  {key}: "{version}"{ending}'
            found = True
            break
    if not found:
        raise ValueError(f"Could not find args.{key} in {path}")
    path.write_text("".join(lines), encoding="utf-8")


def replace_build_from(path: Path, version: str) -> None:
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    in_build_from = False
    found = 0
    for index, line in enumerate(lines):
        if re.match(r"^build_from:\s*(?:#.*)?$", line):
            in_build_from = True
            continue
        if in_build_from and line.strip() and not line.startswith((" ", "\t", "#")):
            in_build_from = False
        if not in_build_from:
            continue
        match = re.match(r"^(\s+(?:amd64|aarch64):\s+.+?:)[^:\s]+(\s*(?:#.*)?\n?)$", line)
        if match:
            ending = "\n" if line.endswith("\n") else ""
            comment = re.search(r"\s+#.*$", line.rstrip("\n"))
            suffix = f" {comment.group(0).lstrip()}" if comment else ""
            lines[index] = f"{match.group(1)}{version}{suffix}{ending}"
            found += 1
    if found < 1:
        raise ValueError(f"Could not find architecture tags in build_from in {path}")
    path.write_text("".join(lines), encoding="utf-8")


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: update-upstream-version.py APP_DIR RELEASE_TAG")

    app_dir = Path(sys.argv[1])
    release_tag = sys.argv[2]
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._+-]*", release_tag):
        raise SystemExit(f"Unsupported upstream release tag: {release_tag!r}")
    build_path = app_dir / "build.yaml"
    config_path = app_dir / "config.yaml"
    build = yaml.safe_load(build_path.read_text(encoding="utf-8")) or {}
    version = normalize_version(release_tag)
    arg_prefix = build.get("upstream_version_arg_prefix", "")

    replace_config_version(config_path, version)
    arg = build.get("upstream_version_arg")
    if arg:
        replace_build_arg(build_path, arg, f"{arg_prefix}{version}")
    if build.get("upstream_build_from"):
        build_from_prefix = build.get("upstream_build_from_prefix", "")
        replace_build_from(build_path, f"{build_from_prefix}{version}")
    for name in TEXT_FILES:
        replace_version_token(app_dir / name, version)


if __name__ == "__main__":
    main()
