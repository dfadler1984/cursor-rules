---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Assistant Learning Logs: Hard Gate

Mode: Lite

## 1. Introduction/Overview

Make Assistant Learning Protocol (ALP) logs a hard gate so reflective entries are captured at key moments (routing corrections, misunderstandings, TDD Red/Green, task completion).

## 2. Goals/Objectives

- Require ALP entries for specified triggers before merge.
- Add lightweight enforcement via PR template checklist and an optional CI check.
- Keep logs redacted and portable; provide a docs fallback path.

## 3. Functional Requirements

1. Triggers (minimum): Routing Corrected, Misunderstanding Resolved, TDD Red, TDD Green, Task Completed.
2. Evidence: PR must reference new log files under `assistant-logs/` (or fallback docs path) covering occurred triggers.
3. PR Template: Add checklist items for ALP compliance and links.
4. CI/Script (optional): fail when target areas changed without matching ALP entries.

## 4. Non-Functional Requirements

- No secrets; use redaction helper.
- Minimal friction; template and script should be easy to use.
- Clear error messages and remediation steps.

## 5. Acceptance

- PRs that include rule/script/docs changes demonstrate ALP entries for occurred triggers.
- Checklist present and used; CI check (if enabled) passes only with evidence.

## 6. Open Questions

- Which directories should mandate ALP (rules, scripts, docs, all)?
- Should we auto-generate stub entries on triggers to reduce friction?

## 7. Investigation: Taskmaster Self‑Improve Rule

- Target reference: `/Users/dustinfadler/Development/claude-task-master/.cursor/rules/self_improve.mdc`
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
