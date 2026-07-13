# Home Assistant Add-on: Resolved Watchdog

Keeps the node's **on-node DNS** working by auto-restarting the host's
`systemd-resolved` whenever it hangs — so a wedged host resolver self-heals
instead of needing host-console access.

## Why this exists

This node runs its own DNS (Technitium) as a host-network add-on, and the host
is configured to resolve through it (required, because UniFi blocks using a
resolver in another VLAN). That's a self-dependency: if the local resolver or
the host network blips, `systemd-resolved` can hang, which stalls the Supervisor
in `setup` and breaks DNS for every host-network container. This add-on detects
that and restarts `systemd-resolved`.

It **only restarts the unit** — it never disables the stub listener or edits
`resolved.conf` — so it does not put the install into an "unsupported" state.

## How it works

- `host_network: true` — so it can probe the host's resolver stub `127.0.0.53`.
- `host_dbus: true` — so it can call `systemd1.RestartUnit` on the host system bus.
- Every `interval` seconds it runs `nslookup <canary_host> <stub_address>`.
  After `failures_before_restart` consecutive failures it restarts `restart_unit`.

## Options

| Option | Default | Description |
| --- | --- | --- |
| `canary_host` | `cloudflare.com` | Name to resolve as the health probe. |
| `stub_address` | `127.0.0.53` | Host resolver stub to query. |
| `interval` | `30` | Seconds between checks. |
| `timeout` | `5` | Per-probe timeout (seconds). |
| `failures_before_restart` | `2` | Consecutive failures before a restart. |
| `restart_unit` | `systemd-resolved.service` | Host unit to restart. |
| `log_level` | `info` | Log verbosity. |

## Requirements

- **Protection mode OFF** (so `host_dbus`/`host_network` are honored).
- The host D-Bus policy must permit `RestartUnit` from the add-on. Verify once by
  watching the log after forcing a failure; if you see "Could not restart … over
  host D-Bus", the policy is blocking it.
