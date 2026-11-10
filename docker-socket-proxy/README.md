# Home Assistant App: Docker Socket Proxy

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Filtered TCP proxy in front of the host Docker socket, powered by
[Tecnativa/docker-socket-proxy][upstream]._

## About

Giving containers raw access to `/var/run/docker.sock` is effectively root on
the host. This app mounts the socket once (with **Protection mode** off) and
serves an allow-listed Docker Engine API on port `2375` on the hassio network
only (not published on the host by default). Other apps set
`DOCKER_HOST=tcp://dd815a57-docker-socket-proxy:2375` instead of mounting the socket.

The app version tracks upstream Tecnativa releases via the repository's
upstream updater.

## Protection mode

Turn **Protection mode → OFF** on the add-on's Info page before starting.
Without that, Supervisor will not mount the Docker socket.

See [DOCS.md](DOCS.md) for API toggles and consumer wiring.

## Credits

- [Tecnativa/docker-socket-proxy][upstream] — HAProxy-based Docker API filter
  (Apache-2.0)

[upstream]: https://github.com/Tecnativa/docker-socket-proxy

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fdocker-socket-proxy%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/docker-socket-proxy
