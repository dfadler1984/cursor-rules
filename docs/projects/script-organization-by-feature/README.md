# Shell Scripts Organization by Feature

**Status**: ACTIVE  
**Phase**: Planning & Audit  
**Completion**: ~0%

---

## Overview

Reorganize `.cursor/scripts/` from flat directory (100+ scripts) to feature-based subdirectories for improved discoverability, maintenance, and navigation.

**Problem**: Flat structure makes it hard to find related scripts and understand feature boundaries.

**Solution**: Create subdirectories by feature type (git, github, project, rules, validation, tooling, lib, scripts) and migrate all scripts.

## Quick Links

- [ERD (Requirements)](./erd.md) — Problem statement, goals, approach, success criteria
- [Tasks](./tasks.md) — Phase checklists and execution tracking
- [Migration Guide](./migration-guide.md) — Old → new path mappings (created in Phase 6)

## Proposed Structure

```
.cursor/scripts/
  ├── git/                    # Git operations (commit, branch, status)
  ├── github/                 # GitHub API (PRs, labels, checks)
  ├── project/                # Project lifecycle (status, archive, complete)
  ├── rules/                  # Rules validation and management
  ├── validation/             # General validation (ERD, links, structure)
  ├── tooling/                # Meta-tooling (capabilities, inventory, health)
  ├── lib/                    # Shared libraries (.lib.sh, .lib-net.sh)
  └── scripts/                # Script utilities (help, error validation)
```

## Current Phase: Planning & Audit

**Goal**: Audit all script references and categorize scripts by feature.

**Next Steps**:

1. Scan `.cursor/rules/*.mdc` for script references
2. Scan `.cursor/scripts/**/*.sh` for inter-script calls
3. Scan `.github/workflows/*.yml` for CI references
4. Categorize all scripts by primary feature
5. Create migration checklist

## Progress

- [ ] Phase 1: Planning & Audit (2-3 hours)
- [ ] Phase 2: Directory Structure (1 hour)
- [ ] Phase 3: Move Scripts (2-3 hours)
- [ ] Phase 4: Update References (3-4 hours)
- [ ] Phase 5: Validation (1-2 hours)
- [ ] Phase 6: Documentation (1 hour)

**Total Estimated**: 10-14 hours

## Success Criteria

### Must Have

- All scripts moved to feature-based subdirectories
- All references updated (rules, scripts, CI, docs)
- All tests pass
- No broken script references

### Should Have

- Script categories documented
- Migration guide for external consumers
- Feature-scoped test runners

## Impact

**Benefits**:

- **Discoverability**: Find related scripts by navigating to feature directory
- **Maintainability**: Changes to a feature area grouped in one location
- **Scalability**: Structure supports repository growth
- **Onboarding**: New contributors understand organization at a glance

**Risks**:

- **Migration effort**: 10-14 hours to move and update all references
- **Breaking changes**: External consumers may need to update paths
- **Temporary disruption**: All changes land in single PR to avoid broken state

**Mitigation**:

- Atomic migration in single PR (no intermediate broken state)
- Rollback plan (git tag + revert strategy)
- Migration guide for external consumers
- Comprehensive validation (tests, reference checks, smoke tests)

## Related Projects

- [script-refinement](../script-refinement/) — Shell script quality improvements
- [shell-test-organization](../shell-test-organization/) — Test organization patterns
- [test-colocation](../test-coverage/) — Test placement standards

## Related Rules

- [shell-unix-philosophy.mdc](../../.cursor/rules/shell-unix-philosophy.mdc) — Shell script standards
- [test-quality-sh.mdc](../../.cursor/rules/test-quality-sh.mdc) — Shell test quality
- [capabilities.mdc](../../.cursor/rules/capabilities.mdc) — Script capabilities catalog

---

**Last Updated**: 2025-10-25
