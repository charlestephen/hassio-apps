# Maintainer notification guidance

In-repo CI is tuned to open fewer Actions runs and check contexts (scoped
Trivy after builds, one Hadolint job, one Build dispatch from Track Upstream).
GitHub still emails you for repo activity based on **your** notification
settings — workflows cannot turn those off.

## Stop Actions email floods

1. Open [Notification settings](https://github.com/settings/notifications).
2. Under **Actions**, choose **Send notifications for failed workflows only**
   (or turn Actions email off if you rely on Slack / the Actions tab).
3. For this repo specifically: open the repo → **Watch** → **Custom**, and
   leave **Actions** unchecked unless you want every run in your inbox.
   Prefer **Issues** / **Pull requests** (and Slack for CI failures) instead
   of watching **All Activity**.

Slack CI alerts (`.github/workflows/slack.yml`) already post only for Build
and Track Upstream on `main`, with a failure cooldown — use that channel as
the pager, not email.

## What this repo does *not* do

- No `actions/github-script` issue/PR comment bots
- No CI-created issues or `@`mentions
- Trivy does not upload SARIF (avoids code-scanning reopen spam)

If email returns after a quiet period, check for a new Watch custom setting
or a temporary switch back to “All Activity,” not a workflow permissions
change.
