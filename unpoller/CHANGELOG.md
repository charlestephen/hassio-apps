# Changelog

## 5.9.4

- First release: UnPoller v5.9.4.

## 5.9.4-1

- Add timezone data, so the timezone Home Assistant passes in is applied instead of logging "unknown time zone".

## 5.9.4-2

- Forward SIGTERM to UnPoller and exit 0 when it stops. UnPoller exits 143 on SIGTERM, which the Supervisor reports as an error after every stop.
