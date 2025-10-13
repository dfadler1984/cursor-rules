# Tasks — Project Lifecycle Coordination

## Phase 1: Tooling

- [ ] Create `.cursor/scripts/project-create.sh --name <slug> [--mode full|lite]`
- [ ] Create `.cursor/scripts/project-status.sh <slug>` (status, tasks %, next action)
- [ ] Create `.cursor/scripts/project-complete.sh <slug>` (summary + validation + status update)
- [ ] Add unit tests for new scripts

## Phase 2: Integration

- [ ] Update assistant rules to check project status before starting work
- [ ] Update assistant rules to update tasks.md as work progresses
- [ ] Integrate validation into lifecycle transitions (pre-commit, pre-complete)
- [ ] Add lifecycle status announcements in assistant responses

## Phase 3: Migration & Validation

- [ ] Migrate existing active projects to new front matter format (status field)
- [ ] Test full lifecycle flow (create → work → complete → archive) with real project
- [ ] Verify automation rate and validation compliance
- [ ] Update `project-lifecycle.mdc` or create successor with new workflow

## Related Files

- `.cursor/rules/project-lifecycle.mdc` (archived)
- `.cursor/scripts/project-lifecycle-validate-scoped.sh` (existing)
- `.cursor/scripts/project-archive-workflow.sh` (existing)
- `.cursor/scripts/final-summary-generate.sh` (existing)
