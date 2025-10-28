---
findingId: 03
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #3: Task Document Structure Not Clearly Defined

**Discovered**: 2025-10-15  
**Severity**: Medium (document bloat)

---

## Issue


## Evidence


## Impact

Tasks file became bloated with content that should be in ERD/README

## Recommendation


## Resolution

✅ **Applied in Phase 1** (Task 16.0)

Updated rules:

- `project-lifecycle.mdc`: Added strict structure section with must include/exclude lists
- `generate-tasks-from-erd.mdc`: Added "What NOT to Include" section with 5 prohibited content types

Evidence cited in both rules with examples.

## Files Affected

- `.cursor/rules/project-lifecycle.mdc`
- `.cursor/rules/generate-tasks-from-erd.mdc`

## Related

