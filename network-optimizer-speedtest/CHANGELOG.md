# Changelog

## 2.11.7

- Upgrading from upstream version 2.11.6-oomtest1 -> 2.11.7

> Upstream v2.11.7: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.7
>
> > **On-Site Agent update (optional; the v2.11.6 Agent, unchanged in v2.11.7):** if you skipped v2.11.6, the Agent on your UniFi Gateway times each connection's round trip for Live Traffic, and on the UDM-Beast, EFG, EF-Core, and UXG-Enterprise it fixes the Agent's out-of-memory errors. Open **Settings - Multi-Site / Agents**, expand your Site, press **Upgrade**, and press **Run It for Me**. If you updated on v2.11.6, you're set.
>
> The Dashboard's speed test cards now keep up on their own, and Performance Tweaks supports UniFi OS 6.0.19 EA on the UCG line. See the [v2.11.6 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.6), the [v2.11.5 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.5), the [v2.11.4 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.4), the [v2.11.3 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.3), the [v2.11.2 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.2), the [v2.11.1 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.1), and the [v2.11.0 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.0) for what's new in v2.11.0+.
>
> ## Coming Soon
>
> - **LAN Health** - a score for every link between your UniFi Devices and every wired port, with when the trouble started and which end it's on, including drops UniFi Network never shows. Try it now in [v2.12.0-preview5](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.12.0-preview5).
>
> ## Dashboard
>
> - **WAN Speed Test and LAN Speed Test cards update as tests finish** - a result shows on its card as soon as it's saved, a Client Speed Test from your phone included, with no reload. The device name and icon fill in a few seconds later, once Network Optimizer has matched the Client.
>
> ## Site Health
>
> - **Fix: A Gateway update read as ISP loss** - while your Gateway installed a UniFi OS update, Site Health labeled its packet loss "(ISP)". It now reads as the Gateway updating, and stored hours are recomputed after the upgrade.
>
> ## Monitoring
>
> ### Live Traffic
>
> - **Fix: Live Traffic waited forever with Monitoring off** (thanks Samfisher for the report) - the On-Site Agent reads flows only while the Site's Monitoring is on, so without it Live Traffic and a Client's Live Traffic card sat on "Measuring rates" for good. They now say Monitoring is off and link **Monitoring - Setup**, where **Enable Monitoring** turns it on.
>
> ### Network Performance
>
> - **Fix: Two transit hops with the same name after a rediscovery** - **Upstream Path Discovery** names a transit hop with no reverse DNS by number ("AT&T 1"), and a rediscovery that found a new one could give it the name of an older hop still saved. A new hop whose name is taken now gets a suffix ("AT&T 1-1"), the way hops sharing a number already did, and the next discovery renames an existing duplicate the same way.
>
> ### Network Tools
>
> - **Fix: No SFP data for a PPPoE WAN** (#1434, thanks @Optic00) - in **Inspect a Gateway Interface**, a PPPoE WAN showed its addresses but nothing under **SFP Module**, because the module sits on the port the PPPoE session runs over. It now reads the module from that port, as UniFi Network reports it, and the card names the port it read ("read from eth6").
>
> ## Change Control
>
> - **Fix: Your own edits after a Network app upgrade read as the upgrade's** - for an hour after UniFi Network updated, a change Network Optimizer couldn't tie to an admin was filed as "changed during Network app upgrade", and that included the port profile and switch port updates UniFi makes on its own when you add or remove a network. Those now go to whoever added or removed the network, and the upgrade's own window is down to the 10 minutes its migration actually takes.
> - **Fix: Add Network on UniFi Network 11.1** - a Network added in **Edit** applied as Partial ("Not applied by UniFi: DHCPv6, mDNS"); it now applies clean.
> - **Fix: A false "still used by" warning when you delete a Network in Edit** - it named UniFi's own Etherlighting colors, which UniFi clears itself, and said Review Plan would refuse the delete when it didn't.
> - **Fix: The Settings tab no longer jumps around** - on laptop-width windows, the **On this page** links flipped between the two columns several times a second, dragging the cards up and down with them. They now sit still above both columns (#1427, thanks @bondskin for the video).
>
> ## Security Audit
>
> - **Fix: A named Device needed acknowledging again on every AP, band, and offline** - acknowledging a Finding like **IoT Device Allowed on VLAN** for your TV covered it only on the AP and band it was on at the time. One acknowledgement now covers it wherever it connects, and while it's offline. Devices known only by their type ("Smart TV") still acknowledge one at a time.
> - **Fix: Security Audit settings saved values the audit could not read** - a VLAN list with a typo, or a grace period of 0, saved without complaint and the audit then ignored it. **Save Audit Settings** now shows the error under the field and saves nothing until every field passes.
>
> ## Alerts & Schedule
>
> - **Fix: Times in alerts name their time zone** - the On-Site Agent offline alert's "Last seen" and a Change Control approval's "Scheduled for" now read on the site's clock with the zone ("Nov 24, 7:47 AM CST"), as other alerts already did. Discord, Slack, Teams, ntfy, and email show an outage's start that way too, not as a raw UTC timestamp.
>
> ## Firmware Rollout
>
> - **Fix: Offline alerts mid-upgrade on a build you chose by hand** - a build pasted as a download link or picked in **Deploy Known Firmware** installs over SSH first, and the Device rebooted into its new firmware before the rollout had muted its alerts, so its offline alert fired anyway. Alerts for the Device, and for any Device behind it, now stay quiet the same as for any other upgrade.
> - **Fix: A pasted build installed over SSH went to the Console as well** - once the Device started flashing the build, the Console was sent the same upgrade too. The Console now gets it only when the Device never starts.
> - **Fix: An acknowledged Firmware Rollout Started alert stayed open** - acknowledging it while the rollout ran kept it open after the rollout finished. It now closes when the rollout does, acknowledged or not.
>
> ## On-Site Agent
>
> - **Settings - Multi-Site is now Multi-Site / Agents** (thanks Srinivas for the report) - On-Site Agents are set up there even for a single Site, and with one Site the site switcher in the top bar now stays hidden. Turning off **Enable multi-site / agent management** with an Agent enrolled now warns you first: the Agent keeps running, but you can't upgrade or configure it until the setting is back on.
>
> ## Managed SSH Key
>
> - **Fix: Remove from gateway took your own key with it** - with a key you already had on the Gateway as the managed key, **Remove from gateway**, or removing the stored key, took it out of authorized_keys too. A key that was there before Network Optimizer installed it now stays.
>
> ## Performance Tweaks
>
> - **UniFi OS 6.0.19 EA on the UCG line** - supported, verified against the UCG-Fiber 6.0.19 firmware image and live-verified on a UCG-Fiber.
>
> ## Fixes
>
> - **nginx 1.30.7 on Windows** - the nginx the MSI installs for the LAN speed test moves to 1.30.7, which carries nginx's November 18 security fixes.
> - **Fix: Remove from UniFi Network logged an error per deleted IP group** (#1424, thanks @bondskin) - on **Automatic Blocking**, an IP group UniFi had already deleted no longer logs an error.
> - Also fixed: smaller issues in the **Network Tools** traceroute tables on a phone; the Test History charts and Mbps tooltips in **WAN Speed Test** and **Client WAN Test**; the Back button, the floating Save, and the unsaved-changes warning; and Client names in Security Audit, Threat Intelligence, and speed test results.
>
> ## Installation
>
> **Windows**: Download the MSI installer below
>
> **Docker (Upgrade)**:
> ```bash
> docker compose pull && docker compose up -d
> ```
>
> **macOS** (native, recommended for accurate speed tests vs Docker Desktop):
> ```bash
> git clone https://github.com/Ozark-Connect/NetworkOptimizer.git && cd NetworkOptimizer && ./scripts/install-macos-native.sh
> # or if you already have it cloned
> cd NetworkOptimizer && git pull && ./scripts/install-macos-native.sh
> ```
>
> **Proxmox**:
> ```bash
> bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ozark-Connect/NetworkOptimizer/main/scripts/proxmox/install.sh)"
> # or if you just need to update
> pct exec <CT_ID> -- bash -c 'cd /opt/network-optimizer && docker compose pull && docker compose up -d && docker image prune -f'
> ```
>
> For other platforms (Synology, QNAP, Unraid, native Linux) or new installations, see the [Deployment Guide](https://github.com/Ozark-Connect/NetworkOptimizer/blob/main/docker/DEPLOYMENT.md).
>
> Need a hand with an install or upgrade, or something not working right? Ask on the [Network Optimizer Discord](https://discord.gg/pHrmzbBCY3). Confirmed bugs and feature requests go to [GitHub Issues](https://github.com/Ozark-Connect/NetworkOptimizer/issues).

## 2.11.6-oomtest1

- Upgrading from upstream version 2.11.5 -> 2.11.6-oomtest1

> Upstream v2.11.6-oomtest1: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.6-oomtest1
>
> **Test build of the On-Site Agent for EFG and UDM-Beast class gateways. Not a regular release: stay on the stable line unless you were asked to try this.**
>
> This build carries two On-Site Agent changes ahead of v2.11.6:
>
> - **Fix: Automatic Blocking's public block lists draining on the gateway** - On 64K-page gateways (UDM-Beast, EFG, EF-Core, UXG-Enterprise), an out-of-memory error while applying the public block lists stopped them from refreshing, and the Security Audit then reported **Automatic Blocking: Gateway Blocklist Empty**. The agent now restarts itself when that happens, and the restarted agent re-applies the lists.
> - **Lower memory churn in Live Traffic sampling** - The conntrack sampler reuses its read buffer and parses without allocating a string per field, which cuts how often the agent's memory is collected.
>
> To install it on the gateway, re-run your On-Site Agent install command with `--release v2.11.6-oomtest1` added. Your existing configuration is kept. When v2.11.6 ships, your server offers the upgrade as usual.

## 2.11.5

- Upgrading from upstream version 2.11.4 -> 2.11.5

> Upstream v2.11.5: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.5
>
> > **On-Site Agent update (optional; new in v2.11.5):** adds telemetry and a mitigation for an out-of-memory error on EFG and UDM-Beast class gateways while feeding Live Traffic (see **Live Traffic** below). Open **Settings - Multi-Site**, expand your Site, press **Upgrade**, and run the command for your install (on an On-Gateway Agent, **Run It for Me** runs it for you). If you updated on v2.11.5-preview3, you're set.
>
> Meet the Path Map: every Target you monitor, and the route your traffic takes to get there, on one live map. Plus your actual devices on the 3D map, a signal meter and smoother layout changes on the 2D map, Recent columns in Live Traffic, and fixes for a UniFi Express used as an Access Point, Client names, Change Control, Adaptive SQM, and the Security Audit. See the [v2.11.4 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.4), the [v2.11.3 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.3), the [v2.11.2 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.2), the [v2.11.1 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.1), and the [v2.11.0 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.0) for what's new in v2.11.0+.
>
> ## Monitoring
>
> ### Network Performance
>
> - **Path Map** - right above the **Latency & Packet Loss** charts, each Target's route drawn hop by hop across the map, lit by how that Target is doing against its own baseline. When something gets slow, you can see at a glance whether it's one destination, a transit network several of them cross, or your own ISP: routes that share a network share a line, so a problem upstream shows up on everything behind it. It follows whatever the charts are showing, WANs and time window included, and re-traces every minute while it's open (once per visit on a metered WAN).
> - **Route changes** - find out when your ISP or a transit network moves your traffic: each change is listed with the round trip before and after, and one click draws the old route next to the new one.
> - **All, Transit, and Local views** - the whole picture, just the networks between you and each Target, or a close-up of your ISP and where they hand off, with the round trip at each stop.
> - **A card on everything** - hover any Target, city, or leg of a route (or tap it on a phone) for the Targets there, then jump straight into their charts or run a traceroute in Network Tools.
> - **Improved UX around switching between Live View, ISP Health, and Network Performance** - links land on the right Targets and moment and show where you came from, the jumps back and forth keep your place, and the chart header (with the loss event stepper) stays in view on desktop.
>
> ### Live View
>
> - **Your actual devices on the 3D map** - every UniFi Device and Client now shows up as itself, sized by what it is: Access Points mounted the way you placed them on the **Signal Map**, TVs on the wall, and roofs that follow your buildings.
> - **Hide Device** - right-click anything you'd rather not see on the 3D map, like a management interface or a whole port group, and **Hidden Devices** in **Overlays** brings it back. Only your view changes.
> - **A smoother 2D map** - Clients joining, roaming, and leaving slide into place instead of jumping, and mesh APs, Device Bridges, and cellular modems set up in **Cellular Stats** carry a signal meter on their card.
> - **Cellular WANs and ISP logos** - on both maps, a cellular WAN runs from its modem to its WAN globe, with a live 5G or LTE badge when the modem is set up in **Cellular Stats**, and each globe shows your ISP's logo where UniFi Network has one.
> - **Double-click an Access Point or a cellular modem** - on both maps, to see its Clients in Wi-Fi Optimizer's **Client Stats**, or its charts in **Cellular Stats**.
> - **Fix: a UniFi Express used as an Access Point showing up as a second Gateway** (thanks @micallan17 for the report and the captures) - behind another UniFi Gateway, it was badged Gateway on **Setup**, left WAN Download and Upload blank on the Dashboard's **Live View**, and sat under the WAN globe on the map.
> - Also fixed: double-clicking a Switch or Gateway on the Dashboard's **Live View** card doing nothing (it now opens **Port Statistics** on Monitoring - Live View with that device picked); a client's rate label covering its name on the left-to-right layout when the client has a device icon; the map's timeline ignoring the time and date format setting; WAN Throughput freezing after you left Live View parked on a moment; and on the 3D map, unplaced Wi-Fi Clients of an Access Point in an outbuilding landing outside both buildings.
>
> ### Live Traffic
>
> - **Recent ↓ and Recent ↑** - each flow's data in each direction over the last 5 minutes, on the **Flows** table (summed per group when grouped) and on a client's **Live Traffic** in Client Performance. Click either one to list the busiest flows first.
> - **Fix: Live Traffic stopping with an error** - when a flow the Gateway's conntrack reads had missed came back and then ended again. Seen on a UDR7.
> - **Fix: "Reconnecting often" while Live Traffic is open on EFG and UDM-Beast class gateways** (thanks @jetlagalex for the report and the ongoing diagnosis on a UDM-Beast) - after about a day of uptime, the On-Gateway Agent hit out-of-memory errors until it was restarted by hand. It now restarts itself when that happens, and logs the detail needed to find the cause. Needs the Agent update above.
>
> ### Network Tools
>
> - **Fix: Set location on a hop also moving the routers after it** - on a hop whose replies come back late, like an MPLS hop.
> - Also fixed: some **Trace** links into Network Tools not filling in the target.
>
> ## Change Control
>
> - **Fix: a WLAN on an AP Group showing no Broadcasting APs in UniFi Network** - when Change Control created it (from the **Edit** tab or a Roll Back) on any AP Group other than All APs. **If you created one before this release, choose Group under Broadcasting APs for it in UniFi Network.**
> - **Fix: "overlaps 192.168.0.0/16, reached over the Vpn zone" in Re-address Networks** - a Firewall Policy matching a private range from the VPN or External Zone refused every pattern into that range (and a move out of it could leave addresses behind).
> - **Fix: Automatic Blocking exceptions left behind by Re-address Networks** - an exception for a Device on a moved Network stopped applying after the move.
> - **Fix: clearing a Client's name read as deleting the Client** - when the name was its only setting, and Roll Back then failed because UniFi refuses to create a Client that already exists. Clearing a name now reads and rolls back as a rename, and removing a name line in **Edit** no longer fails the Plan with "Name did not land".
> - **Fix: Client renames made in UniFi Network recorded as No admin recorded** - the Admin who made the rename now shows.
> - Also fixed: "Partial: Not applied by UniFi: PMF, Security, Security" on a new WLAN with WPA3 or 6 GHz, though the WLAN ended up exactly as planned; a renamed Access Point reading as a fix plus a regression in **Impact**; and a regenerated custom icon reading as unchanged ("Wall Server" to "Wall Server").
>
> ## Adaptive SQM
>
> - **Fix: a scheduled WAN Speed Test running during Adaptive SQM's own speed test** - when one landed on the Gateway's morning or evening Adaptive SQM test, each measured the other's load, and Adaptive SQM shaped to the wrong rate. A scheduled test now waits until the Adaptive SQM test is done.
>
> ## LAN Speed Test
>
> - **Fix: no device name on a test run from a UniFi Device** - an Access Point, Switch, or Gateway. Also fixed: the Dashboard's **LAN Speed Test** card showing 0 for a direction the test didn't run.
>
> ## Security Audit
>
> - **Fix: Acknowledge not sticking on Threat: Actively Targeted Port Forward** (thanks @Mancolt for the report) - the acknowledgement stopped matching whenever the finding's 30-day threat count changed, which is nearly every audit. It now holds until the forwarded port or its source restriction changes. **If you acknowledged it before this release, Acknowledge it once more.**
>
> ## Threat Intelligence
>
> - **Fix: a partial MaxMind GeoLite2 download shown as a success** (thanks @Optic00 for the report) - when one GeoLite2 database downloaded and the other failed, **Settings** showed the error in the green success box. It now shows as a warning naming the database that did load, and a rejected license key gets a hint that a new MaxMind license key can take a few minutes to start working.
>
> ## Fixes
>
> - **Fix: old and mismatched Client names** - a Client renamed in UniFi Network kept its old name for a few minutes in Client Performance (until a reload, if it was offline) and for good in Live Traffic History, and the Security Audit's offline Wireless Clients stayed under their Access Point's old name. Names now follow UniFi on every page: a UniFi Protect camera shows the name you gave it in Protect (and Client Performance no longer offers to rename it), and an unnamed Client in Live Traffic shows UniFi's name for it rather than its DHCP hostname.
>
> ## Installation
>
> **Windows**: Download the MSI installer below
>
> **Docker (Upgrade)**:
> ```bash
> docker compose pull && docker compose up -d
> ```
>
> **macOS** (native, recommended for accurate speed tests vs Docker Desktop):
> ```bash
> git clone https://github.com/Ozark-Connect/NetworkOptimizer.git && cd NetworkOptimizer && ./scripts/install-macos-native.sh
> # or if you already have it cloned
> cd NetworkOptimizer && git pull && ./scripts/install-macos-native.sh
> ```
>
> **Proxmox**:
> ```bash
> bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ozark-Connect/NetworkOptimizer/main/scripts/proxmox/install.sh)"
> # or if you just need to update
> pct exec <CT_ID> -- bash -c 'cd /opt/network-optimizer && docker compose pull && docker compose up -d && docker image prune -f'
> ```
>
> For other platforms (Synology, QNAP, Unraid, native Linux) or new installations, see the [Deployment Guide](https://github.com/Ozark-Connect/NetworkOptimizer/blob/main/docker/DEPLOYMENT.md).
>
> Need a hand with an install or upgrade, or something not working right? Ask on the [Network Optimizer Discord](https://discord.gg/pHrmzbBCY3). Confirmed bugs and feature requests go to [GitHub Issues](https://github.com/Ozark-Connect/NetworkOptimizer/issues).

## 2.11.4

- Upgrading from upstream version 2.11.0 -> 2.11.4

> Upstream v2.11.4: https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.4
>
> > **On-Site Agent update (optional; unchanged since v2.11.3):** skipped v2.11.3? Press **Upgrade** on your Site in **Settings - Multi-Site** for its Upstream Path Discovery fix. If you updated on v2.11.3 or v2.11.3-preview1, you're set.
>
> A fix for Automatic Blocking's public block lists cutting off streaming and other apps some of the time, traceroutes that place each hop in a city and draw the route on a map, a much smoother 2D map, and hover cards on the external addresses in Network Performance and Threat Intelligence. See the [v2.11.3 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.3), the [v2.11.2 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.2), the [v2.11.1 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.1), and the [v2.11.0 release notes](https://github.com/Ozark-Connect/NetworkOptimizer/releases/tag/v2.11.0) for what's new in v2.11.0+.
>
> ## Threat Intelligence
>
> ### Automatic Blocking
>
> - **Fix: public block lists cutting off streaming and other apps some of the time** - on a Site that blocks at the Gateway, the lists' Firewall Policies in UniFi Network also dropped the replies to connections your own Devices opened, so an app was cut off whenever its servers sat on an address an attacker list still held (cloud addresses change hands often). The Policies match new inbound connections only now, as the On-Gateway Agent's rules already did, and the ones you have are corrected within minutes of upgrading. Outbound blocking is unchanged.
> - **Hover cards on external addresses** - hover an address or host name anywhere in Threat Intelligence, the blocked sources and public block list drops, or a Web Application Firewall event's source IP for the card Live Traffic shows for a destination: the address to copy, and **Trace**.
>
> ## Monitoring
>
> ### Network Tools
>
> - **Location on each traceroute hop** - the **Traceroute Result** table shows each hop's flag, city, and country. A transit router is placed by the city its name gives (Dallas for `dllstx14`), where an IP location database would put it wherever its network is registered; other hops are placed by a hop a few ms away, or by GeoLite2 City when installed. Hover a location for where it came from.
> - **Route Map** - below the **Traceroute Result** table, the path is drawn on a map, city to city, starting from your WAN's location when its address is public, with a dotted leg where the hops in between did not answer. Click a hop to find it on the map, or a point on the map to find its hops.
> - **Set location** - when a hop is placed in the wrong city, an Admin can set the right one from the hop's row (the pin icon after its location). It applies to that address on every Site's traces, and the hops around it are placed against it; only public addresses take one.
> - **Learned locations** - a transit router one trace placed by its name or a nearby hop keeps that city on later traces that have only GeoLite2 for it, marked **Learned** in the hover.
> - **Fix: an ICMP or TCP traceroute from a Gateway over SSH ran as UDP** - and a trace whose far end never answered showed an empty table and "Did not reach target", where it now shows the hops it reached.
>
> ### Network Performance
>
> - **Hover cards on external hosts** - hover a host's chip on the chart or in the statistics table, a **Latency Targets** address, or an address in **Upstream Path Discovery** for the same card: the address to copy, and **Trace**.
> - **Fix: a Target's RTT Mean and Max reading an impossible round trip** - one corrupted ping reply can print a time of years, and it set the Target's RTT Mean and Max in the statistics table (and scaled its chart) for every window that included it. It's dropped now, whether an On-Site Agent or the server sent the ping (no Agent update needed); a value already stored stays.
>
> ### ISP Health
>
> - **Location in the hop table** - on desktop, an episode's hop table shows each hop's location, read the same way as in Network Tools (**Set location** works here too), and an open hop table now uses the full width of the event.
>
> ### Live View
>
> - **A much smoother 2D map** - it runs at a higher frame rate now, without skipping as you pan and zoom. The Dashboard's **Live View** card and the **Firmware Rollout** map get it too.
>
> ## Maps
>
> - **Scrolling past a map** - the mouse wheel zooms a map only after the pointer rests on it for a moment, or after a click, so a page scroll no longer stops at a map and zooms it. Every map has it; a fullscreen map zooms right away.
> - **Dark street map** - the **Speed / Coverage Map** and the floor plan editor use the same dark street map as the Route Map. Satellite imagery keeps its own colors.
>
> ## Wi-Fi Optimizer
>
> - **Fix: Channel Recommendation counting one neighbor's SSIDs as several interferers** - a neighbor radio broadcasting several SSIDs (hidden ones included) weighed once per SSID on its channel, and counts once now. RF Environment's **Neighboring Networks** and **Channel Density** still list each network.
> - **Fix: a radio free to move straight back into the 160 MHz channel it just left** - Channel Recommendation's soak period missed a radio that left a 160 MHz channel from any but the block's first channel (ch116 in 100-128).
> - **SSID in Client Stats** - each Client's SSID, as a sortable column in the table (on desktop) and in the Client details.
>
> ## Security Audit
>
> - **Fix: a WAN on a disabled port flagged Critical** - **Gateway Firewall: WAN Not in External Zone** flagged a WAN still assigned to a port you disabled in UniFi Network, which carries no traffic. A disabled port the Gateway still puts in the wrong Zone is still flagged.
>
> ## Fixes
>
> - **Fix: a dropdown closing right after it opened** - in Chrome and Edge, a list opened just after scrolling the page could shut on its own.
>
> ## Installation
>
> **Windows**: Download the MSI installer below
>
> **Docker (Upgrade)**:
> ```bash
> docker compose pull && docker compose up -d
> ```
>
> **macOS** (native, recommended for accurate speed tests vs Docker Desktop):
> ```bash
> git clone https://github.com/Ozark-Connect/NetworkOptimizer.git && cd NetworkOptimizer && ./scripts/install-macos-native.sh
> # or if you already have it cloned
> cd NetworkOptimizer && git pull && ./scripts/install-macos-native.sh
> ```
>
> **Proxmox**:
> ```bash
> bash -c "$(curl -fsSL https://raw.githubusercontent.com/Ozark-Connect/NetworkOptimizer/main/scripts/proxmox/install.sh)"
> # or if you just need to update
> pct exec <CT_ID> -- bash -c 'cd /opt/network-optimizer && docker compose pull && docker compose up -d && docker image prune -f'
> ```
>
> For other platforms (Synology, QNAP, Unraid, native Linux) or new installations, see the [Deployment Guide](https://github.com/Ozark-Connect/NetworkOptimizer/blob/main/docker/DEPLOYMENT.md).
>
> Need a hand with an install or upgrade, or something not working right? Ask on the [Network Optimizer Discord](https://discord.gg/pHrmzbBCY3). Confirmed bugs and feature requests go to [GitHub Issues](https://github.com/Ozark-Connect/NetworkOptimizer/issues).
>
> 3 older upstream releases omitted.

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
