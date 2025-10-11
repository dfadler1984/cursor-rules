---
archived: true
archivedOn: 2025-10-11
source: docs/projects/assistant-learning-hard-gate/erd.md
---

# Engineering Requirements Document — Assistant Learning: Automatic Local Logging (Archived)

---

status: skipped
owner: rules-maintainers

---

# Engineering Requirements Document — Assistant Learning: Automatic Local Logging

Mode: Lite

## 1. Introduction/Overview

Enable automatic, local Assistant Learning Protocol (ALP) logs across the repository so reflective entries are captured at key moments (routing corrections, misunderstandings, TDD Red/Green, task completion) without coupling to PRs/CI.

## 2. Goals/Objectives

- Automatically write ALP entries for specified triggers during local sessions.
- Keep logs redacted and portable; provide a docs fallback path.

## 3. Functional Requirements

1. Triggers (minimum): Routing Corrected, Misunderstanding Resolved, TDD Red, TDD Green, Task Completed.
2. Auto-write behavior: On any trigger, the assistant writes an ALP entry locally without per-event consent.
3. Destination: Configurable via `.cursor/config.json` (`logDir`), default `assistant-logs/`; fallback `docs/assistant-learning-logs/`.
4. Safeguards: mandatory redaction; concise entries; size/rate limits to avoid noise.

## 4. Non-Functional Requirements

- No secrets; use redaction helper.
- Minimal friction; script helpers should be easy to use.
- Clear, minimal messages and remediation steps on failures (e.g., fallback path usage).

## 5. Acceptance

- During sessions, when a trigger occurs, a new ALP entry is created locally under the configured log directory with the required schema.

## 6. Open Questions

- Should we expand optional triggers beyond the minimum set?

## 7. Scripts

Primary helpers and their purposes:

- `.cursor/scripts/alp-logger.sh`: Write logs with primary/fallback destinations; build filenames; redact if possible.
- `.cursor/scripts/alp-redaction.sh`: Redact secrets and auth headers from log content.
- `.cursor/scripts/alp-aliases.sh`: Sourceable `alp_log` that respects env/config and delegates to the logger.
- `.cursor/scripts/alp-smoke.sh`: Smoke test to verify the logging pipeline end-to-end.
- `.cursor/scripts/alp-template.sh`: Format a concise ALP entry from CLI flags; supports `[rule-candidate]` tagging.
- `.cursor/scripts/alp-triggers.sh`: Emit standard logs for common triggers (tdd-fix, intent-resolution, rule-fix, task-completion, mcp-recovery).
- `.cursor/scripts/alp-archive.sh`: Mark logs as reviewed and archive reviewed logs to `_archived/YYYY/MM/`, emitting a summary of learnings.
- `.cursor/scripts/alp-aggregate.sh`: Scan logs and produce a summary aggregating candidate rule counts.

## 9. Periodic Review & Archival

Policy (threshold-based):

- When there are >= 10 unarchived ALP log files in the configured `logDir` (default `assistant-logs/`), generate a summary of learnings and then archive those logs.

Procedure:

1. Summarize
   - Run `.cursor/scripts/alp-aggregate.sh` to scan logs and produce a summary file (path is printed on stdout, defaults under `docs/assistant-learning-logs/summary-*.md`).
   - Review the summary and record actionable improvement suggestions (e.g., rule candidates, wording fixes, automation ideas). Convert accepted items into tasks or rule updates.
2. Mark as Reviewed
   - For each log included in the summary, mark it reviewed:
     - `.cursor/scripts/alp-archive.sh mark <path/to/log-YYYY-MM-DDT...>.md` (idempotent; appends `Reviewed: YYYY-MM-DD`).
3. Archive reviewed logs
   - Archive reviewed logs to `_archived/YYYY/MM/` and emit an archive summary:
     - `.cursor/scripts/alp-archive.sh archive`

Notes:

- Counting unarchived logs: count `log-*.md` under `logDir` excluding the `_archived/` subfolder.
- Improvement suggestions should be captured in follow-up issues/tasks or reflected directly in rule edits (with `lastReviewed` updated).

## 7. Investigation: Taskmaster Self‑Improve Rule

- Target reference: `~/Development/claude-task-master/.cursor/rules/self_improve.mdc`
- Purpose: Perform an in‑depth review of how Taskmaster operationalizes self‑improvement, then contrast with our ALP to identify enforcement mechanisms we lack.
- Focus areas:
  - How triggers are defined and surfaced (routing corrections, repeated patterns, test signals)
  - Where enforcement exists (checklists, hard gates, CI hooks) vs guidance only
  - How logs are structured and kept actionable (links, next steps, owners)
- Our observed failures to analyze:
  - High‑signal moments (confusion, routing corrections, TDD Red/Green) were not captured as logs
  - No hard gate tying scope (rules/scripts/docs changes) → required ALP entries
  - No PR‑template checklist or CI check ensured ALP coverage before merge
- Deliverables:
  - A short comparison note (what Taskmaster does vs our current ALP)
  - Proposed hard‑gate wording and minimal CI/script to enforce it
  - PR‑template checklist items and examples

## 8. Link updates after rename

We renamed the rule file from `logging-protocol.mdc` to `assistant-learning.mdc`. Update references across the repo (completed):

- Replace references to `.cursor/rules/logging-protocol.mdc` with `.cursor/rules/assistant-learning.mdc` in:
  - `README.md`
  - `docs/projects/ai-workflow-integration/erd.md`
  - `docs/projects/ai-workflow-integration/tasks.md`
  - `docs/projects/ai-workflow-integration/discussions.md`
- Any other docs mentioning `logging-protocol.mdc` (none remaining)

Notes:

- Keep links descriptive (e.g., “Assistant Learning rule”).
- Validate links with `.cursor/scripts/links-check.sh` (advisory; no PR/CI coupling).
