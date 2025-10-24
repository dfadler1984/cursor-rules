# TDD Scope Boundaries — Findings

**Monitoring Period**: 2025-10-24 to 2025-10-31 (~1 week)  
**Purpose**: Track TDD scope check accuracy during real-world usage

---

## What Gets Documented Here

**In Scope** (document here):

- **False Negatives**: Code changes that incorrectly skip TDD gate
- **False Positives**: Docs/configs that incorrectly trigger TDD gate
- **Ambiguity Cases**: Files requiring clarification (track rate)
- **Edge Cases**: File types not covered by current globs

**Out of Scope** (document elsewhere):

- Intent routing failures → See `routing-optimization`
- Execution compliance failures → See `rules-enforcement-investigation`

---

## Naming Pattern

`issue-##-<short-name>.md`

**Examples**:

- `issue-01-json-with-logic.md` — JSON file with embedded logic triggers ambiguity
- `issue-02-css-module-false-positive.md` — CSS module incorrectly triggers TDD gate

---

## Template for New Issues

```markdown
# Issue ##: <Short Title>

**Date**: YYYY-MM-DD  
**Category**: False Negative | False Positive | Ambiguity | Edge Case  
**File**: `path/to/file.ext`

## What Happened

[Brief description of the observed behavior]

## Expected Behavior

[What should have happened according to TDD scope rules]

## Root Cause

[Why did this happen? Gap in globs? Ambiguous decision tree?]

## Proposed Fix

[What change(s) would prevent this issue?]

## Related

- ERD Section: [link to relevant ERD section]
- Current Rule: [link to tdd-first.mdc section]
```

---

## Success Metrics

At end of monitoring period, we should have data for:

- **False Negative Rate**: 0 (target)
- **False Positive Rate**: 0 (target)
- **Ambiguity Rate**: <5% of file edits (target)
- **Edge Cases Discovered**: N/A (capture for future improvements)

---

## Related

- Parent Project: `docs/projects/tdd-scope-boundaries/`
- Monitoring Coordination: `docs/projects/ACTIVE-MONITORING.md`
- TDD Rules: `.cursor/rules/tdd-first.mdc`
- Scope Check Script: `.cursor/scripts/tdd-scope-check.sh`
