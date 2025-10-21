# Gap #7: Documentation-Before-Execution Pattern Not Automatic

**Discovered**: 2025-10-16  
**Context**: Slash commands Phase 3 setup  
**Severity**: Medium (process violation)

---

## Issue

Asked "which execution mode?" before documenting test protocol; user had to point out protocol should be documented regardless

## Evidence

2025-10-16 slash commands testing - proposed 3 execution modes but didn't document protocol first

## Impact

- Violated plan-first principle
- Required user correction
- Missed opportunity to model good practice during investigation

## Meta-Observation

Even while investigating rule enforcement, violated documentation-first pattern

## Recommendation

Strengthen self-improve.mdc to treat "should document first" as first-class trigger, not afterthought

## Pattern

Document → then choose execution; not "choose execution, maybe document"

## Resolution

✅ **Applied in Phase 1** (Task 20.0)

Updated `self-improve.mdc`:

- Added process-order trigger to self-improve.mdc
- Added to "Process-Order Patterns" section

## Files Affected

- `.cursor/rules/self-improve.mdc`
- Potentially: `.cursor/rules/spec-driven.mdc`

## Related

- Task: 20.0 in [tasks.md](../tasks.md)
- Part of rule improvements (15.0-20.0) applied in Phase 1
