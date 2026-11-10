# Home Assistant App: Speedtest Tracker

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Scheduled internet speed tests with history and charts - thin wrapper on the LinuxServer.io image._

## About

[Speedtest Tracker](https://github.com/alexjustesen/speedtest-tracker) runs Ookla speed tests on a schedule and charts the results. This app maps Home Assistant options to the variables the [LinuxServer.io image](https://docs.linuxserver.io/images/docker-speedtest-tracker/) reads, uses the PostgreSQL app in this repository for its database, then runs the image's own init.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [Speedtest Tracker](https://github.com/alexjustesen/speedtest-tracker) (MIT)
- [LinuxServer.io](https://www.linuxserver.io/) image (GPL-3.0)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Fspeedtest-tracker%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/speedtest-tracker
