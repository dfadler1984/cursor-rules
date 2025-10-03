---
---

# Engineering Requirements Document — Rule Maintenance & Validator (Lite)

Links: `.cursor/rules/rule-maintenance.mdc` | `docs/projects/rule-maintenance/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Keep rules healthy with a cadence, validation checks, and actionable reports.

## 2. Goals/Objectives

- Define review cadence and health metrics
- Provide a light validator spec (front matter, dates, links)
- Aggregate learning logs into rule change proposals

## 3. Functional Requirements

- Validator CLI prints JSON summary and exits non-zero on violations
- Review report written to `docs/reviews/review-<ISO>.md`
- Surface stale `lastReviewed` and missing required fields

## 4. Acceptance Criteria

- Validator outputs documented; example JSON summary included
- Review flow and report structure described

## 5. Risks/Edge Cases

- Overly strict checks; allow autofix mode for formatting-only issues

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Run validator on this repo and confirm counts and exit codes

## 8. Examples

- Validator JSON summary (illustrative):

```json
{
  "missingFrontMatter": 0,
  "invalidDates": 1,
  "unresolvedReferences": 2
}
```

- Review report skeleton:

```markdown
# Rules Review — 2025-10-02

## Counts

- invalidDates: 1
- unresolvedReferences: 2

## Actions

- Fix invalid date in .cursor/rules/foo.mdc
- Resolve references in .cursor/rules/bar.mdc
```

---

Owner: rules-maintainers

Last updated: 2025-10-02
