MIT License

Copyright (c) 2025 Charles Stephen Thompson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Scope

"The Software" licensed above is this repository's own Home Assistant app
packaging — the "hassio-appification" of each upstream project under its own
directory: `config.yaml`, `build.yaml`, `Dockerfile`, `apparmor.txt`, the
`rootfs/` entrypoint and wrapper scripts, translations, icons/logos created
for this repository, and this repository's own documentation (`README.md`,
`DOCS.md`, `CHANGELOG.md`).

It does not cover the upstream applications themselves. Each app's container
image is built from, or wraps, that project's own official release, under
that project's own license — not this one. This repository's MIT license
does not grant, relicense, or otherwise affect any rights in that upstream
software. See each app's own `DOCS.md`/`README.md` and `Dockerfile` for the
specific upstream project, version, and license it uses.