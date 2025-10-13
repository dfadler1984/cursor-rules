---
status: active
owner: repo-maintainers
lastUpdated: 2025-10-11
---

# Engineering Requirements Document — Project Lifecycle Coordination

## 1. Introduction/Overview

Improve project lifecycle adherence and create simple tooling so the assistant can coordinate conversation, steps, validation, and lifecycle state without manual intervention.

**Context**: User reports issues with unclear project states and adherence to the project lifecycle. Need a streamlined flow with appropriate tooling that makes lifecycle management automatic and transparent.

### Uncertainty / Assumptions

- [NEEDS CLARIFICATION: What specific lifecycle adherence issues have you observed?]
- [NEEDS CLARIFICATION: Are projects getting stuck in certain states, or is state tracking unclear?]
- Assumption: Current lifecycle policy is in `project-lifecycle.mdc` (archived)

## 2. Goals/Objectives

- Make project state transitions automatic and deterministic
- Provide simple tooling for lifecycle operations (create, update, validate, archive)
- Reduce manual coordination burden on assistant and user
- Ensure clear, visible project status at all times
- Integrate validation into natural workflow checkpoints

## 3. User Stories

- As a user, I want to know a project's current state without manual inspection
- As a user, I want lifecycle transitions (active → completed → archived) to happen automatically when criteria are met
- As an assistant, I want to coordinate steps, validation, and lifecycle updates in one flow
- As a maintainer, I want lifecycle compliance to be enforced by tooling, not manual review

## 4. Functional Requirements

### 4.1 State Tracking

1. **Project states**: `planning`, `active`, `paused`, `completed`, `archived`
2. **Auto-detection**: Assistant infers state from ERD/tasks content and completion status
3. **Status visibility**: Projects README auto-updates to reflect current states
4. **State transitions**: Clear criteria for moving between states

### 4.2 Lifecycle Operations

1. **Project creation**

   - Script: `.cursor/scripts/project-create.sh --name <slug> [--mode full|lite]`
   - Output: `docs/projects/<slug>/erd.md` + `tasks.md` from template
   - Auto-add to projects README under "Active"

2. **Task coordination**

   - Assistant checks tasks before starting work
   - Updates task checkboxes as work progresses
   - Validates completion before marking project complete

3. **Completion detection**

   - When all tasks checked → trigger completion flow
   - Generate final summary: `.cursor/scripts/final-summary-generate.sh --project <slug>`
   - Validate artifacts: `.cursor/scripts/project-lifecycle-validate-scoped.sh <slug>`

4. **Archival**
   - Script: `.cursor/scripts/project-archive-workflow.sh --project <slug> --year <YYYY>`
   - Move to `_archived/<YYYY>/`, update links, regenerate README

### 4.3 Validation Integration

1. **Pre-commit validation**: Run scoped lifecycle check before committing project changes
2. **Status check**: Assistant announces project state at start of work
3. **Completion gates**: Block completion if validation fails

## 5. Non-Functional Requirements

- **Automatic**: State transitions happen without explicit user commands
- **Transparent**: Assistant announces state changes and validation results
- **Idempotent**: Running lifecycle operations multiple times is safe
- **Fast**: Validation completes in <5s for typical projects
- **Fail-safe**: Validation errors block risky transitions (e.g., archive incomplete project)

## 6. Architecture/Design

### Current State

- Manual project creation (copy template)
- Manual status updates in projects README
- Manual final summary generation
- Manual archival process
- Validation exists but not integrated into workflow

### Proposed Flow

```
Project Creation
├─ User: "Create project for X"
├─ Assistant: Run project-create.sh → erd.md + tasks.md
├─ Auto-add to projects README
└─ State: planning

Work Phase
├─ Assistant: Check tasks.md before starting
├─ Update checkboxes as work progresses
├─ Run scoped validation before commits
└─ State: active

Completion
├─ All tasks checked → trigger completion flow
├─ Generate final-summary.md
├─ Run project-lifecycle-validate-scoped.sh
├─ Update projects README (active → completed)
└─ State: completed

Archival (when user requests)
├─ Run project-archive-workflow.sh --dry-run (preview)
├─ User approves
├─ Run actual archival
└─ State: archived
```

### Tooling Enhancements

1. **project-create.sh** (new or enhance existing)

   - Create ERD + tasks from template
   - Add to projects README under "Active"
   - Set front matter: `status: active`

2. **project-status.sh** (new)

   - Read front matter status
   - Check task completion %
   - Suggest next action (continue work, validate, complete, archive)

3. **project-complete.sh** (new)

   - Generate final summary
   - Run validation
   - Update status to completed
   - Move in projects README

4. **Integration with existing scripts**
   - `project-lifecycle-validate-scoped.sh` — already exists
   - `project-archive-workflow.sh` — already exists
   - `final-summary-generate.sh` — already exists

## 7. Data Model and Storage

### Project Front Matter (ERD)

```yaml
---
status: planning|active|paused|completed|archived
owner: repo-maintainers|<team>
lastUpdated: YYYY-MM-DD
completedDate: YYYY-MM-DD # when status → completed
archivedDate: YYYY-MM-DD # when moved to _archived
---
```

### Project Status Output

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

## 8. API/Contracts

### project-create.sh

```bash
.cursor/scripts/project-create.sh --name <slug> [--mode full|lite]
# Output: docs/projects/<slug>/erd.md + tasks.md
# Side effect: Add to projects README
```

### project-status.sh

```bash
.cursor/scripts/project-status.sh <slug>
# Output: JSON with status, completion %, next action
```

### project-complete.sh

```bash
.cursor/scripts/project-complete.sh <slug>
# Steps:
# 1. Check all tasks complete
# 2. Generate final summary
# 3. Run validation
# 4. Update status to completed
# 5. Update projects README
```

## 9. Integrations/Dependencies

- Related: `project-lifecycle.mdc` (archived policy)
- Related: `project-lifecycle-docs-hygiene` group
- Scripts (existing):
  - `.cursor/scripts/project-lifecycle-validate-scoped.sh`
  - `.cursor/scripts/project-archive-workflow.sh`
  - `.cursor/scripts/final-summary-generate.sh`
- Scripts (new):
  - `.cursor/scripts/project-create.sh`
  - `.cursor/scripts/project-status.sh`
  - `.cursor/scripts/project-complete.sh`

## 10. Edge Cases and Constraints

- **Incomplete tasks**: User wants to complete project but tasks remain unchecked
- **Failed validation**: Validation fails but user wants to proceed anyway
- **Mid-work archival**: User requests archival of in-progress project
- **State rollback**: Project marked complete but needs more work
- **Multiple projects**: User working on multiple projects simultaneously

## 11. Testing & Acceptance

### Test Cases

1. **Create project**: Run `project-create.sh --name test-proj` → erd.md + tasks.md created, added to README
2. **Status check**: Run `project-status.sh test-proj` → returns status, completion %, next action
3. **Task tracking**: Assistant updates checkboxes as work progresses
4. **Validation gate**: Incomplete tasks → validation fails → completion blocked
5. **Completion flow**: All tasks done → `project-complete.sh` → final summary + status update
6. **Archival**: Run `project-archive-workflow.sh` → project moved to `_archived/2025/`

### Acceptance Criteria

- [ ] Implemented: `project-create.sh`, `project-status.sh`, `project-complete.sh`
- [ ] Integrated: Assistant checks project status before starting work
- [ ] Integrated: Assistant updates tasks.md as work progresses
- [ ] Integrated: Validation runs before lifecycle transitions
- [ ] Tested: Full lifecycle flow (create → work → complete → archive)
- [ ] Validated: Zero manual lifecycle coordination required

## 12. Rollout & Ops

1. Create new scripts: `project-create.sh`, `project-status.sh`, `project-complete.sh`
2. Update assistant rules to use lifecycle scripts automatically
3. Test with new project creation end-to-end
4. Migrate existing active projects to new front matter format
5. Monitor for 1 week and adjust based on feedback

## 13. Success Metrics

### Objective Measures

- **Automation rate**: % of lifecycle transitions handled by tooling (target: >90%)
- **Validation compliance**: % of projects passing validation before completion (target: 100%)
- **Manual intervention**: # of times user has to manually update project status (target: <5% of projects)
- **Completion time**: Avg time from all-tasks-done to completed state (target: <5 minutes)

### Qualitative Signals

- User reports clearer project states
- Assistant coordinates lifecycle smoothly without prompting
- No confusion about what step comes next
- Projects don't get stuck in stale states

## 14. Open Questions

1. **State inference**: Should assistant auto-detect state from tasks, or always trust front matter?
2. **Completion override**: Should users be able to complete projects with incomplete tasks?
3. **Validation strictness**: Should failed validation block completion (hard gate) or warn (soft gate)?
4. **Multi-project workflow**: How to handle user working on multiple projects in one session?
5. **Rollback**: If a completed project needs more work, what's the rollback flow?

---

Owner: repo-maintainers  
Created: 2025-10-11  
Motivation: Issues with unclear project states and lifecycle adherence; need simple flow with tooling for automatic coordination
