---
status: completed
owner: rules-maintainers
completed: 2025-10-10
---

<!-- Archived copy of ERD from docs/projects/alp-logging/erd.md -->

# Engineering Requirements Document — ALP Logging Consistency (Lite)

Links: `.cursor/rules/assistant-behavior.mdc` | `.cursor/rules/assistant-learning.mdc` | `.cursor/scripts/alp-logger.sh` | `.cursor/scripts/alp-aggregate.sh` | `.cursor/scripts/alp-archive.sh` | `docs/assistant-learning-logs/README.md` | `docs/projects/alp-logging/discussion.md`

## 1. Introduction/Overview

Ensure Assistant Learning Protocol (ALP) logs are emitted consistently at high-signal moments with clear precedence over the general consent gate, concise entries, and predictable destinations.

## 2. Goals/Objectives

- Make ALP logging consistent, lightweight, and automatic on triggers
- Codify exception precedence (ALP consent exception → overrides general consent for logging only)
- Add per-turn “ALP-needed?” check to the mandatory send gate
- Keep entries concise (≤ 6 core lines) and redacted by default

## 3. Functional Requirements

1. Exception precedence: ALP logging is consent-exempt; it overrides the general consent gate for log writes only.
2. Per-turn check: A mandatory “ALP-needed?” decision is recorded before sending any message containing tool calls/edits. This check is intended to capture events such as misunderstandings, bottlenecks, repeated patterns, brittle behavior, or any clear improvement opportunity.
3. Triggers (minimum): Task Completed/Cancelled, Routing Corrected, Misunderstanding Resolved, TDD Red, TDD Green, Rule Added/Updated, Safety Near-Miss, Improvement Opportunity. Event values use this exact capitalization.
4. Status coupling: Require a pre-tool micro-update announcing the tool-category switch and pending ALP check; require a post-tool ALP outcome with created log path or `none — reason` (block send when missing).
   - Status format examples: `ALP: Task Completed — assistant-logs/log-2025-10-10Z-task-completed.md` and `ALP: none — no-trigger` (canonical none reasons: `no-trigger`, `duplicate-suppressed`, `batched-under:<event>`)
5. Logger-only writes: Use `.cursor/scripts/alp-logger.sh write-with-fallback` (no ad-hoc file edits); include fallback reason when used.
6. Redaction & limits: Enforce redaction; keep entries concise (≤ 6 core lines); rate-limit duplicates within 2 minutes; combine signals when adjacent.
7. Destinations: Primary `assistant-logs/` (configurable via `.cursor/config.json: logDir`), fallback to `docs/assistant-learning-logs/`.
8. Content shape: `Timestamp, Event, Owner, What Changed, Next Step, Links, Learning` required; “Signals” optional for extras.
9. Aggregation & archival: Produce a weekly aggregate summary and enforce threshold-based archival using `.cursor/scripts/alp-aggregate.sh` and `.cursor/scripts/alp-archive.sh` (newest log remains unarchived after each archive cycle).
10. Status format: Standardize `ALP: <Event> — <path>` for success and `ALP: none — <reason>` for none; reasons limited to `no-trigger`, `duplicate-suppressed`, `batched-under:<event>`.
11. Noise control: Enforce a 2-minute duplicate guard; combine adjacent small triggers; choose one primary Owner and list additional paths under Links; use consistent capitalization for Event values.
12. Failure reporting & fallback: If a logger invocation fails, status must include the command and exit code; attempt the fallback destination once and include the fallback reason in the body when used.
13. Defaults & guidance: Prefer frequent, small logs; default ambiguous cases to `Improvement Opportunity`; require `Next Step` to be verb-led and near-term; prefer repo-relative Links.

## 4. Acceptance Criteria

- On any listed trigger, a new ALP entry is written locally with required fields and concise body.
- Status updates include a pre-tool micro-update and show `ALP: <event>` post-tool with the created path, or `ALP: none — reason` when legitimately none.
- Duplicate suppression is honored; adjacent small triggers combine signals.
- No logs are written via ad-hoc file edits; logger path used so threshold hooks work.
- Weekly aggregate summary is generated and threshold-based archival occurs via the provided scripts; the newest log remains unarchived.
- Primary Owner is selected with any additional affected paths listed under Links; Event values use consistent capitalization; bodies contain no tokens/headers; Links are repo-relative.
- On logger failures, status surfaces the command and exit code; a single fallback attempt is made and the fallback reason is recorded in the log body when applicable.

## 5. Non-Functional Requirements

- Strictly local (no network beyond GitHub API for PRs elsewhere)
- Secret-safe (mandatory redaction); no token echoes
- Minimal friction (single helper script; heredoc-friendly)
- Cross-platform: On Windows, prefer WSL or Git Bash; path semantics documented. `logDir` may be overridden via `.cursor/config.json`.

## 6. Open Questions

- Expand optional triggers beyond the minimum set?
- Add a standing weekly “Top Learnings” rollup section to the aggregate summary?

## 7. To Be Determined

- Define what constitutes a `tool-category switch` for pre-tool status lines (e.g., local filesystem, git, web/network).
