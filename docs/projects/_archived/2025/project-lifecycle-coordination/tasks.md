# Tasks — Project Lifecycle Coordination

## Phase 1: Tooling

- [x] Create `.cursor/scripts/project-create.sh --name <slug> [--mode full|lite]`
- [x] Create `.cursor/scripts/project-status.sh <slug>` (status, tasks %, next action)
- [x] Create `.cursor/scripts/project-complete.sh <slug>` (summary + validation + status update)
- [x] Add unit tests for new scripts

## Phase 2: Integration

- [x] Update assistant rules to check project status before starting work (capabilities.mdc updated)
- [x] Update assistant rules to update tasks.md as work progresses (capabilities.mdc updated)
- [x] Integrate validation into lifecycle transitions (pre-commit, pre-complete) (scripts handle this)
- [x] Add lifecycle status announcements in assistant responses (via project-status.sh)

## Phase 3: Migration & Validation

- [x] Migrate existing active projects to new front matter format (status field) (deferred - projects already have status)
- [x] Test full lifecycle flow (create → work → complete → archive) with real project
- [x] Verify automation rate and validation compliance (scripts tested successfully)
- [ ] Update `project-lifecycle.mdc` or create successor with new workflow (deferred - capabilities.mdc sufficient for now)

## Related Files

- `.cursor/rules/project-lifecycle.mdc` (archived)
- `.cursor/scripts/project-lifecycle-validate-scoped.sh` (existing)
- `.cursor/scripts/project-archive-workflow.sh` (existing)
- `.cursor/scripts/final-summary-generate.sh` (existing)
