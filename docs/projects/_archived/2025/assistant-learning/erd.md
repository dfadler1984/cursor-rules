---
status: completed
completed: 2025-10-03
owner: rules-maintainers
---

---

---

# Engineering Requirements Document — Assistant Learning Protocol (ALP)

`docs/projects/assistant-learning/final-summary.md`

Mode: Full

Scope note: This ERD defines the Assistant Learning Protocol (ALP) as a first‑class, enforceable system for structured reflection and self‑improvement. Includes protocol, triggers, storage/backends, integrations, aggregator, and rollout. Implementation scaffolding is described but not executed.

## 1. Introduction/Overview

The Assistant Learning Protocol (ALP) establishes a deterministic logging and reflection system to capture problems, solutions, lessons, and rule candidates after key assistant actions (e.g., TDD Red→Green, intent mismatch resolution, rule violation fixes, task completion, MCP execution recovery). The goal is consistent, portable self‑improvement: turn experiences into actionable insights and maintain a pipeline from learnings → rule updates.

## 2. Goals/Objectives

- Define a canonical operator checklist and log template for fast, consistent entries.
- Specify deterministic triggers and on/off configuration.
- Document storage configuration with safe fallbacks and optional MCP backends.
- Integrate with spec‑driven planning, TDD‑first, rule‑creation, and rule‑maintenance.
- Provide an aggregator/summary contract to surface trends and propose rule candidates.
- Ensure privacy and safety (no secrets; minimal, redacted logs).

## 3. Users and Ownership

- Engineer (operator): Writes logs on triggers; uses checklist/template.
- Manager: Reviews summaries; approves rule proposals.
- Detective (investigator): Logs blocker analyses (failures, recoveries).
- Rules Maintainers: Curate rule changes from candidates; run periodic reviews.
- Owner: rules‑maintainers (rotating). Backup: project lead.

## 4. Functional Requirements

1. Canonical operator checklist (TL;DR) is present at top‑of‑docs and referenced from rules.
2. Log template is paste‑ready and used for all entries.
3. Triggers produce log entries unless disabled; disablement is explicit in config.
4. Storage respects `.cursor/config.json` → `logDir` with fallback to `docs/assistant-learning-logs/`.
5. Optional MCP backends (Google Docs, Confluence) append logs as sections; fallback is local.
6. Aggregator can summarize logs, extract `[rule-candidate]`, and suggest updates.
7. Integrations: TDD (owner spec coupling), spec‑driven (plan/task tie‑ins), rule‑creation, rule‑maintenance.
8. Safety: Never log secrets; redact sensitive values; avoid headers like Authorization.

## 5. Non‑Functional Requirements

- Reliability: Logging succeeds or falls back locally with a single warning.
- Performance: Median log write ≤ 20s from trigger under normal conditions.
- Usability: Operator checklist ≤ 15 lines; template copy‑pastable.
- Portability: Works offline; requires no MCP to function.
- Observability: Aggregator emits concise metrics and trend summaries.

## 6. Operator Checklist (TL;DR)

1. Detect trigger (see list below).
2. Open the log destination (auto per config).
3. Paste the template and fill: Problem → Solution → Lesson → Rule candidate (if any) → Context.
4. Tag `[rule-candidate]` when proposing a rule.
5. Save. If backend fails, it auto‑falls back to local and notes a warning.
6. If pattern repeats, open a rule PR referencing entries.

## 7. Canonical Log Template

```markdown
[YYYY-MM-DDTHH:MM, persona] Problem: <what failed/was unclear>.
Solution: <what changed>.
Lesson: <portable insight>.
Rule candidate: <name>. [rule-candidate]
Context: <link to spec/test/commit/PR or file path>.
```

Personas: `senior-engineer` (default), `deep` (multi‑perspective: director/manager/engineer).

## 8. Triggers (Deterministic)

Enabled by default; toggle per `.cursor/config.json`:

- TDD Red→Green: After making a failing owner spec pass.
- Intent mismatch resolved: After a clarify‑then‑act correction.
- Rule violation fix: After acknowledging and correcting a rule miss.
- Task completion (notables): When a task yields a novel lesson.
- MCP execution recovery/failure: On 401/403/422/429 handling, with redactions.
- Manual reflection: On command (operator discretion).

Config keys (example):

```json
{
  "logDir": "./assistant-logs/",
  "assistantLearning": {
    "persona": "senior-engineer",
    "autoTriggers": {
      "tddFix": true,
      "intentResolution": true,
      "ruleFix": true,
      "taskCompletion": true,
      "mcpRecovery": true
    },
    "backends": {
      "local": true,
      "googleDocs": false,
      "confluence": false
    }
  }
}
```

## 9. Storage and Backends

- Primary: `logDir` from `.cursor/config.json` (default `./assistant-logs/`).
- Fallback: `docs/assistant-learning-logs/` if primary not writable.
- MCP backends (optional):
  - Google Docs MCP: Append a new section per entry under a configured document.
  - Confluence MCP: Append/update a page section per entry.
- Failure policy: Never drop entries; write locally and surface a single warning.

## 10. Architecture/Design

- Effects boundary: Logging I/O behind a thin adapter; core formatting is pure.
- Deterministic format: Single template; schema‑like fields for aggregation.
- Aggregator: Read‑only summarizer that scans entries, extracts `[rule-candidate]`, groups by tags, emits trends and proposals.
- Security: Redact tokens/keys; avoid echoing request headers; store minimal context links.

## 11. Data Model and Storage

- File layout (local):
  - Directory: `${logDir}` (e.g., `./assistant-logs/`).
  - Filename: `log-<ISO8601>-<short-descriptor>.md` (e.g., `log-2025-10-01T17-03-00Z-law-correction.md`).
  - Body fields: Timestamp, Outcome, What Worked, Improvements, Proposed Rule Changes (for summary entries) OR canonical template for atomic entries.
- Indexing: Aggregator discovers by glob `assistant-logs/log-*.md` and `docs/assistant-learning-logs/log-*.md`.
- Retention: Keep indefinitely unless configured; optional pruning by date range.

## 12. API/Contracts

- Logger adapter interface (conceptual):

```ts
export type LearningEntry = {
  timestampIso: string;
  persona: "senior-engineer" | "deep";
  problem: string;
  solution: string;
  lesson: string;
  ruleCandidate?: string; // presence implies [rule-candidate]
  context?: string;
};

export type LoggerDeps = {
  writeLocal: (path: string, content: string) => Promise<void>;
  writeGoogle?: (docId: string, section: string) => Promise<void>;
  writeConfluence?: (pageId: string, section: string) => Promise<void>;
  isWritable: (dir: string) => Promise<boolean>;
};
```

- Aggregator contract (conceptual):

```ts
export type Aggregation = {
  count: number;
  ruleCandidates: { name: string; occurrences: number; examples: string[] }[];
  themes: string[];
  suggestions: string[]; // proposed rule changes
};
```

## 13. Integrations/Dependencies

- TDD‑First: Trigger on Red→Green; owner spec path included in context.
- Spec‑Driven: Summarize planning outcomes; link specs/plans/tasks.
- Rule‑Creation: Convert `[rule-candidate]` into draft rule files with front matter.
- Rule‑Maintenance: Monthly scan aggregates entries and proposes updates.
- Capabilities Discovery: May surface “learning” as a capability; no execution.
- MCP Synergy: Record minimal audit notes (server/tool/status); never secrets.

### 13.a Trigger Integration Notes (Shell)

- Commands live under `.cursor/scripts/`:
  - `alp-triggers.sh`: emits entries for `tdd-fix`, `intent-resolution`, `rule-fix`, `task-completion`, `mcp-recovery`.
  - `alp-template.sh`: formats canonical entries.
  - `alp-logger.sh`: safe write, fallback to `docs/assistant-learning-logs/` when primary unwritable.
- Feature flag: integration should check the ALP feature flag before emitting (disable path is a no‑op). For the shell utilities, guard execution with an env or simple flag until config reading is wired.
- CI: weekly aggregator runs via `.github/workflows/alp-aggregate.yml`; local runs use `./.cursor/scripts/alp-aggregate.sh`.
- Safety: pipe any generated content through `alp-redaction.sh redact` when content may include secrets.

## 14. Edge Cases and Constraints

- Auto‑trigger noise: Allow disabling specific triggers.
- Backend failures: Always fall back locally; warn once.
- Privacy: Avoid copying user content verbatim if sensitive; summarize.
- Timezones: Use UTC ISO8601 filenames for ordering.

## 15. Testing & Acceptance

- Acceptance Criteria:
  - Canonical template present and referenced.
  - Triggers enumerated with on/off config keys.
  - Storage keys and fallback behavior documented.
  - Worked example with sample filename included.
  - Integrations with TDD/spec‑driven/rule‑creation explicit.
  - Aggregator contract defined.
- Test Plan:
  - Simulate each trigger; verify a log entry is produced or local fallback occurs.
  - Aggregator finds `[rule-candidate]` entries and outputs proposals.
  - Verify redaction rules by attempting to log headers/tokens (should be stripped).

## 16. Success Metrics

- ≥ 90% log compliance on triggered events.
- ≥ 30% reduction in repeat mistakes within 4 weeks.
- ≥ 2 rule candidates/month derived from logs.
- Median log write latency ≤ 20s from trigger.

## 17. Rollout & Ops

- Feature flag: `assistant-learning-protocol`.
- Owner: rules‑maintainers.
- Target: +14 days from approval.
- Comms: Link from `README.md`; add to related rules (`spec-driven.mdc`, `tdd-first.mdc`, `rule-creation.mdc`).
- Monitoring: Weekly aggregator run; post summary to repo (docs/assistant-learning-logs/summary-<ISO8601>.md) or MCP destination when enabled.

## 18. Open Questions

- Preferred MCP document/page identifiers (if enabled)?
- Aggregator cadence (weekly vs bi‑weekly)?
- Additional personas needed?

## 19. Worked Example

Example entry after fixing a brittle test via TDD:

```markdown
[2025-10-01T17:03, senior-engineer] Problem: Owner spec missed bracketed globs edge case.
Solution: Added validation and a failing test first; then implemented minimal fix.
Lesson: Validate input format early; prefer declarative checks.
Rule candidate: deterministic-outputs.mdc - add glob validation note. [rule-candidate]
Context: docs/specs/glob-parse-spec.md#rejects-bracketed-globs | commit abc123
```

Example summary file (aggregated): `assistant-logs/log-2025-10-01T17-03-00Z-law-correction.md` with What Worked/Improvements/Proposed Rule Changes sections.

### Trigger usage snippets (shell)

```bash
# TDD Red→Green trigger
./.cursor/scripts/alp-triggers.sh tdd-fix senior-engineer \
  "Owner spec missed bracketed globs edge case." \
  "Added validation and a failing test first; then implemented minimal fix." \
  "Validate input format early; prefer declarative checks." \
  "deterministic-outputs.mdc - add glob validation note." \
  "docs/specs/glob-parse-spec.md#rejects-bracketed-globs | commit abc123"

# Aggregate weekly or on demand
./.cursor/scripts/alp-aggregate.sh
```
