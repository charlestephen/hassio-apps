#!/usr/bin/env python3
"""Update add-on versions from each app's upstream release.

`python3 scripts/update-upstream-version.py --all` checks every app with
`upstream_repo` in build.yaml. `APP_DIR RELEASE_TAG` updates one app from a
tag you already resolved.
"""

from __future__ import annotations

import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

import yaml

VERSION_TOKEN = "$APP_NEW_VERSION"
TEXT_FILES = ("Dockerfile", "DOCS.md")
TAG_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9._+-]*")
PRERELEASE_RE = re.compile(
    r"(?i)(?:^|[^A-Za-z])(?:alpha|beta|rc|preview|pre|dev)(?:[^A-Za-z]|$)"
)
REPO_ROOT = Path(__file__).resolve().parents[1]


def normalize_version(release_tag: str) -> str:
    """Turn an upstream tag into the version string written into app files."""
    version = release_tag
    if version.startswith("v") and len(version) > 1 and version[1].isdigit():
        version = version[1:]
    release = re.fullmatch(r"REL[_-](\d+(?:_\d+)+)", version)
    if release:
        version = release.group(1).replace("_", ".")
    return version


def version_key(version: str) -> tuple:
    parts: list[tuple[int, int | str]] = []
    for piece in re.split(r"[^A-Za-z0-9]+", version):
        if not piece:
            continue
        if piece.isdigit():
            parts.append((0, int(piece)))
        else:
            parts.append((1, piece))
    return tuple(parts)


def is_prerelease(tag: str) -> bool:
    return PRERELEASE_RE.search(tag) is not None


def read_config_version(path: Path) -> str:
    match = re.search(r'(?m)^version\s*:\s*"?([^"#\n]+?)"?\s*$', path.read_text(encoding="utf-8"))
    if not match:
        raise ValueError(f"Could not find top-level version in {path}")
    return match.group(1).strip()


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


def replace_bounded(text: str, old: str, new: str) -> str:
    if not old or old == new or VERSION_TOKEN in old:
        return text
    return re.sub(
        rf"(?<![A-Za-z0-9.]){re.escape(old)}(?![A-Za-z0-9.])",
        new,
        text,
    )


def rewrite_prose(path: Path, version: str, old_values: list[str]) -> None:
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8")
    if VERSION_TOKEN in text:
        path.write_text(text.replace(VERSION_TOKEN, version), encoding="utf-8")
        return
    updated = text
    for old in sorted(set(old_values), key=len, reverse=True):
        updated = replace_bounded(updated, old, version)
    if updated != text:
        path.write_text(updated, encoding="utf-8")


def update_changelog(path: Path, old: str, version: str) -> None:
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8")
    if VERSION_TOKEN in text:
        text = text.replace(VERSION_TOKEN, version)
        text = re.sub(
            rf"(?m)^- Upgrading from upstream version {re.escape(version)} -> {re.escape(version)}\n(?:\n)?",
            "",
            text,
        )
        path.write_text(text, encoding="utf-8")
        return
    if old == version or f"## {version}\n" in text:
        return
    entry = f"## {version}\n\n- Upgrading from upstream version {old} -> {version}\n\n"
    title = re.match(r"# .+\n\n", text)
    if title:
        text = text[: title.end()] + entry + text[title.end() :]
    else:
        text = entry + text
    path.write_text(text, encoding="utf-8")


def update_readme_badge(path: Path, version: str) -> None:
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8")
    updated = re.sub(
        r"badge/version-v.+?-blue",
        f"badge/version-v{version}-blue",
        text,
        count=1,
    )
    if updated != text:
        path.write_text(updated, encoding="utf-8")


def update_app(app_dir: Path, release_tag: str, *, force: bool) -> None:
    if not TAG_RE.fullmatch(release_tag):
        raise SystemExit(f"Unsupported upstream release tag: {release_tag!r}")
    build_path = app_dir / "build.yaml"
    config_path = app_dir / "config.yaml"
    build = yaml.safe_load(build_path.read_text(encoding="utf-8")) or {}
    version = normalize_version(release_tag)
    old = read_config_version(config_path)
    (app_dir / "upstream_version.txt").write_text(f"{release_tag}\n", encoding="utf-8")
    if VERSION_TOKEN not in old and not force and version_key(version) <= version_key(old):
        print(f"{app_dir.name}: keep {old} (upstream {release_tag} is not newer)")
        return

    arg_prefix = str(build.get("upstream_version_arg_prefix") or "")
    build_from_prefix = str(build.get("upstream_build_from_prefix") or "")
    arg_name = build.get("upstream_version_arg")
    old_arg = str((build.get("args") or {}).get(arg_name) or "") if arg_name else ""
    old_values = [old, old_arg, f"{arg_prefix}{old}", f"{build_from_prefix}{old}"]

    replace_config_version(config_path, version)
    if arg_name:
        replace_build_arg(build_path, arg_name, f"{arg_prefix}{version}")
    if build.get("upstream_build_from"):
        replace_build_from(build_path, f"{build_from_prefix}{version}")
    for name in TEXT_FILES:
        rewrite_prose(app_dir / name, version, old_values)
    update_changelog(app_dir / "CHANGELOG.md", old, version)
    update_readme_badge(app_dir / "README.md", version)
    print(f"{app_dir.name}: {old} -> {version} ({release_tag})")


def github_token() -> str | None:
    return os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")


def fetch_json(url: str, token: str | None) -> object:
    headers = {"User-Agent": "hassio-apps-track", "Accept": "application/json"}
    if "api.github.com" in url:
        headers["Accept"] = "application/vnd.github+json"
        headers["X-GitHub-Api-Version"] = "2022-11-28"
        if token:
            headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        body = error.read().decode("utf-8", "replace")[:300]
        if error.code == 404:
            raise LookupError(body) from error
        raise RuntimeError(f"{url} returned {error.code}: {body}") from error


def choose_tag(names: set[str], pattern: str) -> str:
    if pattern:
        regex = re.compile(pattern)
        names = {name for name in names if regex.fullmatch(name)}
    names = {name for name in names if name and not is_prerelease(name)}
    if not names:
        raise RuntimeError("no stable tag matched")
    return max(names, key=lambda name: version_key(normalize_version(name)))


def latest_github_tag(repo: str, prefix: str, pattern: str, token: str | None) -> str:
    names: set[str] = set()
    if prefix:
        payload = fetch_json(
            f"https://api.github.com/repos/{repo}/git/matching-refs/tags/{prefix}",
            token,
        )
        if not isinstance(payload, list):
            raise RuntimeError(f"Unexpected tag list for {repo}")
        names.update(item["ref"].removeprefix("refs/tags/") for item in payload)
    else:
        try:
            release = fetch_json(f"https://api.github.com/repos/{repo}/releases/latest", token)
            if isinstance(release, dict) and not release.get("prerelease"):
                tag = release.get("tag_name") or ""
                if tag:
                    names.add(tag)
        except LookupError:
            pass
        tags = fetch_json(f"https://api.github.com/repos/{repo}/tags?per_page=100", token)
        if not isinstance(tags, list):
            raise RuntimeError(f"Unexpected tag list for {repo}")
        names.update(item.get("name") or "" for item in tags)
    return choose_tag(names, pattern)


def latest_codeberg_tag(repo: str, pattern: str) -> str:
    slug = repo.removeprefix("codeberg.org/")
    names: set[str] = set()
    releases = fetch_json(
        f"https://codeberg.org/api/v1/repos/{slug}/releases?limit=20",
        None,
    )
    if isinstance(releases, list):
        for release in releases:
            if release.get("prerelease") or release.get("draft"):
                continue
            tag = release.get("tag_name") or ""
            if tag:
                names.add(tag)
    tags = fetch_json(f"https://codeberg.org/api/v1/repos/{slug}/tags?limit=50", None)
    if isinstance(tags, list):
        names.update(item.get("name") or "" for item in tags)
    return choose_tag(names, pattern)


def latest_tag(build: dict, token: str | None) -> str:
    repo = str(build.get("upstream_repo") or "").strip()
    prefix = str(build.get("upstream_tag_prefix") or "")
    pattern = str(build.get("upstream_tag_pattern") or "")
    if repo.startswith("codeberg.org/"):
        return latest_codeberg_tag(repo, pattern)
    if "/" not in repo:
        raise RuntimeError(f"Unsupported upstream_repo value: {repo}")
    return latest_github_tag(repo, prefix, pattern, token)


def tracked_apps(root: Path) -> list[tuple[Path, dict]]:
    apps: list[tuple[Path, dict]] = []
    for build_path in sorted(root.glob("*/build.yaml")):
        build = yaml.safe_load(build_path.read_text(encoding="utf-8")) or {}
        if str(build.get("upstream_repo") or "").strip():
            apps.append((build_path.parent, build))
    return apps


def track_all(root: Path) -> int:
    token = github_token()
    failures: list[str] = []
    seen: set[str] = set()
    for app_dir, build in tracked_apps(root):
        seen.add(app_dir.name)
        current = ""
        marker = app_dir / "upstream_version.txt"
        if marker.is_file():
            current = marker.read_text(encoding="utf-8").strip()
        try:
            tag = latest_tag(build, token)
        except (RuntimeError, LookupError, urllib.error.URLError, TimeoutError, KeyError) as error:
            failures.append(f"{app_dir.name}: {error}")
            print(f"{app_dir.name}: FAILED {error}", file=sys.stderr)
            continue
        if tag == current:
            print(f"{app_dir.name}: {tag} already recorded")
            continue
        try:
            update_app(app_dir, tag, force=False)
        except (OSError, ValueError, SystemExit) as error:
            failures.append(f"{app_dir.name}: {error}")
            print(f"{app_dir.name}: FAILED {error}", file=sys.stderr)
    for app_dir in sorted(path for path in root.iterdir() if (path / "config.yaml").is_file()):
        if app_dir.name not in seen and (app_dir / "build.yaml").is_file():
            print(f"{app_dir.name}: no upstream_repo, left unchanged")
    if failures:
        print("Some apps could not be updated:", file=sys.stderr)
        for failure in failures:
            print(f"  {failure}", file=sys.stderr)
        return 1
    return 0


def main() -> None:
    if len(sys.argv) == 2 and sys.argv[1] == "--all":
        raise SystemExit(track_all(REPO_ROOT))
    if len(sys.argv) != 3:
        raise SystemExit(
            "usage: update-upstream-version.py --all\n"
            "       update-upstream-version.py APP_DIR RELEASE_TAG"
        )
    update_app(Path(sys.argv[1]), sys.argv[2], force=True)


if __name__ == "__main__":
    main()
