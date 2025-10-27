---
status: completed
completed: 2025-10-07
owner: rules-maintainers
---

# (Archived) Engineering Requirements Document — Rule Maintenance & Validator (Lite)


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
- Flags:
  - `--format json|text` (default: `text`)
  - `--fail-on-missing-refs` (treat unresolved references as errors; leverages `links-check.sh`)
  - `--autofix` for formatting-only issues (e.g., CSV comma spacing, boolean casing)
- Staleness policy: `lastReviewed` older than 90 days is flagged (warning by default)

## 4. Acceptance Criteria

- Validator flags (`--format`, `--fail-on-missing-refs`, `--autofix`) are documented
- Staleness threshold and default severity (warning) are documented
- Example JSON summary included
- Review flow and report structure described with concrete steps/commands

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

## 9. Review Flow

1. Run validator (default text) and review issues:

   ```bash
   .cursor/scripts/rules-validate.sh
   ```

2. Optional: produce JSON summary for tooling/reporting:

   ```bash
   .cursor/scripts/rules-validate.sh --format json
   ```

3. Optional: fail build on unresolved references (uses `links-check.sh` under the hood):

   ```bash
   .cursor/scripts/rules-validate.sh --fail-on-missing-refs
   ```

4. Generate a review report at `docs/reviews/review-<ISO>.md` capturing Counts and Actions.

5. For formatting-only issues, consider `--autofix`, then re-run validation.

6. Treat `lastReviewed` older than 90 days as stale; update only when making substantive content edits.
