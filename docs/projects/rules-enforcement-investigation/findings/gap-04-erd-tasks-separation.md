# Gap #4: ERD vs Tasks Separation Unclear for Acceptance Criteria

**Discovered**: 2025-10-15  
**Context**: ERD review  
**Severity**: Medium (duplication and unclear source of truth)

---

## Issue

No clear guidance on whether acceptance criteria checklists belong in ERD or tasks

## Evidence

ERD section 5 had acceptance criteria as checklists (should be in tasks.md)

## Impact

Duplication of checklist structure across files, unclear source of truth

## Recommendation

ERD describes acceptance criteria as narrative/requirements; tasks.md contains the actual checklists

## Pattern

ERD = requirements/what, tasks.md = execution/status

## Resolution

✅ **Applied in Phase 1** (Task 17.0)

Updated rules:
- `project-lifecycle.mdc`: Added "ERD vs tasks.md: Acceptance Criteria" section with examples
- `create-erd.mdc`: Added "Acceptance Criteria Format" section with do/don't examples
- `generate-tasks-from-erd.mdc`: Added "Converting ERD Acceptance Criteria to Tasks" section with transformation example

Evidence: ERD section 5 had checklists; cited with correct vs incorrect examples

## Files Affected

- `.cursor/rules/project-lifecycle.mdc`
- `.cursor/rules/generate-tasks-from-erd.mdc`
- `.cursor/rules/create-erd.mdc`

## Related

- Task: 17.0 in [tasks.md](../tasks.md)

