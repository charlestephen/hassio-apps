# Speedtest Tracker

Thin Home Assistant wrapper around the LinuxServer.io
[Speedtest Tracker](https://github.com/alexjustesen/speedtest-tracker) image
(`1.15.1`). It runs scheduled Ookla speed tests and keeps the history in the
PostgreSQL app from this repository.

## Quick start

1. Install and start the **PostgreSQL** app.
2. Install **Speedtest Tracker**.
3. Set **Database password**. To let the app create its database and login, also
   set **PostgreSQL admin password** (the `postgres` password of the PostgreSQL
   app). Without it, the database and login must already exist.
4. Start the app and open the Web UI on port `8088`.
5. Sign in with `admin@example.com` and the password `password`, then change
   both from the profile page.

## Database

The app always uses PostgreSQL. With the admin password set, every start creates
or updates the login, creates the database when it is missing, makes the login
its owner and grants it rights on the `public` schema.

## Options

| Option | Variable | Notes |
| --- | --- | --- |
| Database host / port / name / user / password | `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` | `DB_CONNECTION` is always `pgsql`. |
| App URL | `APP_URL` | Set it behind a reverse proxy. |
| App key | `APP_KEY` | Generated on first start when empty and kept in `/config/.app_key`. Back it up. |
| Test schedule | `SPEEDTEST_SCHEDULE` | Cron expression. |
| Test servers | `SPEEDTEST_SERVERS` | Comma-separated Ookla server IDs. |
| Timezone | `APP_TIMEZONE`, `TZ` | |

## Extra environment variables

The box at the bottom of the options adds any other variable, for example
`PRUNE_RESULTS_OLDER_THAN=30`. Rows marked secret stay masked in the UI and the
log. These are applied last, so they override the options above.

## Data

Results live in PostgreSQL. The app config folder (`/config`, host path
`/addon_configs/<repository>_speedtest-tracker`) holds the app key, PHP settings
and logs.
