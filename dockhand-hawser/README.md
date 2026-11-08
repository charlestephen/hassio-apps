# Home Assistant App: Hawser Agent for Dockhand

[![Build][build-shield]][build]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Doesn't support armhf Architecture][armhf-shield]
![Doesn't support armv7 Architecture][armv7-shield]
![Doesn't support i386 Architecture][i386-shield]

_Run the Hawser agent to let [Dockhand](https://dockhand.pro) manage your Home Assistant Docker host — containers, images, networks, volumes and Compose stacks — from anywhere._

## About

[Hawser](https://github.com/Finsys/hawser) is a small Go agent that bridges a
Docker host to a [Dockhand](https://dockhand.pro) server. This app runs it
inside Home Assistant so Dockhand can manage the Docker environment your HA
instance lives on.

It supports both **Edge** mode (agent dials out to Dockhand — best behind NAT
or on a dynamic IP) and **Standard** mode (agent listens for connections from
Dockhand — best on a LAN with a stable address).

The Hawser binary is baked into the image. The app version tracks upstream
Hawser releases via the repository's upstream updater.

## ⚠️ Turn off Protection mode

The agent needs access to the host's Docker socket (`/var/run/docker.sock`).
Home Assistant guards that behind **Protection mode**, so before starting the
add-on, open its **Info** page and toggle **Protection mode → OFF**. Without
this, Hawser comes up but every Docker call from Dockhand will fail.

See [DOCS.md](DOCS.md) for full configuration and usage.

## Credits

- [Hawser](https://github.com/Finsys/hawser) — the Dockhand agent (MIT)
- [Dockhand](https://dockhand.pro) — Docker host management UI

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-no-red.svg
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
