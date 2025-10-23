# Implementation Plan — Project Lifecycle Coordination

**Created**: 2025-10-23  
**Status**: Planning

---

## 1. Answers to Open Questions

### Q1: State inference — auto-detect from tasks vs trust front matter?

**Decision**: Trust front matter as source of truth; provide validation warnings.

**Rationale**:

- Front matter is explicit and version-controlled
- Auto-detection can be ambiguous (e.g., 90% done but paused)
- Validation scripts can detect drift (status=active but all tasks done)
- Assistant can suggest state transitions based on task completion

**Implementation**:

- `project-status.sh` reads front matter `status` field
- Outputs warning if mismatch detected (e.g., status=active, 100% tasks complete)
- Suggests: "All tasks complete. Consider running: project-complete.sh <slug>"

---

### Q2: Completion override — allow incomplete tasks?

**Decision**: Soft gate with explicit override flag.

**Rationale**:

- Incomplete tasks may be intentional (deferred, out-of-scope)
- Hard block frustrates users with valid edge cases
- Override leaves audit trail

**Implementation**:

- `project-complete.sh` checks task completion %
- If <100%, prints warning and requires `--force` flag
- With `--force`: adds note to final-summary.md: "Completed with N tasks incomplete"
- Logs to stderr: "Warning: completing with incomplete tasks"

---

### Q3: Validation strictness — hard gate or soft warning?

**Decision**: Soft gate (warn but don't block) for most validations; hard block only for critical issues.

**Rationale**:

- Hard blocks can create false positives (edge cases, temporary states)
- Soft warnings keep workflow moving while surfacing issues
- Hard blocks reserved for data-loss risks (missing ERD, invalid front matter)

**Implementation**:

- **Hard blocks** (exit 1):
  - Missing required files (erd.md, tasks.md)
  - Invalid front matter (missing status/owner)
  - Archive target already exists (prevent overwrite)
- **Soft warnings** (exit 0, stderr message):
  - Broken links
  - Stale lastUpdated
  - Incomplete tasks on completion (requires --force)

---

### Q4: Multi-project workflow — handle multiple projects in one session?

**Decision**: No special handling; treat independently.

**Rationale**:

- Adding cross-project coordination increases complexity
- Most work sessions focus on one project
- Users can switch contexts manually

**Implementation**:

- Assistant announces project context when switching: "Switching to project: <slug>"
- `project-status.sh` operates on single project; no multi-project state
- Future enhancement: `project-status.sh --all` for dashboard view

---

### Q5: Rollback — reopening completed projects?

**Decision**: Manual process with explicit steps.

**Rationale**:

- Rollback should be rare and deliberate
- Automated rollback risks confusion and state thrashing
- Explicit steps create audit trail

**Implementation**:

1. User manually updates front matter: `status: completed` → `status: active`
2. Updates `docs/projects/README.md` index (move from Completed → Active)
3. Removes or updates `final-summary.md` if needed
4. Adds entry to `tasks.md` explaining why project was reopened

No script provided initially; can be added if pattern emerges.

---

## 2. Script Design

### project-create.sh

**Purpose**: Create new project directory and files from templates.

**Arguments**:

```bash
project-create.sh --name <slug> [--mode full|lite] [--owner <owner>] [--root <path>]
```

**Behavior**:

1. Validate: slug is kebab-case, directory doesn't exist
2. Create: `docs/projects/<slug>/`
3. Generate:
   - `erd.md` with front matter (status=planning, owner, created date)
   - `tasks.md` with placeholder structure
   - `README.md` with navigation links
4. Output: Paths created, suggest next steps

**Templates**:

- ERD: inline template (Full vs Lite based on --mode)
- Tasks: inline minimal structure
- README: inline navigation template

**Exit codes**:

- 0: success
- 1: validation error (slug invalid, dir exists)
- 2: usage error

---

### project-status.sh

**Purpose**: Query project status, completion percentage, suggest next action.

**Arguments**:

```bash
project-status.sh <slug> [--format json|text] [--root <path>]
```

**Behavior**:

1. Read: `docs/projects/<slug>/erd.md` front matter
2. Count: tasks in `tasks.md` (total vs completed checkboxes)
3. Detect: mismatches (status vs completion %)
4. Output: status, completion %, next action suggestion
5. Exit: 0 (always; informational only)

**Output (text)**:

```
Project: example-project
Status: active
Tasks: 8/12 complete (67%)
Next action: continue work
Suggestion: 4 tasks remaining before completion
```

**Output (JSON)**:

```json
{
  "slug": "example-project",
  "status": "active",
  "tasksTotal": 12,
  "tasksCompleted": 8,
  "completionPct": 67,
  "nextAction": "continue work",
  "validationStatus": "passing"
}
```

**Next action logic**:

- <100% tasks + status=active → "continue work"
- 100% tasks + status=active → "run project-complete.sh"
- status=completed → "project complete; consider archiving"
- status=paused → "project paused; resume or close"

---

### project-complete.sh

**Purpose**: Orchestrate completion workflow (validate → summary → status update).

**Arguments**:

```bash
project-complete.sh <slug> [--force] [--dry-run] [--root <path>] [--date <YYYY-MM-DD>]
```

**Behavior**:

1. Validate:
   - All tasks checked (or --force provided)
   - Validation passes (rules, lifecycle)
2. Generate: final-summary.md (pre-move mode)
3. Update: ERD front matter (status=completed, completedDate=<date>)
4. Output: Next steps (update README index, consider archiving)
5. Dry-run: preview actions without executing

**Exit codes**:

- 0: success
- 1: validation failed (missing tasks, validation errors)
- 2: usage error

**Workflow**:

```
1. Check task completion
   ├─ <100% → require --force
   └─ 100% → proceed

2. Run validation
   ├─ project-lifecycle-validate-scoped.sh <slug>
   └─ exit 1 if validation fails (hard errors only)

3. Generate summary
   └─ final-summary-generate.sh --project <slug> --year <current-year> --pre-move

4. Update front matter
   ├─ sed or in-place edit: status → completed
   └─ Add: completedDate: <date>

5. Print next steps
   ├─ Update docs/projects/README.md (move to Completed section)
   └─ Consider: project-archive-workflow.sh --project <slug> --year <YYYY>
```

---

## 3. Template Design

### ERD Template (Full)

```markdown
---
status: planning
owner: <owner>
created: <YYYY-MM-DD>
lastUpdated: <YYYY-MM-DD>
---

# Engineering Requirements Document — <Project Name>

## 1. Introduction/Overview

<One-paragraph overview of the problem and proposed solution.>

## 2. Goals/Objectives

- <Primary goal 1>
- <Primary goal 2>

## 3. User Stories

- As a <persona>, I want <capability> so that <benefit>

## 4. Functional Requirements

1. <Requirement 1>
2. <Requirement 2>

## 5. Non-Functional Requirements

- **Performance**: <targets>
- **Reliability**: <targets>
- **Security**: <considerations>

## 6. Architecture/Design

<High-level approach, patterns, components>

## 7. Data Model and Storage

<Schemas, migrations, retention>

## 8. API/Contracts

<Endpoints, events, contracts>

## 9. Integrations/Dependencies

- <External systems>
- <Related projects>

## 10. Edge Cases and Constraints

- <Edge case 1>
- <Constraint 1>

## 11. Testing & Acceptance

<Narrative acceptance criteria; NOT checklists>

## 12. Rollout & Ops

<Feature flags, monitoring, rollback>

## 13. Success Metrics

- <Metric 1>: <target>

## 14. Open Questions

1. <Question 1>?
2. <Question 2>?
```

### ERD Template (Lite)

```markdown
---
status: planning
owner: <owner>
created: <YYYY-MM-DD>
lastUpdated: <YYYY-MM-DD>
---

# Engineering Requirements Document — <Project Name> (Lite)

## 1. Introduction/Overview

<1-2 paragraph overview>

## 2. Goals/Objectives

- <Goal 1>
- <Goal 2>

## 3. Functional Requirements

1. <Requirement 1>
2. <Requirement 2>

## 4. Acceptance Criteria

- <Criterion 1>
- <Criterion 2>

## 5. Risks/Edge Cases

- <Risk 1>
- <Edge case 1>

## 6. Rollout

<Owner, flag, target date>
```

### Tasks Template

```markdown
# Tasks — <Project Name>

## Relevant Files

- `docs/projects/<slug>/erd.md` — Requirements
- `docs/projects/<slug>/tasks.md` — This file

## Phase 1: <Phase Name>

- [ ] 1.0 <Parent task>
  - [ ] 1.1 <Sub-task>
  - [ ] 1.2 <Sub-task>

## Phase 2: <Phase Name>

- [ ] 2.0 <Parent task>
  - [ ] 2.1 <Sub-task>

## Notes

<Optional notes or decisions>
```

### README Template

```markdown
# <Project Name>

**Status**: Planning | Active | Completed | Archived  
**Owner**: <owner>

## Quick Links

- [ERD](./erd.md) — Requirements and design
- [Tasks](./tasks.md) — Execution tracking
- [Final Summary](./final-summary.md) — Outcomes (completed projects only)

## Overview

<One-paragraph project description>

## Related

- <Related project or doc>
```

---

## 4. Implementation Order

### Phase 1: Scripts (TDD)

1. **project-create.sh**

   - Red: Create test for directory creation, front matter generation
   - Green: Implement core logic
   - Refactor: Extract template helpers

2. **project-status.sh**

   - Red: Test status parsing, task counting, next action logic
   - Green: Implement
   - Refactor: Extract pure resolver for task counting

3. **project-complete.sh**
   - Red: Test validation flow, dry-run mode
   - Green: Implement orchestration
   - Refactor: Modularize validation checks

### Phase 2: Integration

1. Update `.cursor/rules/project-lifecycle.mdc` with new script references
2. Add lifecycle coordination to relevant rules (intent-routing, assistant-behavior)
3. Test end-to-end workflow with a real project

### Phase 3: Migration & Validation

1. Migrate 2-3 existing projects to validate tooling
2. Run full lifecycle flow (create → work → complete → archive)
3. Document any edge cases or refinements needed

---

## 5. Testing Strategy

### Script Tests (Shell)

Each script gets colocated `*.test.sh`:

- Argument parsing (missing args, invalid values)
- Exit codes (success, validation errors, usage errors)
- File generation (templates, front matter, paths)
- Dry-run mode (no side effects)

### Integration Tests

- Create project → verify directory structure
- Complete project → verify status updated, summary generated
- Archive workflow → verify full lifecycle

### Manual Validation

- Test with 1-2 real projects
- Verify assistant can coordinate lifecycle without user intervention
- Check for UX friction points

---

## 6. Documentation Updates

1. Update `docs/projects/README.md` with script usage
2. Add lifecycle examples to `.cursor/docs/guides/`
3. Update `capabilities.mdc` with new scripts
4. Link lifecycle scripts in relevant rules

---

## 7. Risks & Mitigations

| Risk                              | Mitigation                                       |
| --------------------------------- | ------------------------------------------------ |
| Scripts don't handle edge cases   | Soft gates, explicit error messages              |
| Front matter drift (manual edits) | Validation warnings                              |
| Users skip lifecycle scripts      | Assistant prompts at natural checkpoints         |
| Template inflexibility            | Inline templates (easy to customize per project) |
| Multi-project confusion           | Clear project context announcements              |

---

## Next Steps

1. Review this plan with user
2. Get confirmation on open question decisions
3. Proceed to Phase 1: implement scripts with TDD
