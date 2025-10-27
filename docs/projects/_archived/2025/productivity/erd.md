---
status: completed
owner: rules-maintainers
lastUpdated: 2025-10-23
---

# Engineering Requirements Document — Productivity & Automation (Lite)


## 1. Introduction/Overview

Streamline repetitive operations with scripts and rule-guided behaviors while preserving safety.

## 2. Goals/Objectives

- Minimal prompting; act when explicit; ask one targeted question on ambiguity
- Automate common steps (git, validation, preflight) with safe defaults
- Keep TDD-first and core guardrails intact

## 3. Functional Requirements

- Provide guidance for when to use scripts vs manual steps
- Integrate with Git usage automation and spec-driven planning
- Prefer reversible, small steps; summarize progress concisely

## 4. Acceptance Criteria

- Example automations listed (branch naming, commit, PR create, preflight)
- Status update guidance (brief, high-signal) documented

## 5. Risks/Edge Cases

- Over-automation leading to hidden behavior; keep outputs explicit

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Run script examples and confirm outputs align with rules

## 8. Examples

### Script Patterns (Observed)

All automation scripts follow consistent patterns:

**Structure:**

- Shebang + `set -euo pipefail` for error handling
- Version constant for tracking
- Usage function with examples and exit codes
- Flag parsing with validation before execution
- Shared library helpers (`.lib.sh`)

**Help System:**

- `--help` flag with usage examples
- `--version` flag for tracking
- `print_exit_codes` for transparency
- Clear error messages with remediation hints

**Design Principles:**

- Non-interactive by default (flags and env vars over prompts)
- Validation-first (check inputs before executing)
- Effects seam pattern (separate decision logic from effects for testability)
- Single responsibility (do one thing well)

### Common Automation Workflows

**Git Automation:**

- Branch naming: `.cursor/scripts/git-branch-name.sh --task checkout-flow --type feat --apply`
- Conventional commits: `.cursor/scripts/git-commit.sh --type feat --scope cart --description "round totals"`
- PR creation: `.cursor/scripts/pr-create.sh --title "Add feature X" --body "Description"`
- PR updates: `.cursor/scripts/pr-update.sh --pr 123 --title "Updated title"`

**Validation & Quality:**

- Preflight checks: `.cursor/scripts/preflight.sh`
- Rules validation: `.cursor/scripts/rules-validate.sh --autofix`
- Test colocation: `.cursor/scripts/test-colocation-validate.sh`
- TDD scope check: `.cursor/scripts/tdd-scope-check.sh <file>`

**Project Lifecycle:**

- Project status: `.cursor/scripts/project-status.sh <slug>`
- Project completion: `.cursor/scripts/project-complete.sh <slug>`
- Archival: `.cursor/scripts/project-archive-workflow.sh --project <slug> --year <YYYY>`

### When to Use Scripts vs Manual

**Use scripts when:**

- Operation is repeatable (commits, PRs, validations)
- Consistency matters (branch naming, commit format)
- Validation is required (TDD scope, rules format)
- Multiple steps can be automated (PR + changeset + labels)

**Use manual when:**

- One-off exploratory task
- Context requires human judgment
- Script overhead exceeds manual effort
- Learning the domain (prefer manual first time, automate on repetition)

### Automation Philosophy (from favor-tooling.mdc)

- **Tooling first**: Rely on scripts, linters, and generators before manual work
- **Smallest check**: Run minimal validation that touches the change (behavior ping)
- **Autofix-first**: Let tools fix formatting before manual edits
- **Scoped locally**: Prefer targeted checks during iteration, full checks in CI

---

Owner: rules-maintainers

Last updated: 2025-10-23
