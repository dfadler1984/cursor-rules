---
findingId: 21
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #21: Empty Final Summaries in Archived Projects

**Date Observed:** 2025-10-23  
**Category:** Execution failure — Lifecycle policy violation  
**Severity:** Medium (incomplete project artifacts)  
**Status:** Identified, one instance fixed, enforcement needed

---

## Symptom

Archived project `collaboration-options` had `final-summary.md` with template placeholders instead of completed content. This violates project lifecycle completion requirements.

## What Happened

During multi-chat session:

1. Chat 3 archived `collaboration-options` project
2. Created `final-summary.md` but left template placeholders:
   - `<One-paragraph summary of the project, scope, and outcome.>`
   - `<list>` for retrospective sections
   - `<owner or team>` for credits
3. Archival completed despite incomplete artifact

**User Concern:**

> "I was worried about that. We need to make sure the final summary is always filled in with meaningful details."

## Root Cause

**Missing Enforcement:** No validation gate prevents archiving with incomplete final summaries.

**Evidence:**

- `project-lifecycle.mdc` requires final summaries but doesn't specify validation
- `.cursor/scripts/project-archive-workflow.sh` doesn't validate summary completeness
- `.cursor/scripts/final-summary-generate.sh` exists but wasn't used/enforced

**Why This Happened:**

1. **No pre-archive validation:** Script doesn't check for template placeholders
2. **No template detection:** Can't distinguish complete vs incomplete summaries
3. **Manual archival:** Human/assistant can bypass automation

## Impact

- **Historical Record Loss:** Future readers can't understand what the project accomplished
- **Pattern Learning:** Can't extract lessons if retrospectives are incomplete
- **Metrics Missing:** Impact data unavailable if placeholders remain

## Expected Behavior

Per `project-lifecycle.mdc` completion checklist:

1. **Before archival:**

   - Final summary MUST be complete (no placeholders)
   - All template sections filled with real content
   - Retrospective includes actual learnings

2. **Validation:**
   - Detect template placeholders: `<...>`, `<list>`, etc.
   - Require minimum content length per section
   - Block archival if summary incomplete

## Corrective Action Taken

✅ Fixed `collaboration-options/final-summary.md` (filled all sections)  
✅ Documented in gap-21  
✅ Identified need for enforcement mechanism

## Prevention

### Short-term (Immediate)

- [ ] Manual review: Check all 3 newly archived projects for complete summaries
  - ✅ collaboration-options (fixed)
  - ✅ productivity (complete)
  - ✅ slash-commands-runtime (complete)

### Medium-term (Validation Script)

**Create:** `.cursor/scripts/final-summary-validate.sh`

```bash
#!/usr/bin/env bash
# Validates final-summary.md completeness

# Checks:
# 1. File exists
# 2. No template placeholders: <...>, <list>, <owner or team>
# 3. Required sections present: Summary, Impact, Retrospective, Credits
# 4. Minimum content length per section (e.g., >50 chars for Summary)
# 5. lastUpdated date is present and recent

# Exit codes:
# 0 = valid
# 1 = incomplete/invalid
# 2 = missing file
```

**Integration:**

- Call from `project-archive-workflow.sh` before archival
- Add to `project-complete.sh` validation checklist
- Add to CI: Reject PRs archiving projects with incomplete summaries

### Long-term (Rule Updates)

**1. Update `project-lifecycle.mdc`:**

Add explicit validation requirement:

```markdown
## Final Summary Requirements (must)

Before archiving:

- ✅ All template placeholders replaced with real content
- ✅ Summary: >50 characters, describes outcome
- ✅ Impact: Baseline → Outcome with metrics
- ✅ Retrospective: What worked, What to improve, Follow-ups
- ✅ Credits: Owner/team identified
- ✅ lastUpdated: Current date

**Validation:** Run `.cursor/scripts/final-summary-validate.sh <project-slug>`
```

**2. Update `assistant-behavior.mdc` → Pre-Send Gate:**

Add item:

```markdown
- [ ] Final Summaries: archived projects have complete summaries (no placeholders)?
```

**3. Create `final-summary.template.mdc` rule:**

Guidance for filling final summaries:

- What makes a good Summary (concise, outcome-focused)
- Impact metrics patterns (Baseline → Outcome)
- Retrospective depth (specific learnings, not generic)
- When to defer final summary (never - must be complete before archive)

### Documentation Changes

**1. ERD template:** Add final summary section to completion checklist

**2. Tasks template:** Add final summary validation step

**3. README:** Link to final-summary-validate.sh in project lifecycle section

## Test Cases

### Valid Final Summaries

- ✅ No `<...>` placeholders
- ✅ Summary >50 chars with outcome
- ✅ Impact has "Baseline → Outcome" pattern
- ✅ Retrospective has 3+ specific items per subsection
- ✅ Credits names actual owner

### Invalid Final Summaries (should fail validation)

- ❌ Contains `<One-paragraph summary...>`
- ❌ Contains `<list>`
- ❌ Contains `<owner or team>`
- ❌ Summary <50 chars or generic
- ❌ Missing required sections
- ❌ lastUpdated date missing or >7 days old at archive time

## Related Gaps

- Gap #18: Project completion validation (general pattern)
- Gap #11: Documentation-before-execution (should document validation before archiving)

## References

- `.cursor/rules/project-lifecycle.mdc` → Completion checklist
- `.cursor/scripts/project-archive-workflow.sh` (needs validation integration)
- `.cursor/scripts/final-summary-generate.sh` (exists but underused)
- Template: `docs/projects/_examples/final-summary.template.md`

---

**Priority:** HIGH — Affects all future project archival  
**Effort:** Medium (script creation + rule updates + documentation)  
**Impact:** High (preserves institutional knowledge)

**Next Steps:**

1. Create `final-summary-validate.sh` with placeholder detection
2. Integrate validation into `project-archive-workflow.sh`
3. Update `project-lifecycle.mdc` with validation requirements
4. Add to Pre-Send Gate checklist
