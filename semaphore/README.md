# Home Assistant App: Semaphore

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Modern web UI for Ansible, Terraform, OpenTofu, PowerShell, and other DevOps automation tools — running directly inside Home Assistant.

## About

[Semaphore UI](https://semaphoreui.com) is an open-source web interface for running automation tasks. It provides:

- A clean web UI for managing Ansible playbooks, Terraform plans, and more
- Team access control with projects, users, and roles
- Scheduled tasks (cron-style) and on-demand execution
- Task output streaming with searchable history
- SSH key management with encrypted storage
- Alert notifications (Telegram, Slack, Teams, email, Rocket.Chat)
- LDAP / Active Directory authentication
- 2FA (TOTP) support

## Documentation

See [DOCS.md](DOCS.md) for full configuration reference.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fsemaphore%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/semaphore
