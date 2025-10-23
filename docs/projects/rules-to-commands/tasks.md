## Tasks — Rules to Commands Conversion

**Status**: ACTIVE | Phase: Implementation | ~20% Complete

---

## Phase 1: Analysis ✅

- [x] 1.0 Review all rules and identify candidates
  - [x] 1.1 Read all `.cursor/rules/*.mdc` files
  - [x] 1.2 Categorize by purpose (behavioral vs procedural)
  - [x] 1.3 Create decision framework
  - [x] 1.4 Document high-priority candidates
  - [x] 1.5 Create analysis document

## Phase 2: Create High-Priority Commands

- [ ] 2.0 Create `/erd` command

  - [ ] 2.1 Create `.cursor/commands/erd.md`
  - [ ] 2.2 Extract workflow from `create-erd.mdc`
  - [ ] 2.3 Add usage examples (Full vs Lite)
  - [ ] 2.4 Test command invocation
  - [ ] 2.5 Update `create-erd.mdc` with command reference

- [ ] 3.0 Create `/tasks` command

  - [ ] 3.1 Create `.cursor/commands/tasks.md`
  - [ ] 3.2 Extract two-phase workflow from `generate-tasks-from-erd.mdc`
  - [ ] 3.3 Add usage examples
  - [ ] 3.4 Test command invocation
  - [ ] 3.5 Update `generate-tasks-from-erd.mdc` with command reference

- [ ] 4.0 Create `/investigation` command

  - [ ] 4.1 Create `.cursor/commands/investigation.md`
  - [ ] 4.2 Extract structure guidance from `investigation-structure.mdc`
  - [ ] 4.3 Add folder scaffolding examples
  - [ ] 4.4 Test command invocation
  - [ ] 4.5 Update `investigation-structure.mdc` with command reference

- [ ] 5.0 Create `/test-plan` command
  - [ ] 5.1 Create `.cursor/commands/test-plan.md`
  - [ ] 5.2 Extract 7-section template from `test-plan-template.mdc`
  - [ ] 5.3 Add usage examples
  - [ ] 5.4 Test command invocation
  - [ ] 5.5 Update `test-plan-template.mdc` with command reference

## Phase 3: Update Original Rules

- [ ] 6.0 Slim down behavioral rules

  - [ ] 6.1 Review `create-erd.mdc` (keep scope enforcement, reference command)
  - [ ] 6.2 Review `generate-tasks-from-erd.mdc` (keep task format rules)
  - [ ] 6.3 Review `investigation-structure.mdc` (keep structure validation)
  - [ ] 6.4 Review `test-plan-template.mdc` (keep section requirements)

- [ ] 7.0 Update rule cross-references
  - [ ] 7.1 Update `spec-driven.mdc` to reference commands
  - [ ] 7.2 Update `deterministic-outputs.mdc` if needed
  - [ ] 7.3 Update `project-lifecycle.mdc` to mention commands
  - [ ] 7.4 Validate all cross-references resolve

## Phase 4: Documentation & Integration

- [ ] 8.0 Update capabilities documentation

  - [ ] 8.1 Update `capabilities.mdc` with new commands
  - [ ] 8.2 Add command examples to capability descriptions
  - [ ] 8.3 Update `lastReviewed` dates

- [ ] 9.0 Create usage guide

  - [ ] 9.1 Document when to use commands vs rules
  - [ ] 9.2 Add examples of command workflows
  - [ ] 9.3 Add troubleshooting section

- [ ] 10.0 Validate implementation
  - [ ] 10.1 Test each command in Cursor
  - [ ] 10.2 Verify workflow completion
  - [ ] 10.3 Check cross-references resolve
  - [ ] 10.4 Run rules validation script

## Phase 5: Measurement & Iteration

- [ ] 11.0 Measure adoption (over 20-30 operations)

  - [ ] 11.1 Track command usage rate
  - [ ] 11.2 Track workflow completion rate
  - [ ] 11.3 Collect user feedback
  - [ ] 11.4 Measure context efficiency improvements

- [ ] 12.0 Iterate based on data
  - [ ] 12.1 Identify additional command candidates
  - [ ] 12.2 Refine existing commands based on feedback
  - [ ] 12.3 Update documentation with learnings
  - [ ] 12.4 Create follow-up tasks if needed

---

## Relevant Files

### Rules to Review/Update

- `.cursor/rules/create-erd.mdc` — ERD creation workflow
- `.cursor/rules/generate-tasks-from-erd.mdc` — Task generation workflow
- `.cursor/rules/investigation-structure.mdc` — Investigation scaffolding
- `.cursor/rules/test-plan-template.mdc` — Test plan template
- `.cursor/rules/spec-driven.mdc` — References ERD/tasks workflow
- `.cursor/rules/deterministic-outputs.mdc` — References specs/plans/tasks
- `.cursor/rules/capabilities.mdc` — Needs updates with new commands

### Commands to Create

- `.cursor/commands/erd.md` — Create ERD command
- `.cursor/commands/tasks.md` — Generate tasks command
- `.cursor/commands/investigation.md` — Create investigation project
- `.cursor/commands/test-plan.md` — Create test plan

### Project Documentation

- `docs/projects/rules-to-commands/README.md` — Entry point
- `docs/projects/rules-to-commands/erd.md` — Full requirements
- `docs/projects/rules-to-commands/command-candidates-analysis.md` — Detailed analysis

### Reference

- Existing `/project` command for pattern reference
- [Cursor Commands Documentation](https://cursor.com/docs/agent/chat/commands)

---

## Notes

- Commands are user-initiated (zero context cost until invoked)
- Rules provide behavioral enforcement (remain in context when needed)
- Both systems work together (commands guide, rules enforce)
- Commands improve discoverability via `/` prefix
- Gradual transition (keep rules functional during implementation)
