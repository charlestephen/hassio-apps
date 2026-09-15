# Home Assistant App: UniFi Voucher Manager

## Setup

1. Create an **API key** on your UniFi controller.
2. Install the app and set, at minimum:
   - **UniFi controller URL** (e.g. `https://unifi.example.com`)
   - **UniFi API key**
3. For QR codes, set **WiFi SSID**, **WiFi password**, and **WiFi security**.
4. Start the app. The web UI is on port **3000**; the REST API on **8080**.

## Networking

Both ports are published on the host. The frontend reaches the backend
internally via **Frontend→backend URL** (`http://127.0.0.1:8080` by default);
to expose the API externally, keep **Backend bind host** at `0.0.0.0`.

## Credits

UniFi Voucher Manager by [Étienne Collin](https://github.com/etiennecollin/unifi-voucher-manager).
