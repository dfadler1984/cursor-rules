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

# Gap #12 Audit Results — ERD/Tasks Separation Violations

**Audit date**: 2025-10-22  
**Scope**: All active projects in `docs/projects/`  
**Pattern**: ERD files containing task execution tracking instead of requirements

---

## Summary

**Found**: 172 checkbox/status indicator matches across 19 ERD files

**Pattern violations detected**:

1. Checkboxes in ERD files (`- [ ]`, `- [x]`)
2. Status indicators in ERD (✅, ❌, ⏳, ⏸️)
3. Numbered lists with completion markers
4. Task execution tracking in Acceptance Criteria or Rollout sections

**Impact**: Conflates requirements specification with execution tracking, violating `project-lifecycle.mdc` separation policy

---

## Affected Projects (19 total)

Projects with ERD/tasks separation violations:

1. `assistant-self-testing-limits/` — 5 matches
2. `command-discovery-rule/` — 9 matches
3. `confluence-automation/` — 7 matches
4. `investigation-docs-structure/` — 10 matches
5. `jira-automation/` — 7 matches
6. `pr-create-decomposition/` — 21 matches
7. `project-lifecycle-coordination/` — 6 matches
8. `routing-optimization/` — 5 matches
9. **`rules-enforcement-investigation/`** — 4 matches (meta-irony: the investigation itself violates the pattern it's studying)
10. `rules-grok-alignment/` — 1 match
11. `script-refinement/` — 6 matches
12. `self-improvement-pivot/` — 17 matches
13. `self-improvement-rule-adoption/` — 18 matches
14. `rules-docs-quality-detection/` — 14 matches
15. `shell-test-organization/` — 11 matches
16. `tdd-scope-boundaries/` — 5 matches

**Plus 3 archived projects** (lower priority): 17. `_archived/2025/deterministic-outputs/` — 3 matches 18. `_archived/2025/shell-and-script-tooling/` — 19 matches 19. `_archived/2025/tests-github-deletion/` — 4 matches

---

## Worst Offenders (Top 5 by Match Count)

1. **`pr-create-decomposition/`** — 21 matches
2. **`_archived/2025/shell-and-script-tooling/`** — 19 matches
3. **`self-improvement-rule-adoption/`** — 18 matches
4. **`self-improvement-pivot/`** — 17 matches
5. **`rules-docs-quality-detection/`** — 14 matches

---

## Example Violations

### 1. rules-enforcement-investigation/erd.md (Lines 150-230)

**Violation**: Entire "Completed (Week 0)" and "Remaining Work" sections with task tracking

```markdown
**Completed (Week 0)**:

1. ✅ Built measurement framework (compliance checkers, baseline dashboard)
2. ✅ Ran Hypothesis 0 (meta-test with self-improve rule)
3. ✅ Established baseline metrics (68% overall, 71% script usage...)

**Remaining Work**:

**Phase 6A: Validate H1 Fix (2-3 weeks)**

1. Monitor script usage over 20-30 commits with alwaysApply: true
2. Measure actual improvement (expect: 71% → >90%)
```

**What's wrong**: This is task execution tracking, not requirements. Should be in `tasks.md`.

**Section 5 "Acceptance Criteria"**:

```markdown
### Phase 6A: Validate H1 Fix ⏳ IN PROGRESS

- ✅ Applied fix (git-usage → alwaysApply: true)
- ❌ Validated fix with 20-30 commits of actual usage
- ❌ Measured improvement (baseline 71% → target >90%)
```

**What's wrong**: Acceptance criteria should define conditions for "done", not track task completion with ✅/❌.

---

### 2. investigation-docs-structure/erd.md

**Violation**: Functional requirements section with execution steps

```markdown
2. **Reorganize rules-enforcement-investigation**
   - Move 40 files to correct locations
   - Remove duplicates
   - Create coordination.md
   - Update all cross-references
```

**What's wrong**: These are tasks, not functional requirements. Requirements should say what the system must do, not how to build it.

---

## Root Cause Analysis

**Why this happens**:

1. **Convenience**: ERD is the "main" document, easier to add progress there
2. **Visibility**: Want to show progress in the visible document
3. **Habit**: Adding checkboxes wherever describing work
4. **Missing distinction**: Not clear enough on requirements vs execution at authoring time

**Contributing factors**:

- ERD is typically opened first and stays open
- Tasks.md feels like "secondary" documentation
- No pre-write checkpoint: "Is this a requirement or a task?"
- No automated validation catching this pattern

---

## Pattern Types Found

### Type A: Checkboxes in Acceptance Criteria

```markdown
## Acceptance Criteria

- [x] Documented baseline issues
- [ ] Implemented core fixes
- [ ] Validated user reports smoother flow
```

**Should be**:

```markdown
## Acceptance Criteria

The solution is complete when:

- Baseline issues are documented in analysis artifacts
- Core fixes are implemented and validated
- User reports smoother consent flow with maintained safety
```

### Type B: Status Indicators in Rollout

```markdown
## Rollout & Ops

1. ✅ Document baseline — See baseline-issues.md
2. 🔄 Implement core fixes
3. ⏸️ Additional refinements
```

**Should be**:

```markdown
## Rollout Plan

**Approach**: Phased rollout with validation gates

1. **Phase 1**: Document baseline, categorize operations
2. **Phase 2**: Implement core fixes
3. **Phase 3**: Validation testing
```

### Type C: Task Lists in Functional Requirements

```markdown
## Functional Requirements

1. **Build measurement framework**
   - Create compliance checkers
   - Generate baseline dashboard
   - Run smoke tests
```

**Should be**:

```markdown
## Functional Requirements

**R1: Measurement framework**

- The system must provide automated compliance checking
- The system must generate baseline metrics dashboards
- The system must support smoke test validation
```

---

## Corrective Action Plan

### Immediate (High Priority Projects)

Fix these projects first (active work likely happening):

1. ✅ **consent-gates-refinement** (fixed as Gap #12 example)
2. ✅ **rules-enforcement-investigation** (meta-priority fix complete - ERD now requirements-only)
3. **pr-create-decomposition** (21 matches, highest count)
4. **self-improvement-rule-adoption** (18 matches)
5. **self-improvement-pivot** (17 matches)

### Medium Priority (Active Projects)

Fix remaining 11 active projects:

- investigation-docs-structure
- rules-docs-quality-detection
- shell-test-organization
- tdd-scope-boundaries
- script-refinement
- routing-optimization
- project-lifecycle-coordination
- jira-automation
- confluence-automation
- command-discovery-rule
- assistant-self-testing-limits

### Low Priority (Archived)

Fix archived projects only if reopened:

- \_archived/2025/\* projects

---

## Prevention Strategy

### 1. Pre-Write Checkpoint (Must)

Before adding content to ERD or tasks, ask:

- **"Is this a requirement or an execution step?"**
- **"Does this describe what needs to be true, or what to do?"**

### 2. ERD Template Reminder

Add at top of ERD template:

```markdown
<!-- REQUIREMENTS ONLY
  - No checkboxes ([ ], [x])
  - No status indicators (✅, ❌, ⏳, ⏸️)
  - Acceptance Criteria: conditions for "done", not task lists
  - Rollout: approach/plan, not execution tracking
  - Tasks belong in tasks.md
-->
```

### 3. Automated Validation

Add to rules-validate.sh or create erd-validate.sh:

```bash
# Check for checkboxes in ERD
if grep -E '^- \[(x| )\]' "$erd_file"; then
  echo "ERROR: Checkboxes found in ERD (should be in tasks.md)"
fi

# Check for status indicators
if grep -E '✅|❌|⏳|⏸️' "$erd_file"; then
  echo "WARNING: Status indicators in ERD (execution tracking belongs in tasks.md)"
fi
```

### 4. Review Checklist

When reviewing PRs or completing phases:

- [ ] ERD has no checkboxes or status indicators
- [ ] Acceptance criteria are conditions, not tasks
- [ ] Rollout section is a plan, not execution tracking
- [ ] All execution steps are in tasks.md

---

## Success Criteria

This gap is resolved when:

- [ ] All 19 projects have ERDs rewritten (requirements only)
- [ ] All execution tracking moved to tasks.md
- [ ] Pre-write checkpoint added to workflow
- [ ] Automated validation catches new violations
- [ ] Template includes prevention reminder
- [ ] Zero new violations in next 10 projects created

---

## Meta-Observation

**The investigation itself violates the pattern**: `rules-enforcement-investigation/erd.md` has 4 matches, including detailed task tracking in Acceptance Criteria.

**Implication**: This pattern is so ingrained that even while studying rule enforcement, I violated the ERD/tasks separation rule. This suggests:

1. Awareness alone is insufficient
2. Need pre-write checkpoints (not just post-write validation)
3. Convenience bias is strong (ERD is already open → add content there)

**Learning**: Pattern violations occur even during meta-work about preventing pattern violations. Systemic enforcement mechanisms needed, not just documentation.

---

## Next Actions

1. [ ] Fix rules-enforcement-investigation/erd.md first (meta-priority)
2. [ ] Fix top 5 worst offenders (pr-create-decomposition, self-improvement-\*, rules-docs-quality-detection)
3. [ ] Add automated validation to catch future violations
4. [ ] Update ERD template with prevention reminder
5. [ ] Document pre-write checkpoint in project-lifecycle.mdc

---

## References

- Gap #12 initial discovery: `gap-12-erd-task-separation.md`
- Fixed example: `consent-gates-refinement/erd.md` and `tasks.md`
- Policy source: `project-lifecycle.mdc` (ERD vs tasks separation)
