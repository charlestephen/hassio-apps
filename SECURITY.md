# Security policy

## Supported versions

Only the current version of each app in this repository receives fixes. Apps are rebuilt when their upstream project
releases a new version or when this repository changes them.

## Reporting a vulnerability

Report vulnerabilities in the wrapper code, configuration or build workflows of an app in this repository through
[private vulnerability reporting](https://github.com/charlestephen/hassio-apps/security/advisories/new). If that is not
available to you, email hassio-apps@cst.nyc. Please do not open a public issue for a vulnerability.

Include the app name and version, what you found, and how to reproduce it. You should get an acknowledgement within a
week.

## What belongs upstream

Each app wraps a third-party project. A vulnerability in that project itself, rather than in the wrapper, should be
reported to the upstream maintainers. Image scan results for upstream packages are published by the `Container image scan`
workflow and are not suppressed.
