# Changelog

## 2026.9.3

- Upgrade cloudflared 2026.9.1 -> 2026.9.3

> Upstream 2026.9.3: https://github.com/cloudflare/cloudflared/releases/tag/2026.9.3
>
> ### SHA256 Checksums:
> ```
> cloudflared-amd64.pkg: 48d0d3b28b3b5d142490f57316981b65ae46fbbe33408c22b0a4a11b5242de50
> cloudflared-arm64.pkg: 79f17181cda2bbcfe6ad36cd9ee1946faaf079e6a9d6c0bc4a32fbb644a4c29d
> cloudflared-darwin-amd64.tgz: ab588b3b4db9cdb4476c30a3db2a72635b1d8327d44741fee6799a0f37b0ec07
> cloudflared-darwin-arm64.tgz: 5472c1a01c84bc31b3021056a73b4e5774ddddefc572124ea8fdf6c340639f32
> cloudflared-fips-linux-amd64: 32a68f04c5816304ece7f5129ab81581c95eb26352848d2605cde42d63316e88
> cloudflared-fips-linux-amd64.deb: 4dd10ab302a672c34739d88305ad83bf847b37840ccbd1f17a2ab94bf3dc690c
> cloudflared-fips-linux-x86_64.rpm: eae2945bc1b947d225b25325eda961be1fa924097d9cfdd0ae70e154bd16dc3e
> cloudflared-linux-386: d6b2f917e2e78b3e3afba760af726e51751d10c2fcad4a2fb2a69feb4bd47421
> cloudflared-linux-386.deb: efd821ce6adeb899b419a26965f09ca4d64c7dca9b386b1be6ecb5b7e947cf34
> cloudflared-linux-386.rpm: e3c3d6bf81c14eec403a540328e66ef3304539fc5c00f0dada6d5b70a9205d59
> cloudflared-linux-aarch64.rpm: e37b746dd252ab51b8dbe90f07eaf50c0335d137009cc224a97203acf1c331ab
> cloudflared-linux-amd64: 77e26d8d900e0b8469f416239d14b5f296525fdf79fee6f511ef55609e3fbac2
> cloudflared-linux-amd64.deb: bc073ef293d504cf5ac533bd0aa1c824ef6b4f358765ccaa6628a8a95cacb4b7
> cloudflared-linux-arm: 967dc371a3fedbf09e881c13ee7ba317155ebc336cbd4afb756b46fc6785e5af
> cloudflared-linux-arm.deb: a9d12267d5991328c40c5071fcc82c3d6d1953800bd30d3530a5120b2dda9b4f
> cloudflared-linux-arm.rpm: 20b3b2ae15b744a04eb27b94300450eb9d280ffff4d196ff3e2509daaf0c7024
> cloudflared-linux-arm64: aaeb2d7d0da3614634c7e03ab13487a1522c2e79165ed2929cfe23d5e95b326d
> cloudflared-linux-arm64.deb: bcce0111878f13d26e66b1d2ea7f270c8bde4bd549e32ce74d32474521583ca3
> cloudflared-linux-armhf: a714b1bee87e71ce7260555b30722ce711d12aaa0fee5a8aadc767ee6b816a14
> cloudflared-linux-armhf.deb: 4815dd7fc7b4c3ff5d29a7bbe80bba9e253d29b2eb84079e853b158fdfd7e975
> cloudflared-linux-armhf.rpm: 4350c58a83ce4cd8717eb6352713e6d2d615c204a6e6161015cf0db4a2142c18
> cloudflared-linux-x86_64.rpm: b64f9131b5ea2772c4a8fb9fb67f95437190ad63e909871396adb92c2b6d99eb
> cloudflared-windows-386.exe: 9b95ddc2eba67b86ed3dc4cc2a15881960563031b52ce564376af41fb91ad402
> cloudflared-windows-386.msi: c26a212d4e04e3d0525aa131c02653801920cd88c706cb67c0eb8a09293f4591
> cloudflared-windows-amd64.exe: f096265ec2fcbe9bb6e2d64268db167ced3fcbb83d894bdb9e2fcdb26f2ea7e2
> cloudflared-windows-amd64.msi: 597c2f4daa5965f10a3893a56aefe27a5e5946bcbd333d984a32743c6df7a561
> ```

## 2026.9.1

- Upgrade cloudflared 2026.7.1 -> 2026.9.1.

## 2026.7.1-1

- CI/registry: image now builds via **GitHub Actions** and publishes to
  **GHCR** (`ghcr.io/charlestephen/hassio-addons-cloudflared-{arch}`), replacing
  the Forgejo self-hosted runner / private registry pipeline. The image is
  now public, so no registry credentials are needed to install this app.

- Docs: renamed "add-on" → "app" throughout (branding only, no
  functional change).

## 2026.7.1

- Update cloudflared to 2026.7.1.

## 2026.6.1.b

- Icon: replaced the placeholder with the Cloudflare cloud and two tunnel bars.

## 2026.6.1.a

- Initial release: dual-replica Cloudflare Tunnel (HA) on the stock
  `cloudflare/cloudflared` image (pinned `2026.6.1`).
- Two connector replicas (`cloudflared0`, `cloudflared1`) of one remotely-managed
  tunnel; Cloudflare-native load-balancing/failover; automatic nearest +
  second-nearest edge selection.
- Prometheus metrics per replica (`:36400` / `:36401`).
- Token passed via `TUNNEL_TOKEN` env (kept out of process args).
- Added default icon.png / logo.png.
- cloudflared self-updater disabled (`--no-autoupdate`); image version managed by
  Renovate + Forgejo CI.
