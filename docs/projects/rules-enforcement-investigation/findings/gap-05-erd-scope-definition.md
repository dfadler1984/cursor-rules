# Gap #5: ERD Scope Not Clearly Defined

**Discovered**: 2025-10-15  
**Context**: ERD review  
**Severity**: Medium (ERD bloat)

---

## Issue

ERD accumulates findings, retrospective, and detailed execution plans beyond requirements

## Evidence

- ERD section 11 (73 lines) contained findings/carryovers, not requirements
- Section 10 had detailed week-by-week timeline
- Total ERD: 441 lines (bloated)

## Impact

ERD becomes bloated (441 lines), hard to scan for actual requirements

## Recommendation

Define ERD scope clearly (requirements only); create separate findings.md for retrospective/outcomes

## Pattern

- ERD = requirements/approach
- findings.md = outcomes/retrospective
- tasks.md = execution/status

## Resolution

✅ **Applied in Phase 1** (Task 18.0)

Updated rules:
- `project-lifecycle.mdc`: ERD = requirements/approach pattern
- `create-erd.mdc`: Added "ERD Scope Definition" section at top; listed in "What ERDs Do NOT Contain" with rationale

Evidence: 441-line ERD bloat example; correct separation documented

## Files Affected

- `.cursor/rules/project-lifecycle.mdc`
- `.cursor/rules/create-erd.mdc`

## Related

- Task: 18.0 in [tasks.md](../tasks.md)

