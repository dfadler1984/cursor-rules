# Assistant Learning Logs

This folder contains public/fallback summaries of assistant learning logs.

- Default private logs directory: `assistant-logs/`
- Fallback/public directory: `docs/assistant-learning-logs/`
- Config override: `.cursor/config.json` key `logDir` or env `ASSISTANT_LOG_DIR`

## How logs are written

- Alias: source `.cursor/scripts/alp-aliases.sh` and use `alp_log` with a short name, piping a body on stdin.
- Script: `.cursor/scripts/alp-logger.sh write-with-fallback <destDir> <short-name>` reads the body from stdin, attempts to write to `<destDir>`, and falls back to this folder if the primary destination is not writable.
- Status format: `ALP: <Event> — <path>` when a log is written; otherwise `ALP: none — <reason>`. Reasons: `no-trigger`, `duplicate-suppressed`, `batched-under:<event>`.
- Example (heredoc):

```bash
.cursor/scripts/alp-logger.sh write-with-fallback assistant-logs 'alp-update' <<'BODY'
Timestamp: 2025-10-10T00:00:00Z
Event: Task Completed
Owner: alp-logging
What Changed: Updated ALP rules and docs per ERD.
Next Step: Add acceptance examples and finalize TBD item.
Links: .cursor/rules/assistant-behavior.mdc, .cursor/rules/assistant-learning.mdc
Learning: Status formats and fallback reasons improve clarity and safety.
BODY
```

- Redaction: If `.cursor/scripts/alp-redaction.sh` exists and succeeds, content is redacted before writing.

## Smoke test

Run the smoke test to verify logging end-to-end:

```bash
.cursor/scripts/alp-smoke.sh
```

Expected output is a path like:

```
assistant-logs/log-<ISO>-alp-smoke.md
```

If the private directory is unavailable, the file will be created here under `docs/assistant-learning-logs/`.

## Reviewed and Archival

- Mark a log as reviewed by appending a line `Reviewed: YYYY-MM-DD` (UTC) at the end.
- Use the archiver to move reviewed logs into a date-based folder:

```bash
.cursor/scripts/alp-archive.sh mark assistant-logs/log-<ISO>-<short>.md --date 2025-10-03
.cursor/scripts/alp-archive.sh archive # uses ASSISTANT_LOG_DIR or .cursor/config.json logDir or ./assistant-logs
```

## Aggregate summary (weekly)

- Produce a summary of assistant learnings and `[rule-candidate]` counts:

```bash
.cursor/scripts/alp-aggregate.sh
```

Expected output path:

```
docs/assistant-learning-logs/summary-<ISO>.md
```

## Examples by trigger (with status lines)

- Task Completed

Body:

```
Timestamp: 2025-10-10T00:00:00Z
Event: Task Completed
Owner: alp-logging
What Changed: Updated ALP rules and docs per ERD.
Next Step: Resolve TBD for tool-category switch guidance.
Links: .cursor/rules/assistant-behavior.mdc, .cursor/rules/assistant-learning.mdc
Learning: Status formats and fallback reasons improve clarity and safety.
```

Status: `ALP: Task Completed — assistant-logs/log-<ISO>-alp-logging.md`

- TDD Red → TDD Green

Status (Red): `ALP: TDD Red — assistant-logs/log-<ISO>-tdd-red.md`

Status (Green): `ALP: TDD Green — assistant-logs/log-<ISO>-tdd-green.md`

## Troubleshooting

- If primary write fails: the script attempts fallback to `docs/assistant-learning-logs/`. Include one line in the body noting the fallback reason.
- Windows: use WSL or Git Bash. Configure `logDir` in `.cursor/config.json` if needed.

## Execution notes

- If a script lacks executable permission, invoke via `bash`:

```bash
bash .cursor/scripts/alp-logger.sh write-with-fallback assistant-logs 'alp-quick' <<<'Timestamp: 2025-10-10T00:00:00Z
Event: Task Completed
Owner: alp-logging
What Changed: Minimal log via bash invocation.
Next Step: N/A
Links: docs/assistant-learning-logs/README.md
Learning: Use bash invocation when exec bit is missing.'
```

Behavior:

- Reviewed logs are moved to `<logDir>/_archived/YYYY/MM/` and appended with `Archived: <ISO>`.
- Unreviewed logs remain in place.
