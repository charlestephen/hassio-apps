# Changelog

## 0.94.0

- Upgrading from upstream version 0.93.0-2 -> 0.94.0

> Upstream 0.94.0: https://github.com/activepieces/activepieces/releases/tag/0.94.0
>
> ## Highlights
>
> * **Process in Batches** – a new step that splits a long list into batches, runs each batch as its own run in parallel, and continues when every batch has finished. [Docs](https://www.activepieces.com/docs/flows/process-in-batches)
> * **Faster code steps** – Deno code steps are much quicker. In our test, a loop of 300 small code steps went from about 118 ms to about 50 ms per step.
> * **Workers stop gracefully** – when a worker stops for a deploy or a scale-in, it now finishes the flows it is running instead of cutting them off and restarting them from step 1.
> * **LiteLLM as an AI provider** – connect your LiteLLM proxy, and its models are discovered and their spend tracked. The AI provider dialog is redesigned.
> * **Live tables** – an open table updates as soon as someone else, a flow or the AI changes it.
> * **Next run on the toggle** – a flow tells you when it runs next, right next to its on/off toggle.
> * **Chat memory import** – new chat users can bring their memory from ChatGPT or Claude.
> * **Pieces** – new pieces for Sage Intacct, Datalab, Jira Service Management and Salla; a New Button Click trigger for Slack; AI agent actions for ActiveCampaign, beehiiv, Buffer, Fireflies, Microsoft Dynamics CRM, Spotify, Stability AI, YouTrack and more; and triggers that no longer miss or repeat events in Google Sheets, Google Calendar, Google Drive, HubSpot, Postgres, RSS, Airtable and others.
>
> ## Upgrade notes
>
> * **Pieces** – several pieces change their behaviour or output in this release (Google Sheets, Gmail, HubSpot, Postgres, RSS and others). Read the [Breaking Changes](https://www.activepieces.com/docs/install/reference/breaking-changes) page before you upgrade.
> * **Stopping workers** – a stopping worker now waits for its running flows, up to `AP_FLOW_TIMEOUT_SECONDS` + 105 seconds. The bundled `docker-compose.yml` sets `stop_grace_period: 705s` and the Helm chart sets `terminationGracePeriodSeconds`. If you run workers another way, give them the same grace period (for `docker run`, `--stop-timeout 705`), or runs are still cut off when a worker stops (#17579).
> * **Code steps** – new and edited code steps always run on Deno. A code step that was moved back to the legacy runtime keeps it until someone edits the step; the edit moves it to Deno (#17686).
>
> ## All changes
>
> ### 🔌 Pieces
>
> * fix(pieces): Google Gemini model list now shows Gemini 3 and newer text models (#17774) @majewskibartosz
> * feat(slack): New Button Click trigger (#17780) @OdaiAhmed99, @AdamSelene, @claude
> * feat(sage-intacct): new piece: contacts, customers, vendors, invoices, bills, payments, lookups (#17770) @OdaiAhmed99
> * fix(okta): new event removes its Okta event hook when the flow is turned off (#17737) @sanket-a11y, @claude
> * fix(wrike): new task, folder and subtask triggers fire once per matching event (#17732) @sanket-a11y, @claude
> * fix(google-sheets): row triggers stop sending duplicate, blank and lost rows; header-row fixes (#17454) @OdaiAhmed99
> * fix(schedule): show real GMT offsets in the timezone dropdown (#17729) @sanket-a11y, @claude
> * fix(salesforce): New Case in Queue runs once when a Case re-enters the queue between checks (#17725) @sanket-a11y, @claude
> * feat(http-oauth2): make Scopes optional on the HTTP (OAuth2) connection (#17626) @OdaiAhmed99
> * fix(slack): hide the self-hosted setup notes on Cloud (#17694) @othmanemad, @claude
> * fix(microsoft-excel-365): new row in table uses column names, append rows to a table loads values (#17657) @kishanprmr
> * fix(microsoft-excel-365): worksheets with # in the name work in every step (#17656) @kishanprmr
> * fix(imap): new email polls by arrival time, downloads only new emails, keeps emails on attachment failure (#17654) @kishanprmr
> * fix(discord): new member on big servers, message-only channel dropdown, all servers listed (#17651) @kishanprmr
> * fix(microsoft-todo): new list trigger fires whatever order graph returns lists in (#17633) @kishanprmr
> * fix(microsoft-outlook): one oversized attachment no longer fails New Attachment (#17631) @kishanprmr
> * fix(apify): stop actor log streaming from crashing the engine (#17540) [@box-activepieces[bot]](https://github.com/apps/box-activepieces), @claude, @kishanprmr
> * feat(google-cloud-storage): add Workload Identity Federation (OIDC) auth (#16592) @fabio-kozlowski, @claude, @kishanprmr
> * feat(ai): litellm provider with model discovery, spend tracking and image glue (#17558) @Louai-Zokerburg
> * fix(slack): drop requests older than five minutes on arrival (#17529) @lina-alomari
> * feat(fireflies-ai): let AI agents search, read and manage Fireflies meetings (#17322) @OdaiAhmed99
> * fix(todoist): send UTC windows and give Task Completed a real sample (#17394) @OdaiAhmed99
> * fix(google-sheets): keep row snapshots when a live flow is republished (#17404) @Louai-Zokerburg
> * feat(fireberry): add AI agent actions and output schemas, fix writes and trigger (#17122) @OdaiAhmed99
> * feat(jira-data-center): clearer step forms, a Transition Issue action and triggers that no longer skip issues (#17488) @ibrahim-abuznaid, @claude
> * fix(salla): accept mapped numeric ids and stop silent drops (#17484) @ibrahim-abuznaid, @claude
> * feat(microsoft-dynamics-crm): manage contacts, accounts, leads and opportunities with new triggers and AI tools (#17485) @OdaiAhmed99
> * feat(datalab): convert, extract, split and fill documents with Datalab from flows and AI agents (#17486) @ibrahim-abuznaid, @claude
> * feat(jira-service-management): manage service desk requests on Jira Cloud and Data Center (#17483) @ibrahim-abuznaid, @claude
> * fix(salla): update orders, add customers and hide products without changing the wrong records (#17460) @ibrahim-abuznaid, @claude
> * feat(salla): run Salla store orders, products, customers and coupons from flows and AI agents, with real-time store triggers (#17440) @ibrahim-abuznaid, @claude
> * feat(manychat): add AI actions, output schemas and fix Send Content auth (#17418) @OdaiAhmed99
> * fix(airtable): fire view entrants, survive Trigger Field renames, load samples from quiet tables (#17397) @OdaiAhmed99
> * fix(postgres): run New Row once per row, keep tied rows, compare timestamps in the database (#17355) @OdaiAhmed99
> * fix(rss): RSS triggers fire each new item once per feed, even when feeds are slow, failing, huge or oldest-first (#17313) @OdaiAhmed99
> * fix(hubspot): poll CRM search oldest first and stop missing changes, stage entries, list joins (#17391) @OdaiAhmed99
> * fix(google-calendar): Google Calendar triggers fire once per event, catch up after late checks and no longer stall or miss events (#17315) @OdaiAhmed99
> * fix(wordpress): new post fires once on any site timezone, for backdated posts and bursts (#17392) @OdaiAhmed99
> * fix(youtube): New Video stops re-firing old videos and follows channel changes (#17393) @OdaiAhmed99
> * fix(apitable): load the newest records as New Record sample data, not only the last 24 hours (#17395) @OdaiAhmed99
> * fix(google-drive): wait between download retries and let Test page past an empty first page (#17450) @OdaiAhmed99
> * fix(gmail): stop leaking proxy credentials in New Email and Send Email output (#17452) @OdaiAhmed99
> * fix(google-docs): let New Document Test page past an empty first page (#17451) @OdaiAhmed99
> * fix(google-drive): file triggers no longer drop, stall or repeat on failed downloads, partial searches or large backlogs (#17314) @OdaiAhmed99
> * fix(google-sheets): row triggers match rows by content, quote tab names, fix Get Next Rows (#17356) @OdaiAhmed99
> * fix(google-tasks): let new task ignore edits with run on (#17330) @OdaiAhmed99
> * feat(google-docs): fill a copy of a template and see which placeholders were filled (#17410) @ibrahim-abuznaid, @claude
> * fix(github): stop Update Issue (Agent) clearing labels and assignees (#17409) @ibrahim-abuznaid, @claude
> * feat(beehiiv): manage subscribers, tags, segments and posts from agents (#17368) @OdaiAhmed99
> * fix(google-forms): let New Response ignore edited responses (Run on) (#17329) @OdaiAhmed99
> * feat(buffer): create, edit and schedule posts across channels from agents (#17369) @OdaiAhmed99
> * feat(stability-ai): generate, edit, upscale and restyle images with Stable Image and SD 3.5 (#17302) @OdaiAhmed99
> * feat(youtrack): manage projects, sprints, work items and articles from agents (#17234) @OdaiAhmed99
> * fix(http): let the request timeout cover connecting and keep the fetch error cause (#17320) @Louai-Zokerburg
> * fix(flows): list polling trigger test samples newest first, in the order the trigger returned them (#17321) @Louai-Zokerburg
> * feat(spotify): control playback, browse the catalog and manage playlists from agents (#17235) @OdaiAhmed99
> * feat(activecampaign): manage contacts, deals, tasks and automations from AI agents and flows (#17303) @OdaiAhmed99
> * fix(slack): handle a failed forward of an approval button click (#17262) @kishanprmr, @claude
>
> ### ⛓️‍💥 Breaking Changes
>
> * fix(google-sheets): row triggers stop sending duplicate, blank and lost rows; header-row fixes (#17454) @OdaiAhmed99
> * feat(fireflies-ai): let AI agents search, read and manage Fireflies meetings (#17322) @OdaiAhmed99
> * feat(fireberry): add AI agent actions and output schemas, fix writes and trigger (#17122) @OdaiAhmed99
> * feat(microsoft-dynamics-crm): manage contacts, accounts, leads and opportunities with new triggers and AI tools (#17485) @OdaiAhmed99
> * feat(manychat): add AI actions, output schemas and fix Send Content auth (#17418) @OdaiAhmed99
> * fix(postgres): run New Row once per row, keep tied rows, compare timestamps in the database (#17355) @OdaiAhmed99
> * fix(rss): RSS triggers fire each new item once per feed, even when feeds are slow, failing, huge or oldest-first (#17313) @OdaiAhmed99
> * fix(hubspot): poll CRM search oldest first and stop missing changes, stage entries, list joins (#17391) @OdaiAhmed99
> * fix(google-calendar): Google Calendar triggers fire once per event, catch up after late checks and no longer stall or miss events (#17315) @OdaiAhmed99
> * fix(gmail): stop leaking proxy credentials in New Email and Send Email output (#17452) @OdaiAhmed99
> * fix(google-drive): file triggers no longer drop, stall or repeat on failed downloads, partial searches or large backlogs (#17314) @OdaiAhmed99
> * fix(google-sheets): row triggers match rows by content, quote tab names, fix Get Next Rows (#17356) @OdaiAhmed99
> * fix(google-tasks): let new task ignore edits with run on (#17330) @OdaiAhmed99
> * fix(github): stop Update Issue (Agent) clearing labels and assignees (#17409) @ibrahim-abuznaid, @claude
> * feat(beehiiv): manage subscribers, tags, segments and posts from agents (#17368) @OdaiAhmed99
> …

## 0.93.0-1

- Initial release.
- Activepieces `0.93.0`: thin wrapper on the official Debian-based image,
  `exec`s upstream's own entrypoint (`tini -- docker-entrypoint.sh`)
  unchanged, which picks `WORKER_AND_APP` mode by default (server + worker
  in one process, confirmed from reading that entrypoint script directly).
- Runs fully standalone by default: `db_type: pglite` (embedded database)
  and `redis_type: memory` (embedded queue), matching upstream's own
  standalone configuration path — no external dependencies required.
  Setting `db_type: postgres`/`redis_type: standalone` plus the matching
  host/port options wires this repository's own PostgreSQL/Valkey apps in
  instead.
- `frontend_url` required at runtime (wrapper exits with a clear error if
  empty); `encryption_key`/`jwt_secret` auto-generate and persist under
  `/data` on first start if left blank, matching the Authentik/Pocket ID
  apps' own pattern for secrets.
- `execution_mode` exposes only the two Activepieces sandbox modes that need
  no special container privileges (`UNSANDBOXED`, `SANDBOX_CODE_ONLY`); the
  two that need `CAP_SYS_ADMIN`/privileged mode are left to `env_vars`.
- Ships an AppArmor profile (`apparmor.txt`).
- `icon.png`/`logo.png` use upstream's own GitHub organization avatar.

## 0.93.0-2

- Fixed a first-boot bug caught by testing on a real Supervisor: the
  wrapper's `log()` helper wrote to stdout, and `gen_secret()` called it
  right before printing the secret — so on first generation only,
  `KEY="$(gen_secret ...)"` captured the log line *and* the secret
  together, corrupting `AP_ENCRYPTION_KEY`/`AP_JWT_SECRET` and failing
  Activepieces' own startup validation (`AP_ENCRYPTION_KEY is missing or
  invalid`). The same bug as Checkmate's — both wrappers used the same
  `gen_secret()` pattern. Fixed by sending `log()` output to stderr.
