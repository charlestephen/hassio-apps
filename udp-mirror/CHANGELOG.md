# Changelog

## 0.1.1-1

- Fix: upstream's own image has no shell, and its `ENTRYPOINT` names a
  `udp-mirror` binary that doesn't exist anywhere in the image (the real
  binary is `/app/udp_mirror`, not on `PATH`) — the image never actually
  built, and upstream's own image is unusable as shipped. Now copies the
  real binary into the HA base image instead of wrapping upstream's image
  directly.

## 0.1.1

- Initial release.
- udp-mirror 0.1.1, thin wrapper on the official `czerwonk/udp-mirror` image.
- `listen_address` and `receivers` options.
- Ships an AppArmor profile (`apparmor.txt`).
