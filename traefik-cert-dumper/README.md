# Home Assistant App: Traefik Certs Dumper

[![Build][build-shield]][build]
[![Version][version-shield]][version]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

_Dump Traefik's ACME certificates to PEM files - thin wrapper on the kereis image._

## About

[traefik-certs-dumper](https://github.com/kereis/traefik-certs-dumper) extracts the certificates and keys from Traefik's `acme.json` and keeps the files up to date. This app maps Home Assistant options to the image's variables and writes the PEM files into the `ssl` folder. It reads and writes files only, so there are no PostgreSQL options.

See [DOCS.md](DOCS.md) for configuration.

## Credits

- [traefik-certs-dumper](https://github.com/kereis/traefik-certs-dumper) (MIT)
- [ldez/traefik-certs-dumper](https://github.com/ldez/traefik-certs-dumper) (Apache-2.0)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

[build-shield]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml/badge.svg?branch=main
[build]: https://github.com/charlestephen/hassio-apps/actions/workflows/build.yml?query=branch%3Amain+event%3Apush
[version-shield]: https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fcharlestephen%2Fhassio-apps%2Fmain%2Ftraefik-cert-dumper%2Fconfig.yaml&query=%24.version&label=version&color=blue
[version]: https://github.com/charlestephen/hassio-apps/tree/main/traefik-cert-dumper
