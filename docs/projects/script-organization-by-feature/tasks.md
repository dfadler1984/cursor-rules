## Tasks — Shell Scripts Organization by Feature

**Status**: ACTIVE | Phase: Planning & Audit | ~0% Complete

---

## Phase 1: Planning & Audit (2-3 hours)

- [ ] 1.0 Audit script references across repository
  - [ ] 1.1 Scan `.cursor/rules/*.mdc` for script references (grep for `.cursor/scripts/`)
  - [ ] 1.2 Scan `.cursor/scripts/**/*.sh` for inter-script calls (grep for sourcing and execution)
  - [ ] 1.3 Scan `.github/workflows/*.yml` for script references
  - [ ] 1.4 Scan `docs/**/*.md` for script references
  - [ ] 1.5 Check git hooks (`.git/hooks/`) for script references
  - [ ] 1.6 Document all references in `audit-references.md`
- [ ] 1.7 Categorize scripts by primary feature
  - [ ] 1.8 List all scripts in `.cursor/scripts/` (exclude tests initially)
  - [ ] 1.9 Assign each script to a category (git, github, project, rules, validation, tooling, lib, scripts)
  - [ ] 1.10 Identify scripts with multiple feature areas (document primary + secondary)
  - [ ] 1.11 Document categorization in `script-categories.md`
- [ ] 1.12 Create migration checklist
  - [ ] 1.13 List all files to move (scripts + tests)
  - [ ] 1.14 List all files to update (rules, workflows, docs)
  - [ ] 1.15 Identify rollback plan (git tag + revert strategy)
  - [ ] 1.16 Document in `migration-checklist.md`

**Relevant Files**:

- `.cursor/rules/*.mdc` (script references)
- `.cursor/scripts/**/*.sh` (inter-script calls)
- `.github/workflows/*.yml` (CI references)
- `docs/**/*.md` (documentation)

**Acceptance**:

- Complete inventory of all script references
- Clear categorization of all scripts
- Migration checklist with rollback plan

---

## Phase 2: Directory Structure (1 hour)

- [ ] 2.0 Create subdirectory structure
  - [ ] 2.1 Create `.cursor/scripts/git/` (Git operations)
  - [ ] 2.2 Create `.cursor/scripts/github/` (GitHub API)
  - [ ] 2.3 Create `.cursor/scripts/project/` (Project lifecycle)
  - [ ] 2.4 Create `.cursor/scripts/rules/` (Rules validation)
  - [ ] 2.5 Create `.cursor/scripts/validation/` (General validation)
  - [ ] 2.6 Create `.cursor/scripts/tooling/` (Meta-tooling)
  - [ ] 2.7 Create `.cursor/scripts/lib/` (Shared libraries)
  - [ ] 2.8 Create `.cursor/scripts/scripts/` (Script utilities)
- [ ] 2.9 Document organization rationale
  - [ ] 2.10 Update `.cursor/scripts/README.md` with subdirectory descriptions
  - [ ] 2.11 Add feature category definitions
  - [ ] 2.12 Document how to choose category for new scripts
  - [ ] 2.13 Add examples of each category

**Relevant Files**:

- `.cursor/scripts/README.md` (documentation)

**Acceptance**:

- All subdirectories created
- README documents organization rationale
- Clear guidance for future script placement

---

## Phase 3: Move Scripts (2-3 hours)

- [ ] 3.0 Move git-related scripts
  - [ ] 3.1 Move `git-commit.sh` + test to `git/`
  - [ ] 3.2 Move `git-branch-name.sh` + test to `git/`
  - [ ] 3.3 Move `git-context.sh` + test to `git/`
  - [ ] 3.4 Update internal path references in moved scripts
- [ ] 3.5 Move github-related scripts
  - [ ] 3.6 Move `pr-create.sh` + test to `github/`
  - [ ] 3.7 Move `pr-update.sh` + test to `github/`
  - [ ] 3.8 Move `pr-create-simple.sh` + test to `github/`
  - [ ] 3.9 Move `pr-labels.sh` + test to `github/`
  - [ ] 3.10 Move `pr-label.sh` + test to `github/`
  - [ ] 3.11 Move `pr-changeset-sync.sh` + test to `github/`
  - [ ] 3.12 Move `checks-status.sh` + test to `github/`
  - [ ] 3.13 Move `changesets-automerge-dispatch.sh` + test to `github/`
  - [ ] 3.14 Update internal path references in moved scripts
- [ ] 3.15 Move project-related scripts
  - [ ] 3.16 Move `project-status.sh` + test to `project/`
  - [ ] 3.17 Move `project-complete.sh` + test to `project/`
  - [ ] 3.18 Move `project-create.sh` + test to `project/`
  - [ ] 3.19 Move `project-archive-workflow.sh` + test to `project/`
  - [ ] 3.20 Move `project-archive-ready.sh` + test to `project/`
  - [ ] 3.21 Move `project-archive.sh` + test to `project/`
  - [ ] 3.22 Move `final-summary-generate.sh` + test to `project/`
  - [ ] 3.23 Move `project-lifecycle-validate.sh` + test to `project/`
  - [ ] 3.24 Move `project-lifecycle-validate-scoped.sh` + test to `project/`
  - [ ] 3.25 Move `project-lifecycle-validate-sweep.sh` + test to `project/`
  - [ ] 3.26 Move `project-lifecycle-migrate.sh` + test to `project/`
  - [ ] 3.27 Move `project-docs-organize.sh` + test to `project/`
  - [ ] 3.28 Move `archive-detect-complete.sh` + test to `project/`
  - [ ] 3.29 Move `archive-fix-links.sh` + test to `project/`
  - [ ] 3.30 Move `generate-projects-readme.sh` + test to `project/`
  - [ ] 3.31 Update internal path references in moved scripts
- [ ] 3.32 Move rules-related scripts
  - [ ] 3.33 Move `rules-validate.sh` + test to `rules/`
  - [ ] 3.34 Move `rules-list.sh` + test to `rules/`
  - [ ] 3.35 Move `rules-autofix.sh` + test to `rules/`
  - [ ] 3.36 Move `rules-attach-validate.sh` + test to `rules/`
  - [ ] 3.37 Move `rules-validate-format.sh` + test to `rules/`
  - [ ] 3.38 Move `rules-validate-frontmatter.sh` + test to `rules/`
  - [ ] 3.39 Move `rules-validate-refs.sh` + test to `rules/`
  - [ ] 3.40 Move `rules-validate-staleness.sh` + test to `rules/`
  - [ ] 3.41 Move `routing-validate.sh` + test to `rules/`
  - [ ] 3.42 Update internal path references in moved scripts
- [ ] 3.43 Move validation-related scripts
  - [ ] 3.44 Move `erd-validate.sh` + test to `validation/`
  - [ ] 3.45 Move `erd-migrate-frontmatter.sh` + test to `validation/`
  - [ ] 3.46 Move `erd-add-mode-line.sh` + test to `validation/`
  - [ ] 3.47 Move `erd-fix-empty-frontmatter.sh` + test to `validation/`
  - [ ] 3.48 Move `links-check.sh` + test to `validation/`
  - [ ] 3.49 Move `validate-artifacts.sh` + test to `validation/`
  - [ ] 3.50 Move `test-colocation-validate.sh` + test to `validation/`
  - [ ] 3.51 Move `test-colocation-migrate.sh` + test to `validation/`
  - [ ] 3.52 Move `validate-investigation-structure.sh` + test to `validation/`
  - [ ] 3.53 Move `validate-project-lifecycle.sh` + test to `validation/`
  - [ ] 3.54 Move `validate-artifacts-smoke.sh` + test to `validation/`
  - [ ] 3.55 Update internal path references in moved scripts
- [ ] 3.56 Move tooling-related scripts
  - [ ] 3.57 Move `capabilities-sync.sh` + test to `tooling/`
  - [ ] 3.58 Move `tooling-inventory.sh` + test to `tooling/`
  - [ ] 3.59 Move `deep-rule-and-command-validate.sh` + test to `tooling/`
  - [ ] 3.60 Move `health-badge-generate.sh` + test to `tooling/`
  - [ ] 3.61 Move `repo-health-badge.sh` + test to `tooling/`
  - [ ] 3.62 Move `context-efficiency-score.sh` + test to `tooling/`
  - [ ] 3.63 Move `context-efficiency-format.sh` + test to `tooling/`
  - [ ] 3.64 Move `context-efficiency-gauge.sh` + test to `tooling/`
  - [ ] 3.65 Update internal path references in moved scripts
- [ ] 3.66 Move library scripts
  - [ ] 3.67 Move `.lib.sh` + test to `lib/`
  - [ ] 3.68 Move `.lib-net.sh` to `lib/`
  - [ ] 3.69 Move `rules-validate.spec.sh` to `lib/` (shared test helper)
  - [ ] 3.70 Update internal path references in moved scripts
- [ ] 3.71 Move script utility scripts
  - [ ] 3.72 Move `help-validate.sh` + test to `scripts/`
  - [ ] 3.73 Move `error-validate.sh` + test to `scripts/`
  - [ ] 3.74 Move `shellcheck-run.sh` + test to `scripts/`
  - [ ] 3.75 Move `network-guard.sh` + test to `scripts/`
  - [ ] 3.76 Update internal path references in moved scripts
- [ ] 3.77 Move remaining scripts (triage as needed)
  - [ ] 3.78 Audit any remaining scripts in root
  - [ ] 3.79 Categorize and move to appropriate subdirectories
  - [ ] 3.80 Update internal path references

**Relevant Files**:

- `.cursor/scripts/*.sh` (all scripts)
- `.cursor/scripts/*.test.sh` (all tests)

**Acceptance**:

- All scripts moved to subdirectories
- Test colocation preserved (tests next to scripts)
- All inter-script references updated
- No scripts remain in root (except potentially test runner)

---

## Phase 4: Update References (3-4 hours)

- [ ] 4.0 Update rule file references
  - [ ] 4.1 Update `assistant-behavior.mdc` script paths
  - [ ] 4.2 Update `assistant-git-usage.mdc` script paths
  - [ ] 4.3 Update `capabilities.mdc` script paths
  - [ ] 4.4 Update `create-erd.mdc` script paths
  - [ ] 4.5 Update `generate-tasks-from-erd.mdc` script paths
  - [ ] 4.6 Update `project-lifecycle.mdc` script paths
  - [ ] 4.7 Update `rule-creation.mdc` script paths
  - [ ] 4.8 Update `rule-maintenance.mdc` script paths
  - [ ] 4.9 Update `shell-unix-philosophy.mdc` script paths
  - [ ] 4.10 Update any other rule files with script references
- [ ] 4.11 Update CI workflow references
  - [ ] 4.12 Update `.github/workflows/ci.yml` (if exists)
  - [ ] 4.13 Update `.github/workflows/tests.yml` (if exists)
  - [ ] 4.14 Update `.github/workflows/validation.yml` (if exists)
  - [ ] 4.15 Update any other workflow files with script references
- [ ] 4.16 Update documentation references
  - [ ] 4.17 Update `README.md` script paths
  - [ ] 4.18 Update `docs/scripts/README.md` script paths
  - [ ] 4.19 Update `docs/projects/**/*.md` script paths (bulk update)
  - [ ] 4.20 Update any other documentation with script references
- [ ] 4.21 Update git hooks (if any)
  - [ ] 4.22 Check `.git/hooks/` for script references
  - [ ] 4.23 Update hook script paths if needed
- [ ] 4.24 Update package.json scripts (if any)
  - [ ] 4.25 Check `package.json` for script references
  - [ ] 4.26 Update script paths in npm/yarn scripts

**Relevant Files**:

- `.cursor/rules/*.mdc` (50+ rule files)
- `.github/workflows/*.yml` (workflow files)
- `docs/**/*.md` (documentation)
- `README.md` (main docs)
- `package.json` (if applicable)

**Acceptance**:

- All rule file references updated
- All CI workflow references updated
- All documentation references updated
- No broken script references remain

---

## Phase 5: Validation (1-2 hours)

- [ ] 5.0 Run test suite
  - [ ] 5.1 Run `bash .cursor/scripts/tests/run.sh` (all tests)
  - [ ] 5.2 Fix any test failures related to path changes
  - [ ] 5.3 Re-run tests until all pass
- [ ] 5.4 Validate script references
  - [ ] 5.5 Run `grep -r "\.cursor/scripts/[^/]*\.sh" .cursor/rules/` (check for old paths)
  - [ ] 5.6 Run `grep -r "\.cursor/scripts/[^/]*\.sh" .github/workflows/` (check for old paths)
  - [ ] 5.7 Run `grep -r "\.cursor/scripts/[^/]*\.sh" docs/` (check for old paths)
  - [ ] 5.8 Fix any remaining old path references
- [ ] 5.9 Manual smoke tests
  - [ ] 5.10 Run a git script: `bash .cursor/scripts/git/git-commit.sh --help`
  - [ ] 5.11 Run a github script: `bash .cursor/scripts/github/pr-create.sh --help`
  - [ ] 5.12 Run a project script: `bash .cursor/scripts/project/project-status.sh <slug>`
  - [ ] 5.13 Run a rules script: `bash .cursor/scripts/rules/rules-validate.sh`
  - [ ] 5.14 Run a validation script: `bash .cursor/scripts/validation/erd-validate.sh <path>`
- [ ] 5.15 Validate capabilities.mdc
  - [ ] 5.16 Run `bash .cursor/scripts/tooling/capabilities-sync.sh --check`
  - [ ] 5.17 Fix any capability mismatches
  - [ ] 5.18 Re-run until all capabilities sync

**Relevant Files**:

- `.cursor/scripts/**/*.sh` (all scripts)
- `.cursor/scripts/tests/run.sh` (test runner)
- `.cursor/rules/capabilities.mdc` (capabilities catalog)

**Acceptance**:

- All tests pass
- No broken script references
- All capabilities in sync
- Manual smoke tests successful

---

## Phase 6: Documentation (1 hour)

- [ ] 6.0 Update scripts README
  - [ ] 6.1 Document subdirectory structure in `.cursor/scripts/README.md`
  - [ ] 6.2 Add category descriptions (git, github, project, rules, validation, tooling, lib, scripts)
  - [ ] 6.3 Document how to choose category for new scripts
  - [ ] 6.4 Add examples of each category
  - [ ] 6.5 Document migration rationale
- [ ] 6.6 Create migration guide (if needed)
  - [ ] 6.7 Document old → new path mappings
  - [ ] 6.8 Provide search-replace commands for external consumers
  - [ ] 6.9 Add migration guide to `docs/projects/script-organization-by-feature/migration-guide.md`
- [ ] 6.10 Update main README (if applicable)
  - [ ] 6.11 Update script usage examples in `README.md`
  - [ ] 6.12 Add note about subdirectory organization
- [ ] 6.13 Create PR description
  - [ ] 6.14 Summarize changes (moved X scripts to Y subdirectories)
  - [ ] 6.15 Document validation performed (tests, references, smoke tests)
  - [ ] 6.16 Add migration guide link (if applicable)
  - [ ] 6.17 Note rollback plan (git tag + revert strategy)

**Relevant Files**:

- `.cursor/scripts/README.md` (scripts documentation)
- `docs/projects/script-organization-by-feature/migration-guide.md` (migration guide)
- `README.md` (main documentation)

**Acceptance**:

- Scripts README documents organization
- Migration guide available (if needed)
- Main README updated with new paths
- PR description ready for submission

---

## Carryovers

_(Tasks deferred from earlier phases or discovered during execution)_

- [ ] Consider feature-scoped test runners (run all git tests, all project tests, etc.)
- [ ] Consider shell completion helpers for new paths
- [ ] Consider automated reference updater for future moves
- [ ] Consider PATH-style discovery mechanism (search subdirectories)

---

## Notes

- **Migration strategy**: Atomic migration in single PR to avoid broken intermediate state
- **Rollback plan**: Tag current state before migration; revert if issues arise
- **Test colocation**: Keep `*.test.sh` next to `*.sh` per `test-quality-sh.mdc`
- **Shebang preservation**: Scripts keep their shebangs (no wrapper changes)
- **Execute permissions**: Preserve `chmod +x` state

---

## Related

- See [erd.md](./erd.md) for full requirements and decision rationale
- See [script-refinement](../script-refinement/) for shell script quality improvements
- See [shell-test-organization](../shell-test-organization/) for test organization patterns
