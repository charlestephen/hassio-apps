# Home Assistant App: Tang

## Overview

Tang is a server for Network Bound Disk Encryption (NBDE). It allows LUKS2-encrypted volumes to be automatically unlocked when a machine is on the same network as the Tang server.

## How it works

Tang provides cryptographic key services over HTTP. Clients use Clevis to bind LUKS2 volumes to a Tang server. When the client can reach the Tang server, volumes are automatically unlocked without user interaction.

## Configuration

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually sufficient) messages.
- `warning`: Only shows warning and error messages.
- `error`: Only shows error messages.
- `fatal`: Only very severe error messages.

## Client setup

On a client machine with Clevis installed:

```bash
# Bind a LUKS2 volume to this Tang server
clevis luks bind -d /dev/sdX tang '{"url":"http://<hassio-ip>:8888"}'

# Verify the binding
clevis luks list -d /dev/sdX
```

## Key management

Tang keys are stored persistently in `/data/tang/db`. Keys are auto-generated on first startup. To rotate keys, stop the app, remove old keys from the data directory, and restart.
