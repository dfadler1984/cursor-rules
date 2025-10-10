# Tasks — Project Lifecycle Hardening (Parent Level)

## Parent Tasks

- [x] Create canonical templates under `.cursor/templates/project-lifecycle/` [P]
- [x] Update `project-lifecycle` rule to encode usage and completion policy
- [x] Implement scoped CI validator + tests under `.cursor/scripts/`
- [x] Update `docs/projects/README.md` with Active/Completed index entries
- [x] Migrate existing `project-lifecycle` experiment to use canonical templates
- [x] Define and document archival path `docs/projects/_archived/<YYYY>/<project>/`
- [x] Add retrospective/metrics requirements to closeout flow
- [x] Add guidance for finalizing PR titles to land in `CHANGELOG.md`

## Relevant Files

- `.cursor/templates/project-lifecycle/*.template.md`
- `.cursor/rules/project-lifecycle.mdc`
- `.cursor/scripts/validate-project-lifecycle.sh`
- `.cursor/scripts/validate-project-lifecycle.test.sh`
- `docs/projects/README.md`
- `docs/projects/project-lifecycle/`
- `docs/projects/_archived/`

## Remaining Work

- [x] Create `.cursor/templates/project-lifecycle/final-summary.template.md` with front matter and Impact/Retrospective sections
- [x] Create `.cursor/templates/project-lifecycle/completion-checklist.template.md` with front matter
- [x] Create `.cursor/templates/project-lifecycle/retrospective.template.md` with front matter
- [x] Author `.cursor/rules/project-lifecycle.mdc` documenting template usage, completion criteria, and PR title guidance
- [x] Implement `.cursor/scripts/validate-project-lifecycle.sh` scoped to changed projects (checks: final-summary front matter + Impact, tasks checked or Carryovers, retrospective present, no templates under project)
- [x] Add `.cursor/scripts/validate-project-lifecycle.test.sh` with pass/fail and warning scenarios
- [x] Update `docs/projects/README.md` to ensure Completed index links to each project's `final-summary.md`
- [ ] Migrate existing projects to the canonical templates and add required front matter/sections
- [x] Decide validator strictness for PR title semantics (warn vs fail) and document in rule
- [x] Decide index generation approach (manual vs auto) and document in rule

## New Tasks from Findings

### High Impact

- [x] Clarify validator roles and names; add cross-links in rule and scripts (names adopted: `project-lifecycle-validate-scoped.sh`, `project-lifecycle-validate-sweep.sh`)
  - Owner: rules-maintainers
  - Outcome: unambiguous scoped vs sweep validators with distinct names
- [x] Fix README link policy checks in sweep validator (accept archived `final-summary.md` post-move; allow pre-move `./<name>/erd.md` transiently)
- [x] Align generator/template: simplify generator subs to title/date/links; tests updated accordingly
- [x] Align workflow default with rule (prefer post-move); test updated; Completed index line points to `final-summary.md`

### Medium Impact

- [x] Update migration policy: prefer `final-summary-generate.sh --pre-move`; document exception when structure is missing
- [x] Harden scoped validator: strict front-matter block detection; optional PR title flag/env; update rule usage examples
- [x] Add optional post-archive README Completed verification to archive workflow
- [x] Decide fate of `archive-redirect.template.md`: document usage or remove
- [x] Expand `validate-project-lifecycle.sh` tests: Impact missing, carryovers behavior, retrospective-as-section

### Low Impact

- [x] Relax regex anchors in scoped validator for FM fields; optionally check `last-updated`
- [x] Improve diagnostics with file paths and suggested fixes
