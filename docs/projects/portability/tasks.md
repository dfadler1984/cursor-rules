## Tasks — Portability Taxonomy

**Status**: ACTIVE | Phase: Definition | ~0% Complete

---

## Phase 1: Definition & Schema

- [ ] 1.0 Define taxonomy

  - [ ] 1.1 Define "portable" criteria (zero config vs parameterizable vs template)
  - [ ] 1.2 Define "project-specific" criteria
  - [ ] 1.3 Define "hybrid" criteria and marking strategy
  - [ ] 1.4 Document portability assumptions (folder structure, conventions, etc.)
  - [ ] 1.5 Create `portability.mdc` rule with taxonomy and examples

- [ ] 2.0 Update front-matter schema

  - [ ] 2.1 Add `portability` field to schema (`portable | project-specific | hybrid`)
  - [ ] 2.2 Add optional `portabilityNotes` field for assumptions/requirements
  - [ ] 2.3 Update `front-matter.mdc` with new fields
  - [ ] 2.4 Update examples in `front-matter.mdc`

- [ ] 3.0 Update validation tooling
  - [ ] 3.1 Update `rules-validate.sh` to check `portability` field
  - [ ] 3.2 Add validation for `portabilityNotes` when `portability: hybrid`
  - [ ] 3.3 Add test coverage for new validations
  - [ ] 3.4 Run validator against existing rules (expect failures)

---

## Phase 2: Backfill Core Artifacts

- [ ] 4.0 Mark core portable rules

  - [ ] 4.1 `tdd-first.mdc` → portable
  - [ ] 4.2 `code-style.mdc` → portable
  - [ ] 4.3 `testing.mdc` → portable
  - [ ] 4.4 `shell-unix-philosophy.mdc` → portable
  - [ ] 4.5 `imports.mdc` → portable
  - [ ] 4.6 `assistant-git-usage.mdc` → portable (or hybrid?)
  - [ ] 4.7 `refactoring.mdc` → portable
  - [ ] 4.8 `security.mdc` → portable
  - [ ] 4.9 `dependencies.mdc` → portable
  - [ ] 4.10 `direct-answers.mdc` → portable

- [ ] 5.0 Mark project-specific rules

  - [ ] 5.1 `project-lifecycle.mdc` → project-specific
  - [ ] 5.2 `investigation-structure.mdc` → project-specific
  - [ ] 5.3 `rule-creation.mdc` → project-specific
  - [ ] 5.4 `rule-maintenance.mdc` → project-specific
  - [ ] 5.5 `front-matter.mdc` → project-specific

- [ ] 6.0 Mark portable scripts

  - [ ] 6.1 `git-commit.sh` → portable
  - [ ] 6.2 `git-branch-name.sh` → portable (or hybrid?)
  - [ ] 6.3 `pr-create.sh` → portable
  - [ ] 6.4 `pr-update.sh` → portable
  - [ ] 6.5 `shellcheck-run.sh` → portable

- [ ] 7.0 Mark project-specific scripts
  - [ ] 7.1 `project-archive-workflow.sh` → project-specific
  - [ ] 7.2 `rules-validate.sh` → project-specific (or hybrid?)
  - [ ] 7.3 `project-lifecycle-validate-scoped.sh` → project-specific
  - [ ] 7.4 `erd-validate.sh` → hybrid (pattern portable, impl project-specific)

---

## Phase 3: Full Backfill & Tooling

- [ ] 8.0 Categorize remaining rules

  - [ ] 8.1 Audit all rules in `.cursor/rules/`
  - [ ] 8.2 Mark each with appropriate `portability` field
  - [ ] 8.3 Add `portabilityNotes` where needed
  - [ ] 8.4 Run validation to confirm completeness

- [ ] 9.0 Categorize remaining scripts

  - [ ] 9.1 Audit all scripts in `.cursor/scripts/`
  - [ ] 9.2 Add front matter with `portability` field (or use comment header)
  - [ ] 9.3 Document assumptions for hybrid scripts

- [ ] 10.0 Add filtering/querying capability

  - [ ] 10.1 Update `rules-list.sh` to support `--portability <filter>` flag
  - [ ] 10.2 Update `capabilities.mdc` to group by portability
  - [ ] 10.3 Add portability summary to `rules-list.sh` output
  - [ ] 10.4 Test filtering with various queries

- [ ] 11.0 Documentation & validation
  - [ ] 11.1 Update `README.md` to reference portability taxonomy
  - [ ] 11.2 Add portability section to `capabilities.mdc`
  - [ ] 11.3 Run full validation sweep (`rules-validate.sh --all`)
  - [ ] 11.4 Document migration path for future extraction

---

## Relevant Files

**Rules**:

- `.cursor/rules/front-matter.mdc` — Front matter structure
- `.cursor/rules/rule-creation.mdc` — Rule authoring
- `.cursor/rules/capabilities.mdc` — Capabilities listing

**Scripts**:

- `.cursor/scripts/rules-validate.sh` — Validation tooling
- `.cursor/scripts/rules-list.sh` — Listing tooling

**Docs**:

- `docs/projects/portability/erd.md` — This project's requirements
- `docs/projects/portability/README.md` — This project's entry point

---

## Nested Project Dependencies

### Enterprise Toolkit Phase

See [`phases/enterprise-toolkit/tasks.md`](phases/enterprise-toolkit/tasks.md) for:

- Config system implementation
- Tool adapters (GitHub, Jira, GitLab)
- Template suite (ERD, Spec, Plan, Tasks)
- Multi-environment validation (3 Fortune 500 projects)

**Dependency**: Requires taxonomy phase (this project) complete before starting

### Migration Coordination

See [`phases/migration-coordination/tasks.md`](phases/migration-coordination/tasks.md) for:

- Tooling discovery coordination
- Artifact migration coordination
- Cross-project sequencing

**Runs concurrently** with taxonomy phase as coordination layer

## Overall Project Completion

This umbrella project is complete when:

- [ ] ✅ Base taxonomy defined and validated (Phase 1-3 of this project)
- [ ] ✅ Core artifacts categorized (Phase 2 of this project)
- [ ] ✅ Enterprise toolkit OR migration coordination complete (one nested project validated)

## Notes

- Start with Option A (metadata tags) for minimal disruption
- Can evolve to folder separation (Option B) later if needed
- Focus on clear taxonomy definition before backfilling
- Prioritize core portable artifacts (TDD, testing, git workflows) first
- Enterprise toolkit is optional future work; base taxonomy alone is valuable
