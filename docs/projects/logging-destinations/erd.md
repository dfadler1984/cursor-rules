---
---

---
title: ERD — Logging Destinations and Publication Strategy
status: Draft
owners:
  - assistant-learning
last_updated: 2025-10-02
related:
  - docs/projects/deterministic-outputs/erd.md
  - docs/projects/assistant-learning/erd.md
  - .cursor/scripts/alp-logger.sh
  - .cursor/scripts/alp-redaction.sh
  - .cursor/config.json
---

Mode: Full

### Purpose

Define how and where assistant learning logs are stored, protected, and published. Clarify the contract between the private working directory (`assistant-logs/`) and the public/fallback directory (`docs/assistant-learning-logs/`), including configuration, privacy, and acceptance criteria.

### Problem Statement

We need a predictable, configurable logging destination policy that balances developer ergonomics (high‑churn, raw logs) with safety (privacy, secrets) and visibility (curated, shareable summaries). Today both `assistant-logs/` and `docs/assistant-learning-logs/` exist; teams need clear guidance on which is used when, how to configure overrides, and how to promote content safely.

### Goals

- Establish a single source of truth for where logs are written by default and when to fall back.
- Provide a safe path to publicly share curated learnings without leaking sensitive data.
- Ensure the policy is scriptable, deterministic, and configurable per repo via `.cursor/config.json`.
- Minimize repository noise (avoid committing high‑churn raw logs) while keeping a simple escape hatch.

### Non‑Goals

- Building a full log viewer UI.
- Implementing long‑term archival or retention beyond simple rotation guidance.
- Redefining the log schema beyond file naming and basic front matter.

### Stakeholders

- Repository owners and maintainers
- Contributors using the Assistant Learning Logging Protocol
- Security reviewers

### Definitions

- Private logs directory: `assistant-logs/` (default destination; intended to be git‑ignored)
- Public/fallback directory: `docs/assistant-learning-logs/` (committed, human‑readable summaries)
- Config: `.cursor/config.json` key `logDir` overriding the default destination

### Functional Requirements

1. Default Destination

   - If no override is present, logs are written to `assistant-logs/`.
   - Directory should be treated as private and typically git‑ignored to prevent accidental publication of raw content.

2. Configurable Override

   - If `.cursor/config.json` contains a `logDir` value, logs are written there instead.
   - Override path may be relative to the repository root or absolute; relative is preferred.

3. Safe Fallback

   - If the selected destination is not writable, the system falls back to `docs/assistant-learning-logs/`.
   - Fallback writes must succeed without requiring additional configuration.

4. File Naming & Format

   - Files must be named `log-<ISO8601>-<short>.md`, where `<short>` is 3–5 words, lowercase, hyphenated.
   - Minimal front matter or a header section includes timestamp and event type (e.g., TDD Red/Green, Completed Task, Rule Added).

5. Redaction & Privacy

   - All writes pass through a redaction step to remove secret‑like values.
   - Redaction script: `.cursor/scripts/alp-redaction.sh`.

6. Logging Script

   - Primary interface: `.cursor/scripts/alp-logger.sh write-with-fallback <dest> <body>`.
   - The script resolves `logDir` → attempts write → falls back on failure → exits non‑zero if both destinations fail.

7. Promotion Path
   - Curated summaries can be promoted to `docs/assistant-learning-logs/` for visibility (e.g., weekly summaries).
   - Promotion should use redaction and a concise format suitable for docs.

### Non‑Functional Requirements

- Security: Prefer private storage for raw logs; publish only curated content.
- Performance: Writes are lightweight shell operations; no heavy dependencies.
- Maintainability: Single script path for writes; minimal config surface.
- Determinism: Given the same config and environment, destination selection is predictable.

### Operational Policy

- `assistant-logs/` SHOULD be git‑ignored by default to avoid committing sensitive or high‑churn files.
- `docs/assistant-learning-logs/` SHOULD be committed for curated artifacts and examples.
- Repositories MAY override the default destination via `.cursor/config.json` if their policy differs.

### Example `.cursor/config.json`

```json
{
  "logDir": "./assistant-logs/"
}
```

### Example Log Entry (Private)

```markdown
Timestamp: 2025-10-02T02:00:00Z
Event: TDD Green
Owner: assistant-learning
What Changed: Implemented fallback write and verified success.
Next Step: Promote a weekly summary to docs.
Links: scripts/assistant-learning/triggers.spec.ts
```

### Acceptance Criteria

- Default write without config creates a file under `assistant-logs/`.
- With `logDir` override, writes go to the configured directory.
- If destination is not writable, a file is created under `docs/assistant-learning-logs/`.
- Redaction is applied to all outputs (no obvious secret patterns remain).
- Example curated summaries exist under `docs/assistant-learning-logs/`.

### Validation Plan

1. Default Path

   - Remove `logDir` from `.cursor/config.json` (or unset).
   - Run: `.cursor/scripts/alp-logger.sh write-with-fallback ./assistant-logs/ "<body>"`.
   - Expect: new file `assistant-logs/log-*.md`.

2. Override Path

   - Set `logDir` to `./custom-logs/`.
   - Run logger; expect write under `custom-logs/`.

3. Fallback Behavior

   - Point `logDir` to a non‑writable path.
   - Run logger; expect write under `docs/assistant-learning-logs/`.

4. Redaction
   - Include a fake token pattern in the body; verify it is removed in the output.

### Risks & Mitigations

- Risk: Sensitive data in raw logs.
  - Mitigation: Private default, enforced redaction, promotion policy.
- Risk: Repository noise from committed raw logs.
  - Mitigation: Git‑ignore private logs; only curated docs are committed.
- Risk: Misconfiguration of `logDir`.
  - Mitigation: Clear fallback; validation steps documented.

### Open Questions

- Retention policy for private logs: size cap or time‑based rotation?
- Additional redact rules for organization‑specific secrets?
- Should CI enforce that `assistant-logs/` is git‑ignored?
