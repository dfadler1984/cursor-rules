# Shell Scripts Reference

This directory provides a reference for all shell scripts in `.cursor/scripts/`. All scripts follow the standardized patterns defined in [`docs/projects/shell-and-script-tooling/`](../projects/shell-and-script-tooling/).

## Quick Start

All scripts provide built-in help:

```bash
bash .cursor/scripts/<script-name>.sh --help
bash .cursor/scripts/<script-name>.sh --version
```

## Standards Compliance

All 44 production scripts (plus 1 spec helper and 2 libraries) comply with:

- **D1 (Help/Version)**: Standardized help with Options, Examples, Exit Codes sections
- **D2 (Strict Mode)**: `set -euo pipefail`, proper error traps
- **D3 (Error Semantics)**: Standardized exit codes (EXIT_USAGE=2, EXIT_CONFIG=3, etc.)
- **D4 (Networkless Tests)**: Tests use seams/fixtures; production scripts can make network calls
- **D5 (Portability)**: bash + git only; optional tools degrade gracefully
- **D6 (Test Isolation)**: Subshell isolation prevents env leakage

See: [`shell-and-script-tooling/MIGRATION-GUIDE.md`](../projects/shell-and-script-tooling/MIGRATION-GUIDE.md)

## Script Categories

### Git & GitHub Automation (9 scripts)

- **`git-commit.sh`** — Generate Conventional Commits with validation
- **`git-branch-name.sh`** — Validate and generate branch names with prefixes
- **`git-context.sh`** — Derive owner, repo, head, base from git remote (reusable utility)
- **`pr-create.sh`** — Create GitHub pull requests via API (comprehensive, includes templates/labels)
- **`pr-create-simple.sh`** — Create GitHub pull requests (simplified: title/body only)
- **`pr-label.sh`** — Add labels to existing pull requests via GitHub API
- **`pr-update.sh`** — Update existing pull requests via API
- **`checks-status.sh`** — Check GitHub Actions status for PRs
- **`changesets-automerge-dispatch.sh`** — Dispatch changesets auto-merge workflow

### Project Lifecycle (6 scripts)

- **`project-archive.sh`** — Archive individual project to `_archived/YYYY/`
- **`project-archive-workflow.sh`** — End-to-end project archival workflow
- **`project-lifecycle-migrate.sh`** — Backfill lifecycle artifacts for legacy projects
- **`project-lifecycle-validate.sh`** — Validate all projects for lifecycle compliance
- **`project-lifecycle-validate-scoped.sh`** — Validate single project
- **`project-lifecycle-validate-sweep.sh`** — Validate all completed projects
- **`final-summary-generate.sh`** — Generate final project summaries

### Rules & Validation (12 scripts)

- **`rules-validate.sh`** — Validate rule files (front matter, refs, staleness) — comprehensive validator
- **`rules-validate-frontmatter.sh`** — Validate front matter only (description, lastReviewed, healthScore)
- **`rules-validate-refs.sh`** — Validate markdown link references
- **`rules-validate-staleness.sh`** — Validate lastReviewed age (configurable threshold)
- **`rules-validate-format.sh`** — Validate CSV format, booleans, deprecated refs, structure
- **`rules-autofix.sh`** — Auto-fix CSV spacing and boolean casing
- **`rules-validate.spec.sh`** — Spec helper for rules validation (not validated itself)
- **`rules-list.sh`** — List rules with metadata and filters
- **`rules-attach-validate.sh`** — Validate rule attachment configuration
- **`capabilities-sync.sh`** — Sync capabilities between rules and scripts
- **`erd-validate.sh`** — Validate ERD structure and required sections
- **`validate-artifacts.sh`** — Validate project artifacts (ERDs, tasks)

### Shell Script Validators (4 scripts)

- **`help-validate.sh`** — Validate help documentation (D1 compliance)
- **`error-validate.sh`** — Validate error handling and strict mode (D2/D3 compliance)
- **`network-guard.sh`** — Check network usage policy (D4 informational)
- **`shellcheck-run.sh`** — Run ShellCheck with graceful degradation (D5)

### Testing & Quality (4 scripts)

- **`test-colocation-validate.sh`** — Validate test file colocation
- **`test-colocation-migrate.sh`** — Migrate tests to colocation pattern
- **`security-scan.sh`** — Run security scans (npm audit)
- **`validate-artifacts-smoke.sh`** — Smoke test for artifact validation
- **`validate-project-lifecycle.sh`** — Helper for project lifecycle validation

### Workflow & CI (4 scripts)

- **`lint-workflows.sh`** — Lint GitHub Actions workflows
- **`preflight.sh`** — Pre-flight checks before major operations
- **`tooling-inventory.sh`** — Inventory of all tooling and scripts
- **`links-check.sh`** — Check for broken links in documentation

### Templates & Utilities (5 scripts)

- **`template-fill.sh`** — Fill templates with variables
- **`context-efficiency-gauge.sh`** — Measure chat context efficiency (orchestrator: score + format)
- **`context-efficiency-score.sh`** — Compute context efficiency score only (1-5 scale)
- **`context-efficiency-format.sh`** — Format efficiency scores (4 modes: line, dashboard, decision-flow, json)
- **`setup-remote.sh`** — Setup script for remote machines (dependency checking)

### Libraries (2 files)

- **`.lib.sh`** — Core library (exit codes, strict mode, help functions, logging)
- **`.lib-net.sh`** — Network effects seam (test helpers, fixtures)

## Script Count

- **45 production scripts** (plus 1 spec helper: `rules-validate.spec.sh`)
- **47 scripts validated** by help-validate.sh and error-validate.sh (includes 2 libraries: `.lib.sh`, `.lib-net.sh`)
- **7 scripts use network** (legitimately, per D4 policy):
  - pr-create.sh, pr-create-simple.sh, pr-label.sh, pr-update.sh, checks-status.sh, changesets-automerge-dispatch.sh, setup-remote.sh
- **53 test files with 56 tests** (all passing, 100% use fixtures/seams)

## Usage Patterns

### Running Scripts

```bash
# Direct execution (if executable)
.cursor/scripts/help-validate.sh

# Via bash (if not executable)
bash .cursor/scripts/help-validate.sh

# With options
bash .cursor/scripts/help-validate.sh --format json
```

### Common Options

Most scripts support:

- `--help`, `-h` — Show help
- `--version` — Show version
- `--verbose` — Enable verbose output (where applicable)
- `--dry-run` — Preview without making changes (where applicable)

### Exit Codes

All scripts use standardized exit codes:

- `0` — Success
- `2` — Usage error (missing required args, invalid flags)
- `3` — Configuration error (bad config file, missing settings)
- `4` — Dependency missing (required command not found)
- `5` — Network failure (API call failed)
- `6` — Timeout
- `20` — Internal error (unexpected condition)

See: `.cursor/scripts/.lib.sh` for exit code constants

## Adding New Scripts

When creating new scripts:

1. Use the shebang: `#!/usr/bin/env bash`
2. Source `.lib.sh` and enable strict mode
3. Add help documentation using template functions
4. Use standardized exit codes
5. Add owner tests (colocated `*.test.sh`)
6. Run validators: `help-validate.sh`, `error-validate.sh`

See: [`MIGRATION-GUIDE.md`](../projects/shell-and-script-tooling/MIGRATION-GUIDE.md) for detailed patterns

## CI Integration

Scripts are validated on every PR via `.github/workflows/shell-validators.yml`:

- ✅ **help-validate.sh** — Blocks on missing help sections
- ✅ **error-validate.sh** — Blocks on strict mode violations
- ℹ️ **network-guard.sh** — Informational only
- ℹ️ **shellcheck-run.sh** — Optional linting

## Related Documentation

- [Shell & Script Tooling ERD](../projects/shell-and-script-tooling/erd.md) — Project overview
- [Migration Guide](../projects/shell-and-script-tooling/MIGRATION-GUIDE.md) — Detailed patterns
- [Progress Report](../projects/shell-and-script-tooling/PROGRESS.md) — Implementation status

---

Last updated: 2025-10-14
