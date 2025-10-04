## Tasks — ERD: Assistant Learning Protocol (ALP)

## Relevant Files

- `.cursor/config.json`
  - ALP config (`assistantLearning`), feature flag `assistant-learning-protocol`, default `logDir`.
- `docs/assistant-learning-logs/`
  - Local fallback directory for logs and summaries.
- `.cursor/scripts/alp-logger.sh`
  - Shell logger utilities (filename, write, writable, fallback).
- `.cursor/scripts/alp-logger.test.sh`
  - Shell tests for logger utilities.
- `.cursor/scripts/` (future) — optional shell helper for redaction if needed.
- `.cursor/scripts/` (future) — optional shell helpers for template formatting if needed.
- `.cursor/scripts/alp-template.sh`
  - Shell template formatter for canonical log entries.
- `.cursor/scripts/alp-template.test.sh`
  - Shell tests for the template formatter.
- `.cursor/scripts/alp-redaction.sh`
  - Shell redaction filter for headers and tokens.
- `.cursor/scripts/alp-redaction.test.sh`
  - Shell tests for the redaction filter.
- `.github/workflows/alp-aggregate.yml` (optional)
  - Scheduled weekly aggregator run to publish summaries.
- `README.md`
  - Link to ALP and operator checklist.
- `docs/projects/assistant-learning/erd.md`
  - Source ERD; ensure cross-links and worked examples.

### Notes

- TDD-first: for each source created, create/adjust the colocated `*.spec.ts` first to fail, then implement to pass, then refactor.
- Prefer pure functions for formatting/redaction/selection; isolate I/O in `logger.ts` and CLI.
- Keep entries minimal and redacted; never log secrets or authorization headers.

## Tasks

- [x] 1.0 Implement ALP configuration and feature flag in `.cursor/config.json`

  - [x] 1.1 Add `assistantLearning` section with `persona`, `autoTriggers`, `backends`, and optional `logDir`.
  - [x] 1.2 Add global feature flag `assistant-learning-protocol` (boolean) and read path.
  - [x] 1.3 Add config loader (pure) returning defaults when keys missing.
  - [x] 1.4 Spec: config loader returns expected merged config; respects overrides.

- [x] 2.0 Build local logging adapter with fallback directory and UTC filenames

  - [x] 2.1 Implement `writeLocal` that ensures directory, writes file atomically.
  - [x] 2.2 Use UTC ISO8601 in filename: `log-<ISO>-<short>.md`.
  - [x] 2.3 Implement `isWritable` and fallback to `docs/assistant-learning-logs/`.
  - [x] 2.4 Spec: fallback occurs when primary not writable; content integrity verified.

- [x] 3.0 Implement redaction layer and canonical log template generator

  - [x] 3.1 Implement `redactSensitive(content)` to remove tokens/keys and headers.
  - [x] 3.2 Implement `formatEntry(entry)` using canonical template.
  - [x] 3.3 Spec: redaction before/after cases; template contains all fields.

- [x] 4.0 Integrate deterministic triggers across flows

  - [x] 4.1 Add trigger helpers: `onTddFix`, `onIntentResolution`, `onRuleFix`, `onTaskCompletion`, `onMcpRecovery`.
  - [x] 4.2 Each helper builds context and calls logger if feature flag enabled.
  - [x] 4.3 Spec: helpers no-op when disabled; emit when enabled.

- [ ] 5.0 Add optional MCP backends (Google Docs, Confluence) gated by config — DEFERRED

  - [ ] 5.1 (Deferred) Add optional `writeGoogle`/`writeConfluence` deps, disabled by default.
  - [ ] 5.2 (Deferred) Validate config gating prevents remote writes unless enabled.
  - [ ] 5.3 (Deferred) Spec: remote writers not invoked by default; invoked when enabled.

- [x] 6.0 Build aggregator CLI to summarize logs and propose `[rule-candidate]` updates

  - [x] 6.1 Implement glob discovery across primary and fallback directories.
  - [x] 6.2 Parse entries, count, extract rule candidates and themes.
  - [x] 6.3 Emit summary file to `docs/assistant-learning-logs/summary-<ISO>.md`.
  - [x] 6.4 Spec: aggregation contract (counts, candidates, examples, suggestions).

- [x] 7.0 Document operator workflow and worked examples; link from `README.md`

  - [x] 7.1 Add operator checklist at ERD top and ensure ≤ 15 lines.
  - [x] 7.2 Add worked examples per trigger in ERD.
  - [x] 7.3 Add `README.md` link to ALP and logs directory.

- [x] 8.0 Plan rollout and observability (cadence, owners, metrics, summary publishing)
  - [x] 8.1 Define owners and backups; set +14d target.
  - [x] 8.2 Choose aggregator cadence (weekly/bi-weekly) and enable optional workflow.
  - [x] 8.3 Track success metrics and add minimal runbook.
