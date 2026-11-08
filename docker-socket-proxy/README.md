# Home Assistant App: Docker Socket Proxy

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Filtered TCP proxy in front of the host Docker socket, powered by
[Tecnativa/docker-socket-proxy][upstream]._

## About

Giving containers raw access to `/var/run/docker.sock` is effectively root on
the host. This app mounts the socket once (with **Protection mode** off) and
serves an allow-listed Docker Engine API on port `2375` on the hassio network
only (not published on the host by default). Other apps set
`DOCKER_HOST=tcp://docker-socket-proxy:2375` instead of mounting the socket.

The app version tracks upstream Tecnativa releases via the repository's
upstream updater.

## Protection mode

Turn **Protection mode → OFF** on the add-on's Info page before starting.
Without that, Supervisor will not mount the Docker socket.

See [DOCS.md](DOCS.md) for API toggles and consumer wiring.

## Credits

- [Tecnativa/docker-socket-proxy][upstream] — HAProxy-based Docker API filter
  (Apache-2.0)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[upstream]: https://github.com/Tecnativa/docker-socket-proxy
