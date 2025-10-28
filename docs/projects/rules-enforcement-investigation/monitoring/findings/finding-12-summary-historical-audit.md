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

# Gap #12 Summary — ERD/Tasks Separation

**Self-improvement action**: Corrected systemic ERD/tasks violation across repository

---

## What Happened

While completing Phase 2 of consent-gates-refinement, user identified that I was **mixing task execution tracking into ERD documents** instead of keeping them in tasks.md.

**Root cause**: Conflating requirements (what needs to be true) with execution (what to do)

---

## Audit Results

**Scope**: All active projects in `docs/projects/`

**Found**: **172 checkbox/status indicator matches across 19 ERD files**

**Pattern violations**:

1. Checkboxes in ERD files (`- [ ]`, `- [x]`)
2. Status indicators (✅, ❌, ⏳, ⏸️)
3. Task tracking in Acceptance Criteria or Rollout sections
4. Execution steps in Functional Requirements

---

## Immediate Corrections Made

### 1. consent-gates-refinement (Gap #12 example)

- ✅ ERD Section 11 (Acceptance Criteria): Rewritten as conditions ("The solution is complete when...")
- ✅ ERD Section 12 (Rollout & Ops → Rollout Plan): Now describes approach/phases/gates
- ✅ All execution tracking moved to tasks.md Phase 3/4

### 2. rules-enforcement-investigation (Meta-fix)

**Meta-irony**: The investigation studying rule enforcement violations itself violated the ERD/tasks separation rule.

- ✅ ERD Section 4 Phase 6: Removed "Completed (Week 0)" and "Remaining Work" task lists
- ✅ ERD Section 5 (Acceptance Criteria): Removed all status indicators (✅, ❌, ⏳, ⏸️), rewritten as conditions
- ✅ Execution tracking remains correctly in tasks.md

---

## Documentation Created

1. **`gap-12-erd-task-separation.md`** — Initial discovery, root cause analysis, corrective actions
2. **`gap-12-audit-results.md`** — Comprehensive audit of 19 projects, 172 violations found
3. **`gap-12-summary.md`** — This summary document

---

## Key Learnings

1. **Awareness ≠ Compliance**: I knew the rule but didn't consistently apply it
2. **Convenience bias**: ERD was already open → easier to add content there
3. **Visibility bias**: Wanted to show progress in the "main" document
4. **Meta-failure**: Violated the pattern even while investigating rule enforcement

---

## Prevention Strategy

### 1. Pre-Write Checkpoint (Must Add)

Before adding content to ERD or tasks, ask:

- **"Is this a requirement or an execution step?"**
- **"Does this describe what needs to be true, or what to do?"**

### 2. ERD Template Reminder (To Add)

```markdown
<!-- REQUIREMENTS ONLY
  - No checkboxes ([ ], [x])
  - No status indicators (✅, ❌, ⏳, ⏸️)
  - Acceptance Criteria: conditions for "done", not task lists
  - Rollout: approach/plan, not execution tracking
  - Tasks belong in tasks.md
-->
```

### 3. Automated Validation (To Add)

Extend rules-validate.sh or create erd-validate.sh to catch violations.

---

## Remaining Work

**High priority** (active projects with most violations):

- pr-create-decomposition (21 matches)
- self-improvement-rule-adoption (18 matches)
- self-improvement-pivot (17 matches)
- rules-docs-quality-detection (14 matches)

**Medium priority**: 11 other active projects

**Low priority**: 3 archived projects

---

## Success Criteria

This gap is resolved when:

- [ ] All 19 projects have ERDs rewritten (requirements only)
- [ ] Pre-write checkpoint added to workflow
- [ ] Automated validation catches new violations
- [ ] Template includes prevention reminder
- [ ] Zero new violations in next 10 projects created

---

## Meta-Observation

**Pattern**: Even while studying rule enforcement gaps, I violated the ERD/tasks separation rule in the investigation's own ERD.

**Implication**: Awareness alone is insufficient. Need pre-write checkpoints and automated validation, not just documentation.

---

## Related

- `consent-gates-refinement/erd.md` — Fixed example
- `consent-gates-refinement/tasks.md` — Execution tracking properly placed
- `rules-enforcement-investigation/erd.md` — Meta-fix applied
- `rules-enforcement-investigation/findings/gap-12-erd-task-separation.md` — Initial finding
- `rules-enforcement-investigation/findings/gap-12-audit-results.md` — Full audit
- `project-lifecycle.mdc` — Policy source
