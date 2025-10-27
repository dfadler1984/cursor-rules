---
status: active
owner: Repository Maintainers
created: 2025-10-25
lastUpdated: 2025-10-25
---

# Engineering Requirements Document: Shell Scripts Organization by Feature

Mode: full

**Project**: script-organization-by-feature

---

## 1. Problem Statement

The `.cursor/scripts/` directory contains 100+ shell scripts in a flat structure, making it difficult to:

- **Navigate**: Finding scripts related to a specific feature requires scanning entire directory
- **Understand scope**: No clear grouping indicates what scripts do or which features they support
- **Maintain**: Related scripts are scattered; changes to a feature area require searching multiple locations
- **Onboard**: New contributors struggle to understand script organization and dependencies

**Why now**: The repository has grown significantly; continued flat structure will compound discovery and maintenance issues.

## 2. Goals

### Primary

- **Organize scripts by feature type** into clear subdirectories (git, project, rules, validation, etc.)
- **Update all references** to scripts (rules, other scripts, documentation, CI workflows)
- **Maintain backward compatibility** during transition (symlinks or path updates)
- **Preserve test colocation** (keep `*.test.sh` next to implementation)

### Secondary

- **Improve discoverability** via logical grouping
- **Enable feature-scoped tooling** (run all git-related tests, validate project scripts, etc.)
- **Document organization rationale** for future maintainers

## 3. Current State

**Structure**: Flat directory with ~100 scripts

```
.cursor/scripts/
  ├── git-commit.sh
  ├── git-branch-name.sh
  ├── pr-create.sh
  ├── pr-update.sh
  ├── project-status.sh
  ├── project-archive-workflow.sh
  ├── rules-validate.sh
  ├── rules-list.sh
  ├── erd-validate.sh
  ├── links-check.sh
  └── ... (90+ more scripts)
```

**References** (locations that reference script paths):

- `.cursor/rules/*.mdc` — 50+ script references
- `.cursor/scripts/*.sh` — Inter-script calls
- `.github/workflows/*.yml` — CI workflow steps
- `docs/projects/**/*.md` — Documentation examples
- Test files (`*.test.sh`) — Colocated with scripts

**Challenges**:

- No clear feature boundaries
- Inter-script dependencies are implicit
- Hard to run feature-specific test suites
- New scripts added without organizational guidance

## 4. Proposed Solutions

### Option A: Feature-Based Subdirectories (Recommended)

**Approach**: Create subdirectories by primary feature area; move scripts into appropriate folders.

**Proposed structure**:

```
.cursor/scripts/
  ├── git/                    # Git operations (commit, branch, status)
  │   ├── git-commit.sh
  │   ├── git-commit.test.sh
  │   ├── git-branch-name.sh
  │   └── git-context.sh
  ├── github/                 # GitHub API (PRs, labels, checks)
  │   ├── pr-create.sh
  │   ├── pr-update.sh
  │   ├── pr-labels.sh
  │   └── checks-status.sh
  ├── project/                # Project lifecycle
  │   ├── project-status.sh
  │   ├── project-archive-workflow.sh
  │   ├── project-complete.sh
  │   └── final-summary-generate.sh
  ├── rules/                  # Rules validation and management
  │   ├── rules-validate.sh
  │   ├── rules-list.sh
  │   ├── rules-autofix.sh
  │   └── rules-attach-validate.sh
  ├── validation/             # General validation (ERD, links, structure)
  │   ├── erd-validate.sh
  │   ├── links-check.sh
  │   ├── validate-artifacts.sh
  │   └── test-colocation-validate.sh
  ├── tooling/                # Meta-tooling (capabilities, inventory, health)
  │   ├── capabilities-sync.sh
  │   ├── tooling-inventory.sh
  │   ├── deep-rule-and-command-validate.sh
  │   └── health-badge-generate.sh
  ├── lib/                    # Shared libraries
  │   ├── .lib.sh
  │   ├── .lib.test.sh
  │   └── .lib-net.sh
  └── scripts/                # Script utilities (help, error validation)
      ├── help-validate.sh
      ├── error-validate.sh
      └── shellcheck-run.sh
```

**Pros**:

- Clear feature boundaries
- Easy to find related scripts
- Enables feature-scoped testing and validation
- Scalable as repository grows

**Cons**:

- Large initial migration effort
- Requires updating all references
- Temporary disruption during transition

**Migration strategy**:

1. **Phase 1: Planning**
   - Audit all script references (rules, scripts, CI, docs)
   - Categorize scripts by feature
   - Create subdirectory structure
2. **Phase 2: Move Scripts**
   - Move scripts to subdirectories
   - Update inter-script references
3. **Phase 3: Update References**
   - Update rule files (`.cursor/rules/*.mdc`)
   - Update CI workflows (`.github/workflows/*.yml`)
   - Update documentation (`docs/projects/**/*.md`)
4. **Phase 4: Validation**
   - Run all tests
   - Validate all references resolve
   - Update capabilities.mdc

### Option B: Hybrid (Subdirectories + Root)

**Approach**: Move scripts to subdirectories but keep most-used scripts in root with symlinks.

**Pros**:

- Backward compatibility for common scripts
- Gradual migration path

**Cons**:

- Confusing: two ways to reference scripts
- Symlinks may break on some systems
- Technical debt (temporary solution becomes permanent)

**Recommendation**: Avoid; adds complexity without solving the core issue.

### Option C: No Change (Status Quo)

**Approach**: Keep flat structure; improve documentation instead.

**Pros**:

- No migration effort
- No breaking changes

**Cons**:

- Doesn't solve discoverability problem
- Scalability issues persist
- Technical debt compounds

**Recommendation**: Reject; problem will worsen over time.

## 5. Success Criteria

### Must Have

- [ ] All scripts moved to feature-based subdirectories
- [ ] All rule references updated (`.cursor/rules/*.mdc`)
- [ ] All inter-script calls updated (`.cursor/scripts/**/*.sh`)
- [ ] All CI workflow references updated (`.github/workflows/*.yml`)
- [ ] All tests pass (`bash .cursor/scripts/tests/run.sh`)
- [ ] `capabilities.mdc` updated with new paths
- [ ] Documentation updated (`docs/projects/**/*.md`, `README.md`)

### Should Have

- [ ] Script categories documented in `.cursor/scripts/README.md`
- [ ] Migration guide for external consumers (if any)
- [ ] Feature-scoped test runners (run all git tests, all project tests, etc.)

### Nice to Have

- [ ] Shell completion helpers for new paths
- [ ] Tooling to detect orphaned references
- [ ] Automated reference updater for future moves

## 6. Non-Goals

- **Changing script functionality**: Scripts should behave identically after move
- **Renaming scripts**: Keep current names (only change paths)
- **Breaking external integrations**: If scripts are used outside this repo, provide migration path
- **Rewriting scripts in different languages**: Focus on organization, not implementation

## 7. Dependencies & Constraints

### Dependencies

- **Test colocation**: Must preserve `*.test.sh` next to `*.sh` (per `test-quality-sh.mdc`)
- **Shebang preservation**: Scripts must keep their shebangs (no wrapper changes)
- **Execute permissions**: Must preserve `chmod +x` state

### Constraints

- **No downtime**: All references must work after migration
- **Single PR**: All changes should land atomically to avoid broken state
- **Rollback plan**: Tag current state before migration; revert script if issues arise

### Breaking Change Risks

- **External consumers**: If scripts are called from outside this repo
- **CI workflows**: Workflows may fail if references break
- **Git hooks**: Pre-commit/pre-push hooks may reference old paths
- **User aliases**: Developers may have shell aliases to old paths

## 8. Open Questions

1. **Should we keep `.cursor/scripts/` as root or nest deeper** (e.g., `.cursor/tooling/scripts/`)?
   - **Answer**: Keep `.cursor/scripts/` as root to minimize path changes
2. **How to handle scripts with multiple features** (e.g., a script that validates rules AND projects)?
   - **Answer**: Place in primary feature directory; document cross-feature usage
3. **Should we create a PATH-style discovery mechanism** (search subdirectories)?
   - **Answer**: Out of scope for initial migration; revisit if needed
4. **Do we need symlinks for transition period**?
   - **Answer**: No; atomic migration in single PR avoids transition complexity

## 9. Timeline

**Phase 1: Planning & Audit** — 2-3 hours

- Audit all script references (rules, scripts, CI, docs)
- Categorize scripts by feature
- Create migration checklist

**Phase 2: Directory Structure** — 1 hour

- Create subdirectories
- Document organization rationale

**Phase 3: Move Scripts** — 2-3 hours

- Move scripts to subdirectories (preserve test colocation)
- Update inter-script references

**Phase 4: Update References** — 3-4 hours

- Update rule files (`.cursor/rules/*.mdc`)
- Update CI workflows (`.github/workflows/*.yml`)
- Update documentation (`docs/`, `README.md`)
- Update `capabilities.mdc`

**Phase 5: Validation** — 1-2 hours

- Run all tests
- Validate all references
- Manual smoke tests

**Phase 6: Documentation** — 1 hour

- Update `.cursor/scripts/README.md`
- Document organization rationale
- Create migration guide (if needed)

**Total**: 10-14 hours

## 10. Related Work

### Related Projects

- [script-refinement](../script-refinement/) — Shell script quality improvements
- [shell-test-organization](../shell-test-organization/) — Test organization patterns
- [test-colocation](../test-coverage/) — Test placement standards

### Related Rules

- [shell-unix-philosophy.mdc](../../../.cursor/rules/shell-unix-philosophy.mdc) — Shell script standards
- [test-quality-sh.mdc](../../../.cursor/rules/test-quality-sh.mdc) — Shell test quality
- [capabilities.mdc](../../../.cursor/rules/capabilities.mdc) — Script capabilities catalog

### Related Documentation

- [.cursor/scripts/README.md](../../../.cursor/scripts/README.md) — Scripts overview
- [docs/scripts/README.md](../../../../docs/scripts/README.md) — Scripts documentation

---

## Decision

**Chosen Approach**: Option A (Feature-Based Subdirectories)

**Rationale**:

- Solves core discoverability problem
- Scalable for repository growth
- Clean migration path (no symlinks or hybrid complexity)
- Atomic migration in single PR avoids transition issues

**Next Steps**: Generate tasks from this ERD and begin Phase 1 (Planning & Audit)
