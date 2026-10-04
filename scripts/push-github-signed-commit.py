#!/usr/bin/env python3
"""Commit version updates with a signature GitHub will accept on main.

A local `git commit` is unsigned. main rejects it. createCommitOnBranch signs
the commit when the caller is the GitHub Actions bot and the request does not
set an author, committer, or signature.
"""

from __future__ import annotations

import base64
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
ALLOWED = re.compile(
    r"^[a-z0-9_-]+/(?:upstream_version\.txt|config\.yaml|build\.yaml|Dockerfile|CHANGELOG\.md|DOCS\.md|README\.md)$"
)
MUTATION = """
mutation($input: CreateCommitOnBranchInput!) {
  createCommitOnBranch(input: $input) {
    commit { oid }
  }
}
"""


def git_output(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=REPO_ROOT, text=True).strip()


def changed_files() -> list[str]:
    status = subprocess.check_output(
        ["git", "status", "--porcelain", "-u"],
        cwd=REPO_ROOT,
        text=True,
    )
    paths: list[str] = []
    for line in status.splitlines():
        path = line[3:].strip()
        if " -> " in path:
            path = path.split(" -> ", 1)[1]
        path = path.strip('"')
        if ALLOWED.fullmatch(path):
            paths.append(path)
    return sorted(set(paths))


def repository() -> str:
    repo = os.environ.get("GITHUB_REPOSITORY", "")
    if repo:
        return repo
    remote = git_output("remote", "get-url", "origin")
    match = re.search(r"github\.com[:/]([^/]+/[^/.]+)", remote)
    if not match:
        raise SystemExit(f"Could not parse GitHub repository from {remote}")
    return match.group(1)


def branch_name() -> str:
    name = os.environ.get("GITHUB_REF_NAME", "")
    if name:
        return name
    return git_output("rev-parse", "--abbrev-ref", "HEAD")


def api_json(url: str, token: str, payload: dict | None = None) -> dict:
    data = None if payload is None else json.dumps(payload).encode()
    request = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "Content-Type": "application/json",
            "User-Agent": "hassio-apps-track",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            body = json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", "replace")[:500]
        raise RuntimeError(f"GitHub API {error.code}: {detail}") from error
    if not isinstance(body, dict):
        raise RuntimeError("GitHub API returned an unexpected payload")
    return body


def head_oid(repo: str, branch: str, token: str) -> str:
    payload = api_json(f"https://api.github.com/repos/{repo}/git/ref/heads/{branch}", token)
    oid = ((payload.get("object") or {}).get("sha")) or ""
    if not oid:
        raise RuntimeError(f"Could not read the tip of {branch}")
    return oid


def commit_message(paths: list[str]) -> tuple[str, str]:
    lines: list[str] = []
    for path in paths:
        if not path.endswith("/upstream_version.txt"):
            continue
        app = path.split("/", 1)[0]
        tag = (REPO_ROOT / path).read_text(encoding="utf-8").strip()
        lines.append(f"{app} {tag}")
    headline = "chore: bump add-ons to latest upstream versions"
    return headline, "\n".join(lines)


def create_commit(repo: str, branch: str, token: str, paths: list[str], oid: str) -> str:
    headline, body = commit_message(paths)
    additions = []
    for path in paths:
        content = (REPO_ROOT / path).read_bytes()
        additions.append(
            {
                "path": path,
                "contents": base64.b64encode(content).decode("ascii"),
            }
        )
    message: dict[str, str] = {"headline": headline}
    if body:
        message["body"] = body
    payload = api_json(
        "https://api.github.com/graphql",
        token,
        {
            "query": MUTATION,
            "variables": {
                "input": {
                    "branch": {
                        "repositoryNameWithOwner": repo,
                        "branchName": branch,
                    },
                    "message": message,
                    "fileChanges": {"additions": additions},
                    "expectedHeadOid": oid,
                }
            },
        },
    )
    errors = payload.get("errors") or []
    if errors:
        detail = "; ".join(error.get("message", "unknown error") for error in errors)
        raise RuntimeError(detail)
    commit = ((payload.get("data") or {}).get("createCommitOnBranch") or {}).get("commit") or {}
    oid = commit.get("oid") or ""
    if not oid:
        raise RuntimeError("GitHub did not return a commit id")
    return oid


def main() -> None:
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        raise SystemExit("GITHUB_TOKEN is required")
    paths = changed_files()
    if not paths:
        print("No version changes to commit.")
        return
    repo = repository()
    branch = branch_name()
    last_error = "commit failed"
    for _attempt in range(3):
        oid = head_oid(repo, branch, token)
        try:
            new_oid = create_commit(repo, branch, token, paths, oid)
        except RuntimeError as error:
            last_error = str(error)
            lowered = last_error.lower()
            if "did not match" in lowered or "expected head" in lowered:
                print(f"Branch moved, retrying: {last_error}", file=sys.stderr)
                continue
            raise SystemExit(last_error) from error
        print(f"Committed {new_oid}")
        return
    raise SystemExit(last_error)


if __name__ == "__main__":
    main()
