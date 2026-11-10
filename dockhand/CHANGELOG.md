# Changelog

## 1.0.57

- First release: Dockhand 1.0.57 using the PostgreSQL app for its database.

## 1.0.57-1

- Forward SIGTERM to the Dockhand entrypoint and exit 0 when it stops. Node exits 143 on SIGTERM, which the Supervisor reports as an error after every stop.
