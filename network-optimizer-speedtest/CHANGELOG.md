# Changelog

## 2.11.0

- Upgrading from upstream version 2.10.7 -> 2.11.0

> Upstream v2.11.0: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.0
>
> > **On-Site Agent update (optional):** if you'll apply Change Control Plans on a Site behind an On-Site Agent, upgrade the Agent so that it can automatically roll back a Change that inadvertently cuts the Site off from Network Optimizer. It also carries every Agent fix and improvement since v2.10.0. Open **Settings - Multi-Site**, expand your Site, press **Upgrade**, and run the command for your install (on an On-Gateway Agent, **Run It for Me** runs it for you). If you updated on v2.11.0-preview19, you're set.
>
> The headline is Change Control. Every configuration Change on your Sites is recorded as it happens: who made it (an admin, Network Optimizer, or UniFi on its own), exactly which fields moved, what it did to your Security Audit, and what latency, throughput, and Wi-Fi Clients did in the hour after. When something breaks, the Incident lists the Changes from the two hours before it, you can roll any one of them back, and a Plan you apply to a Device's management path or a WAN reverts itself if a Device drops off.
>
> On top of that history, you can edit any Site's config in one place, save the Networks, Wi-Fi, and firewall you got right as a Template, and roll it out to your other Sites or a brand new one, with the Security Audit impact shown before anything is written. When a Site needs restructuring, Migrate / Restore moves a Device's config to new hardware, groups Networks into Firewall Zones, and re-addresses LAN Networks along with every address that depends on them.
>
> Outside Change Control, the Wi-Fi Optimizer tells your own APs from your neighbors', Adaptive SQM gets an experimental CAKE download shaper, and pages, charts, and Alerts run on each Site's own clock.
>
> ## What you missed on v2.10.1+
>
> - **Path Localization** (#1334) - when one destination degrades while the rest of your connection stays clean, ISP Health traces the route to it and says where the problem first shows up, or that it's most likely on the return path. An episode across several destination networks lowers Transit Health, so a Site with evening congestion will see its score drop.
> - **Automatic Blocking Exceptions** - let specific traffic through when a public block list catches something a Site needs, narrowed to a Device, an address, a protocol, or a port, with an optional expiry.
> - **Fix: no Wi-Fi metrics on UniFi Network 11** - **Metrics**, **Environment**, Client Performance's signal history from UniFi Network, and Channel Recommendation's history were empty.
> - **Throughput history** (Client Performance - Speed) - the Throughput card gets its own range from 1h to 30d, with average and peak, the measured WAN share, and the Client's speed tests as marks that open their result.
> - **Console Access** in Security Audit (#1342) - flags API Keys and Local Admin accounts unused for 7+ days, Critical after 30.
> - **Cable Modem Stats, Cellular Stats, and ONT Stats** - new cable modems: the FRITZ!Box 6690 Cable (#1299, thanks @gmdfalk), ARRIS SURFboard SB6141 (thanks Conlan for the HAR), and Xfinity XB7 (thanks @papisosa for the HAR). New cellular modems: the UDR-5G-Max's built-in modem (over Gateway SSH) and MikroTik LTE routers on RouterOS 7 (thanks @kongkr-code for the output). And the Richerlink RL821GWV-D ONT (thanks Srinivas for the traces and his bridge script).
>
> See the [v2.10.7](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.7), [v2.10.6](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.6), [v2.10.5](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.5), [v2.10.4](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.4), [v2.10.3](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.3), [v2.10.2](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.2), and [v2.10.1](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.1) release notes for the full detail.
>
> ## Change Control
>
> - **Change Control** - a new page that takes a Snapshot of each Site's config whenever UniFi Network logs a Change or a Device is provisioned, plus once a day. Each Change names who made it: an admin, Network Optimizer, UniFi itself after an upgrade, or **Unattributed**.
> - **Overview** covers every Site you can see: recent Changes, **Needs Attention**, Plans in progress and drafts, and the last UniFi Network upgrade.
> - **Site Health** - one hourly score per Site, for how much of the time your users had good service across internet, Devices, Wi-Fi, and LAN, with the top issue and what it cost. It backfills 90 days and alerts when it falls after a Change.
> - **Change Alerts** fire on a Change that adds a Security Audit issue, an unattributed Change to the management path or sensitive settings like Wi-Fi security, a Console admin added or removed, and each UniFi Network upgrade.
> - **Alerts & Schedule - Incidents** lists the config Changes from the two hours before an Incident a Change could cause, such as a Device going offline, each with **Roll Back**.
> - **Firmware Rollout** pins a Snapshot before every rollout and pauses one when the UniFi Network upgrade leaves a new Security Audit issue or an unattributed Change. After a firmware rollback, **Compare Config Snapshot** shows what moved.
> - **UniFi Network 11 upgrades** - **Needs Attention** lists anything an upgrade deleted (in testing, two disabled Static Routes whose WAN no longer existed).
> - **Snapshots and Retention** on the Settings tab sets how long Snapshots and copies of UniFi's .unf Backups are kept, and the disk space they use.
>
> ### Changes
>
> - **A timeline per Site** with loaded latency, Change markers by who made them, and Incident bands. Expand a Site for WAN latency, loss, and throughput, Gateway CPU, and Wi-Fi Clients by band on the same time axis.
> - **A Change opens to what changed**: its Security Audit impact first, each setting in UniFi Network's own names (Port Mode: Infrastructure to Edge) and moved Firewall Rules with their neighbors, and the hour before and after it with the Incidents that followed. Firmware and UniFi Network upgrades are on the timeline too.
>
> ### Snapshots + Templates
>
> - **Compare** two Snapshots, or one against live, with the Security Audit impact first and a field-by-field or YAML diff. Drift from the Baseline is flagged, and **Return to Baseline** applies in one click when there's nothing to review.
> - **Templates** - save part of a Site's config (Networks, Wi-Fi, firewall) from live or any Snapshot, and apply it to another Site, a new one, or as that Site's Baseline. It only adds and updates, matched to each Site's own objects, and never deletes.
> - **UniFi Console Backups** - hourly copies of UniFi Network's own Autobackups, for Site Admins to download. Restoring one stays UniFi's job.
>
> ### Edit
>
> - **A YAML editor for every config collection**, in UniFi's field names, with completion from the Site's own config and problems shown as you type. **Review Plan** turns the edit into a Plan.
> - **+ Add** creates WLANs, Networks, Port Profiles, Firewall Policies and Zones, Groups, and Local DNS records from UniFi's own defaults. Firewall Policies are grouped by Zone pair with arrows to reorder them, and UniFi's predefined objects and Network Optimizer's own are **Read-only**. Removing a Client forgets it in UniFi Network.
> - **Search across every collection** - by field name, value, or the name you'd call it (VLAN finds Networks, SSID finds WLANs), with a match count per collection.
> - **YAML** and **Collection YAML** download the whole Site or one collection to edit offline and upload back, and **Problems** warns about anything the upload would delete.
> - **Secrets stay masked** (Wi-Fi passphrases, PPSK, VPN keys): a Site Admin can **Show** one, which is audited.
> - **Templates are edited here too**, with the same editor and checks.
>
> ### Review Plan
>
> - **Every apply is a Plan** (a rollback, an edit, a Template, a migration), with the Security Audit impact first and a lockout check for anything on a Device's management path or a WAN, confirmed by typing the Site's name. Deletes, passphrase Changes, and a firewall Change that cuts a Network off the internet need acknowledging. **When to Apply** suggests the quietest hour from the last 14 days of WAN traffic.
> - **Commit-confirmed** - a Plan that touches the management or WAN path is watched after it applies, and reverts on its own if a Device that was online drops off or the Console loses internet (a re-address of the Devices' management Network alerts instead, since Devices drop while they move). With **Approvals** on, a Plan waits for a Site Admin.
> - **The Security Audit runs after a Plan applies**, so its score shows the new config without a **Run Audit**.
>
> ### Migrate / Restore
>
> - **Restore a Snapshot** from any of your Sites onto this one, optionally removing what the Snapshot lacks. **Write Device Config** sends the Snapshot's config to a Device you adopt afterwards.
> - **Replace Device** - moves a Device's config to new hardware, a different model included, with ports and AP Radios mapped to the new model and a re-cabling sheet PDF. A replacement on older firmware links to Firmware Rollout's **Deploy Known Firmware** for that build.
> - **Set Up Zones** - group LAN Networks into Firewall Zones by trust level from their Security Audit purposes. Named exceptions allow only their ports, untrusted Zones are kept off the Gateway's SSH and web UI, and the Security Audit checks the result live. Your existing Policies move into the new Zones (where UniFi Network only pauses them), redundant Block Rules are removed, and Isolation Findings link here with **Fix with zones**.
> - **Translate Legacy Rules** - after UniFi Network moves a Site to Zone-Based Firewall, turns its legacy Firewall Rules into Zone Policies and lists the ones it can't translate, which you accept by name.
> - **Re-address Networks** - move LAN Networks to new subnets by a pattern (`10.42.{vlan}.0/24`) or per Network, and every address that depends on them moves too, from Reservations and Local DNS to Firewall Policies and Device static IPs, and a Network Device that doesn't reconnect gets set-inform over SSH. Client Reservations and their Local DNS names move with their Network, where UniFi Network drops them when a subnet changes.
> - **Moving Clients** - the dry run lists Clients with a static address set on the Client itself. **Lower Lease Times** before the move and **Reconnect Clients** after it get Clients onto their new addresses within minutes.
>
> ## Security Audit
>
> - **Fix it for me** on DNS Findings - opens a Change Control Plan with the fix, built on your existing Firewall Rules where it can, so you review it before anything is written.
> - **DoH is checked per Network**, like DoT and DoQ - a partial block reads **Partially Blocked** with the Networks it misses.
> - **Guest and Hotspot Networks are held to the same DNS bar** - UniFi's Hotspot blocks only hold until a guest is authorized, so they no longer count. Expect new DNS Findings on guest Networks; **Allow Guest / Hotspot Public DNS** in the **Security Audit** settings leaves them out.
> - **Gateway Firewall** (Gateway SSH) - the audit checks your Gateway's own firewall against UniFi Network: each WAN and Network in its Zone, every enabled Policy present and no disabled ones, and Automatic Blocking in place.
>
> ## Dashboard
>
> - **Sites** (Multi-Site) says which Site needs you and why: Site Health and its trend, worst first, and each Site's top issue, which opens the page to investigate it. A Firmware Rollout scheduled, running, or just finished shows as a pill.
> - **Signal history behind Cable Modem Stats, ONT Stats, and Cellular Stats** - the last 24 hours of downstream SNR, Rx optical power, or signal quality sits faintly behind the reading.
>
> ## Date & Time
>
> - **Times on each Site's own clock** - pages, charts, Alerts, and the Security Audit PDF use the Site's time zone from its UniFi Console, and name it. Before, they followed the server's (`America/Chicago` on a Docker or Proxmox install that never set `TZ`).
> - **Your own time zone and format** - set your time zone, 12- or 24-hour time, and date order (ISO 8601 included) on your account's **Security** page. A Global Admin sets the defaults in **Settings - Application**.
> - **Fix: Site schedules ran on the server's clock** - on an install whose time zone differs from a Site's, ISP Health read Adaptive SQM's speed test schedule on the server's clock, so those speed tests counted against the ISP score, and Data Usage billing cycles started at the server's midnight.
>
> ## Monitoring
>
> ### Live View
>
> - **Last-hour history behind the ISP, Transit, and Gateway tiles** - RTT, loss, CPU, memory, and temperature sit faintly behind each tile's value.
>
> ### ISP Health
>
> - **Acknowledge a recurring path Finding that can't be pinned on a hop** (Site Admin) - it stays scored but stops raising the banner, until the problem spreads or starts costing points.
> - **Fix: a route change scored as Path Congestion** - a rise in RTT with no loss and steady jitter is a **Path shift** now, with no score impact.
> - **Fix: your own WAN load blamed on your ISP's nearest hop** - when every path slowed under your own load and one far path slowed more, ISP Health showed **Congestion** there and counted it against the score. It reads as **Loaded Latency** now.
>
> ### Network Performance
>
> …

## 2.10.7

- First Home Assistant app release wrapping upstream Speed Test `2.10.7`
  (`ghcr.io/ozark-connect/speedtest`).
- Thin image: official `/docker-entrypoint.sh` preserved; HA options → env.
- Publishes host **3005** → container 3000; exposes full host / proxy env so
  result POSTs and canonical redirects follow the assigned URL.
- Upstream brand icon; track-upstream via the NetworkOptimizer GitHub releases.

> Upstream v2.10.7: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.10.7
