# Changelog

## 5.9.5

- Upgrading from upstream version 5.9.4-2 -> 5.9.5

> Upstream v5.9.5: https://github.com/unpoller/unpoller/releases/tag/v5.9.5
>
> ## Changelog
> * 27f37138504d51b92a6582a8bdeb811faff05874 fix(promunifi): export PDU outlet relay_state and cycle_enabled
> * 3d340d88a960f83bbf5c1424ab086882a22eaab5 build(deps): bump the all group with 3 updates
> * e18dfb6424c45b1dd217098c8fce078a6ede52f3 build(deps): bump docker/login-action

## 5.9.4

- First release: UnPoller v5.9.4.

## 5.9.4-1

- Add timezone data, so the timezone Home Assistant passes in is applied instead of logging "unknown time zone".

## 5.9.4-2

- Forward SIGTERM to UnPoller and exit 0 when it stops. UnPoller exits 143 on SIGTERM, which the Supervisor reports as an error after every stop.
