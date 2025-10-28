---
findingId: 12
date: "2025-10-24"  # Inferred from migration
project: "rules-enforcement-investigation"
severity: "medium"  # Default for migrated findings
status: "open"      # Default for migrated findings
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: []      # To be filled post-migration
---

# Gap #12: ERD/Tasks Separation Violation

**Discovered**: 2025-10-22  
**Context**: consent-gates-refinement project  
**Severity**: Medium (pattern violation affecting project lifecycle compliance)

---

## What Happened

While working on `docs/projects/consent-gates-refinement`, I mixed task execution details into the ERD document:

**ERD Section 12 "Rollout & Ops"** contained:

- ✅ Checkboxes indicating task completion status
- 🔄 In-progress indicators
- Specific action items like "Test slash commands execute without prompts"
- "Remaining refinements (as needed)" - task planning
- "Feedback loop" - execution detail

**ERD Section 11 "Acceptance Criteria"** contained:

- Task-like checkboxes with completion markers ([ ] / [x])
- References to implementation documents (which is okay as evidence, but was presented as tasks)

**ERD Section 14 "Open Questions"** contained:

- "Action: Monitor and document..." - task directive, not a question

---

## What Should Have Happened

Per `project-lifecycle.mdc`:

**ERD should contain**:

- Requirements (functional, non-functional)
- Acceptance criteria (conditions for "done", not task lists)
- Open questions (about requirements, not execution)
- Rollout **plan** (approach, not task tracking)

**tasks.md should contain**:

- Execution steps (with checkboxes)
- Task status tracking ([x] / [ ])
- Phase organization
- Specific action items

---

## Root Cause

**Pattern**: Conflating requirements specification with execution tracking

**Contributing factors**:

1. **Convenience bias**: ERD was already open, easier to add task-like content there
2. **Completion visibility**: Wanted to show progress in the "main" document (ERD)
3. **Missing distinction**: Not clear enough on "what needs to be true" (requirements) vs "what to do" (tasks)

**Rule awareness**: I know `project-lifecycle.mdc` exists but didn't apply the ERD/tasks separation properly

---

## Evidence

**Before correction** (`consent-gates-refinement/erd.md`):

```markdown
## 12. Rollout & Ops

1. ✅ Document baseline consent issues — See `baseline-issues.md`
2. ✅ Classify operations by risk tier — See `risk-categorization.md`
3. ✅ Implement core consent fixes — See `implementation-summary.md`
4. 🔄 Real-session validation (Phase 3):
   - Test slash commands execute without prompts
   - Test `/allowlist` and natural language triggers
```

**After correction** (`consent-gates-refinement/erd.md`):

```markdown
## 12. Rollout Plan

**Approach**: Phased rollout with validation gates

1. **Phase 1 (Analysis)**: Document baseline, categorize operations, identify gaps
2. **Phase 2 (Implementation)**: Implement core fixes, defer additional refinements
3. **Phase 3 (Validation)**: Real-session testing (1-2 weeks), collect metrics
4. **Phase 4 (Optional Refinements)**: Based on Phase 3 results

**Validation gates**:

- After Phase 2: Core fixes must be implemented before moving to Phase 3
```

**Moved to tasks.md**:

```markdown
## Phase 3: Validation

### Real-Session Testing

- [ ] Test `/commit` executes without "Proceed?" prompt in real session
- [ ] Test `/pr` executes without "Proceed?" prompt
- [ ] Test `/allowlist` displays current session state correctly
```

---

## Pattern Analysis

**Same violation in other projects?**

Need to audit:

- Other active projects for ERD/tasks separation
- Check if this is a recurring pattern across multiple projects

**Hypothesis**: This may be a systemic issue where I prioritize "showing progress" over proper document separation.

---

## Corrective Actions

### Immediate (This Project - consent-gates-refinement)

- [x] Rewrite ERD Section 11 (Acceptance Criteria) as conditions, not tasks
- [x] Rewrite ERD Section 12 (Rollout & Ops) as a plan, not task tracking
- [x] Remove task indicators (✅, 🔄, checkboxes) from ERD
- [x] Remove "Action:" directives from ERD Section 14 (Open Questions)
- [x] Move execution details to tasks.md Phase 3/4
- [x] Document this gap (#12)

### Immediate (rules-enforcement-investigation - meta-fix)

- [x] Rewrite ERD Section 4 Phase 6 to remove "Completed/Remaining Work" task tracking
- [x] Rewrite ERD Section 5 (Acceptance Criteria) as conditions, remove all status indicators (✅, ❌, ⏳, ⏸️)
- [x] Execution tracking remains correctly in tasks.md (appropriate location)

### Pattern Prevention (Future Projects)

- [ ] **Pre-file-creation check**: Before adding content to ERD or tasks, ask: "Is this a requirement or an execution step?"
- [ ] **Checkpoint reviews**: When marking tasks complete, verify ERD hasn't accumulated task content
- [ ] **Template reminder**: Add comment at top of ERD template: "Requirements only - no task checkboxes or completion tracking"

### Investigation Scope

- [ ] Audit other active projects (list: ai-workflow-integration, artifact-migration, assistant-self-improvement, etc.)
- [ ] Check for similar violations
- [ ] Add to rules-enforcement-investigation test battery

---

## Related Gaps

- **Gap #11** (investigation-structure rule created): Discovered gap during investigation but didn't propose rule immediately
- **Both gaps share root cause**: Not enforcing documented structure/separation rules in real-time

---

## Meta-Observation

**User's feedback**: "You are incorrectly following the project life cycle, specifically you seem to have trouble keeping the erd and tasks correctly written and updated"

This is accurate. The pattern suggests:

- I understand the rules conceptually
- I don't consistently apply them during execution
- Convenience/habit overrides documented structure

**Connection to rules-enforcement-investigation**: This is precisely what the investigation is studying - the gap between documented rules and actual enforcement.

---

## Success Criteria for This Gap

- [ ] No task checkboxes or completion indicators in ERD documents
- [ ] Acceptance criteria written as conditions ("The solution is complete when..."), not task lists
- [ ] Rollout sections describe approach/plan, not track execution
- [ ] All execution tracking in tasks.md with proper phase/subsection organization
- [ ] Pre-edit checkpoint: "Is this a requirement (ERD) or an action (tasks)?"

---

## References

- `project-lifecycle.mdc` — ERD vs tasks separation policy
- `consent-gates-refinement/erd.md` — This violation example (now corrected)
- `consent-gates-refinement/tasks.md` — Execution details properly placed
- Rules-enforcement-investigation — Parent investigation
