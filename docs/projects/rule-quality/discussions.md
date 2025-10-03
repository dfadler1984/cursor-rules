# Discussions — Rule Quality & Consolidation

Purpose: Capture decisions, trade-offs, and notes for consolidating and validating the ruleset.

## Working Topics

- Consolidation map and category structure
- Global Defaults extraction (canonical source)
- Validation script scope and heuristics
- Routing sanity prompts and expected attachments
- PR hygiene and capability sync discipline

## Consolidation Map (Draft)

- Testing family → `testing.mdc`

  - Subsections: Structure, Naming, Quality, Coverage>0 guards, Owner spec rule
  - Keep `testing.caps.mdc` as a concise quick reference

- Critical thinking → fold into `direct-answers.mdc`

  - Section: Root‑cause‑first (Cause, Evidence, Next step ≤3 lines)

- Task list process → fold into `project-lifecycle.mdc`

  - Section: Single active sub‑task; dependency/priority‑aware next selection

- Capabilities discovery → fold into `capabilities.mdc`

  - Section: Discovery (rules list, validate, show scripts)

- Add `global-defaults.mdc`
  - Consent-first behavior, status updates, TDD pre‑edit gate, source‑of‑truth citations
  - All other rules link here instead of duplicating these blocks

## Validation Script Outline

Checks:

1. Front matter

- Required keys present; `lastReviewed` format `YYYY-MM-DD`
- `healthScore` has content/usability/maintenance
- CSV field formatting (`globs`, `overrides`): commas, no spaces/braces

2. Links

- Each referenced `.mdc` exists; no broken relative paths
- “See also” sections present where applicable

3. Globs breadth

- Warn on `**/*` or project‑wide patterns; suggest narrowing

4. Duplication

- Detect repeated blocks (e.g., TDD gate paragraph) and suggest linking to `global-defaults.mdc`

5. Caps pairing

- Ensure every `.caps.mdc` has a single corresponding `.mdc` and vice versa

6. Capabilities sync

- If rules/scripts changed, require updates to `.cursor/rules/capabilities.mdc`

Outputs:

- Markdown report grouped by rule with actionable suggestions
- Non‑zero exit on errors (missing front matter, broken links); warnings for breadth/duplication

## Routing Sanity Prompts

- “Add tests for X” → expect: `testing`, `tdd-first` only
- “Refactor Y” → expect: `refactoring` (+ `testing` if JS/TS target), not `tdd-first` unless edits planned
- “Create an ERD for Z” → expect: `create-erd`, `guidance-first`
- Guidance-only questions → exclude execution/tooling rules

## PR Hygiene

- Include checklist: ran validation script, updated `lastReviewed`, updated `@capabilities`, pasted validator output if failures were fixed
- Prefer redirects or short deprecation headers when merging rules; avoid silent deletion

## Open Questions

- Do we keep a thin `task-list-process.mdc` stub that points to `project-lifecycle`?
- Where should `global-defaults.mdc` live in the index order?

## Notes

Complexity rubric: I was proposing rule edits (add rubric notes to /analyze in spec-driven.mdc and a brief note in generate-tasks-from-erd.mdc). We can also document it in discussions.md for now if you prefer to defer rule changes.
Rule renames: not yet tracked as tasks; if you want, I can add a todo to plan and execute renames with validator support.
