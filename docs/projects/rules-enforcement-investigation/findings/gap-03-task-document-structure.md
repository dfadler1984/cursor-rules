# Gap #3: Task Document Structure Not Clearly Defined

**Discovered**: 2025-10-15  
**Context**: tasks.md cleanup  
**Severity**: Medium (document bloat)

---

## Issue

No clear guidance on what belongs in tasks.md vs ERD vs other docs

## Evidence

tasks.md accumulated findings, questions, success criteria (152 lines non-task content)

## Impact

Tasks file became bloated with content that should be in ERD/README

## Recommendation

Define tasks.md as phase sections with checklists only; all other content in ERD

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

- Task: 16.0 in [tasks.md](../tasks.md)

