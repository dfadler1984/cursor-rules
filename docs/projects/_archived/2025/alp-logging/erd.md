---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — ALP Logging Consistency (Lite)

Links: `.cursor/rules/assistant-behavior.mdc` | `.cursor/rules/assistant-learning.mdc` | `.cursor/scripts/alp-logger.sh` | `docs/assistant-learning-logs/README.md` | `docs/projects/alp-logging/discussion.md`

## 1. Introduction/Overview

Ensure Assistant Learning Protocol (ALP) logs are emitted consistently at high-signal moments with clear precedence over the general consent gate, concise entries, and predictable destinations.

## 2. Goals/Objectives

- Make ALP logging consistent, lightweight, and automatic on triggers
- Codify exception precedence (ALP consent exception → overrides general consent for logging only)
- Add per-turn “ALP-needed?” check to the mandatory send gate
- Keep entries concise (≤ 6 core lines) and redacted by default

## 3. Functional Requirements

1. Exception precedence: ALP logging is consent-exempt; it overrides the general consent gate for log writes only.
2. Per-turn check: A mandatory “ALP-needed?” decision is recorded before sending any message containing tool calls/edits.
3. Triggers (minimum): Task Completed/Cancelled, Routing Corrected, Misunderstanding Resolved, TDD Red, TDD Green, Rule Added/Updated, Safety Near-Miss, Improvement Opportunity.
4. Status coupling: Status updates must include an ALP field (e.g., `ALP: <event|none>`), or block send when missing.
5. Logger-only writes: Use `.cursor/scripts/alp-logger.sh write-with-fallback` (no ad-hoc file writes); include fallback reason when used.
6. Redaction & limits: Enforce redaction; keep entries concise; rate-limit duplicates within 2 minutes; combine signals when adjacent.
7. Destinations: Primary `assistant-logs/` (configurable via `.cursor/config.json: logDir`), fallback to `docs/assistant-learning-logs/`.
8. Content shape: `Timestamp, Event, Owner, What Changed, Next Step, Links, Learning` required; “Signals” optional for extras.

## 4. Acceptance Criteria

- On any listed trigger, a new ALP entry is written locally with required fields and concise body.
- Status updates show `ALP: <event>` and the created path or `ALP: none — reason` when legitimately none.
- Duplicate suppression is honored; adjacent small triggers combine signals.
- No logs are written via ad-hoc file edits; logger path used so threshold hooks work.

## 5. Non-Functional Requirements

- Strictly local (no network beyond GitHub API for PRs elsewhere)
- Secret-safe (mandatory redaction); no token echoes
- Minimal friction (single helper script; heredoc-friendly)

## 6. Open Questions

- Expand optional triggers beyond the minimum set?
- Add a standing weekly “Top Learnings” rollup section to the aggregate summary?
