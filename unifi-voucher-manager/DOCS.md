# Home Assistant App: UniFi Voucher Manager

## Setup

1. Create an **API key** on your UniFi controller.
2. Install the app and set, at minimum:
   - **UniFi controller URL** (e.g. `https://unifi.example.com`)
   - **UniFi API key**
3. For QR codes, set **WiFi SSID**, **WiFi password**, and **WiFi security**.
4. Start the app. The web UI is on port **3000**; the REST API on **8080**.

## Networking

By default only the frontend (port 3000) is published on the host. The
backend REST API binds to `127.0.0.1` inside the container and is reached by
the frontend via **Frontend→backend URL** (`http://127.0.0.1:8080`) — it has
no auth of its own, so it isn't exposed externally unless you deliberately
set **Backend bind host** to `0.0.0.0` and give the `8080/tcp` port a host
port in the add-on's Network settings.

## Credits

UniFi Voucher Manager by [Étienne Collin](https://github.com/etiennecollin/unifi-voucher-manager).
