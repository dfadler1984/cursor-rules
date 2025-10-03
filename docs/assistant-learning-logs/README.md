# Assistant Learning Logs

This folder contains public/fallback summaries of assistant learning logs.

- Default private logs directory: `assistant-logs/`
- Fallback/public directory: `docs/assistant-learning-logs/`
- Config override: `.cursor/config.json` key `logDir` or env `ASSISTANT_LOG_DIR`

## How logs are written

- Alias: source `.cursor/scripts/alp-aliases.sh` and use `alp_log` with a short name, piping a body on stdin.
- Script: `.cursor/scripts/alp-logger.sh write-with-fallback <destDir> <short-name>` reads the body from stdin, attempts to write to `<destDir>`, and falls back to this folder if the primary destination is not writable.
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

Behavior:

- Reviewed logs are moved to `<logDir>/_archived/YYYY/MM/` and appended with `Archived: <ISO>`.
- Unreviewed logs remain in place.
