## Relevant Files

- `docs/projects/ai-workflow-integration/erd.md` - Canonical ERD (Full)
- `docs/projects/ai-workflow-integration/discussions.md` - Deep-dive notes
- `docs/projects/ai-workflow-integration/comparison-framework.md` - Scope & evaluation criteria
- `.cursor/rules/create-erd.mdc` - ERD generation rule
- `.cursor/rules/erd-full.md` - Full ERD template
- `.cursor/rules/erd-lite.md` - Lite ERD template
- `.cursor/rules/generate-tasks-from-erd.mdc` - Tasks generation rule
- `.cursor/rules/spec-driven.mdc` - Spec‑Driven workflow
- `.cursor/rules/task-list-process.mdc` - Task execution protocol
- `.cursor/rules/logging-protocol.mdc` - Assistant learning logs (authoritative)

### Notes

- Optional fields (dependencies/priority/[P]) are additive and controlled by feature flags.

## Tasks

- [x] 1.0 Establish comparison framework (scope, criteria, artifacts) (priority: high)

  - [x] 1.1 Define evaluation criteria: setup, slash‑commands, tasks structure, dependencies/priority, logging, licensing
  - [x] 1.2 Map our current rules to the criteria and identify coverage
  - [x] 1.3 Record baseline and scope in `discussions.md`

- [x] 2.0 Evaluate ai-dev-tasks for PRD/tasks process portability [P] (priority: medium) (depends on: 1.0)

  - [x] 2.1 Review `create-prd.md`; capture strengths/gaps vs `create-erd.mdc`
  - [x] 2.2 Review `generate-tasks.md`; compare with `generate-tasks-from-erd.mdc`
  - [x] 2.3 Review `process-task-list.md`; compare with `task-list-process.mdc`
  - [x] 2.4 Propose importable snippets/citations and minimal diffs

- [x] 3.0 Evaluate spec-kit SDD slash-commands for our workflow [P] (priority: medium) (depends on: 1.0)

  - [x] 3.1 Review `spec-driven.md` and `templates/commands/*`
  - [x] 3.2 Specify minimal optional slash‑command support in `spec-driven.mdc`
  - [x] 3.3 Define `/analyze` gate behavior and wording
  - [x] 3.4 Decide on feasibility of `memory/constitution.md` pattern

- [x] 4.0 Evaluate Taskmaster task/dependency model and research hooks [P] (priority: medium) (depends on: 1.0)

  - [x] 4.1 Review `docs/task-structure.md` for `dependencies`/`priority` and `[P]`
  - [x] 4.2 Identify minimal, optional additions to `generate-tasks-from-erd.mdc`
  - [x] 4.3 Review `src/progress/*` and `mcp-server/src/logger.js` for operational metrics patterns
  - [x] 4.4 Draft logging additions: Operation block (elapsed, token I/O), Dependency Impact section

- [x] 5.0 Draft integration approach and candidate rule edits (priority: high) (depends on: 2.0, 3.0, 4.0)

  - [x] 5.1 Update `create-erd.mdc` (uncertainty markers, optional slash‑command note)
  - [x] 5.2 Update `erd-full.md` and `erd-lite.md` (add Uncertainty/Assumptions subsection)
  - [x] 5.3 Update `generate-tasks-from-erd.mdc` (deps/priority/[P] optional fields)
  - [x] 5.4 Update `task-list-process.mdc` (dependency/priority‑aware next step)
  - [x] 5.5 Update `spec-driven.mdc` (slash‑commands + `/analyze` gate + cross‑links)
  - [x] 5.6 Update logging rule (now `logging-protocol.mdc`) with Operation block + Dependency Impact

- [ ] 6.0 Review, iterate, and finalize adoption plan (priority: medium) (depends on: 5.0)
  - [x] 6.1 Validate rule front‑matter and references (rules validation script)
  - [x] 6.2 Stakeholder review and wording adjustments
  - [ ] 6.3 Remove feature flags concept (unified defaults: commands, deps/priority/[P], always-on logging)
  - [ ] 6.4 Update README/docs to state unified defaults (no toggles)
  - [x] 6.5 Publish adoption plan in `discussions.md`
