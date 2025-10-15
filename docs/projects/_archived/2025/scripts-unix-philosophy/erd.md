---
status: active
owner: rules-maintainers
lastUpdated: 2025-10-13
---

# Engineering Requirements Document — Scripts Refactor Aligned to Unix Philosophy

Reference: [Basics of the Unix Philosophy](https://cscie2x.dce.harvard.edu/hw/ch01s06.html)

**Enforcement:** See [`.cursor/rules/shell-unix-philosophy.mdc`](../../../../../.cursor/rules/shell-unix-philosophy.mdc) for active rule enforcement.

Mode: Lite

## 1. Introduction/Overview

Refactor the repository's scripts to embody the Unix Philosophy: simple programs that do one thing well, composed via clean, text-stream interfaces, with clear separation of mechanism and policy, designed for clarity and robustness.

## 2. Goals/Objectives

- Do one thing well: each script has a single responsibility and minimal flags
- Composition: default to text input/output suitable for piping; avoid interactive prompts
- Clarity over cleverness: straightforward algorithms and readable code
- Separation: isolate policy/config from execution mechanisms
- Extensibility: stable, documented interfaces to evolve over time

## 3. Functional Requirements

1. Text-stream IO: scripts read from stdin and/or arguments, write results to stdout, logs to stderr
2. Clean interfaces: consistent `--help` and `--version`; minimal, orthogonal flags
3. Composability: support exit codes and machine-readable modes where appropriate (e.g., `--format json`)
4. Modularity: extract common helpers into `.cursor/scripts/.lib.sh` and keep scripts small
5. Non-interactive by default: avoid prompts; accept flags/env for configuration

## 4. Acceptance Criteria

- Each script:
  - Has a clearly documented single responsibility in `--help`
  - Emits only the essential result to stdout; logs/errors to stderr
  - Returns meaningful exit codes (0 success; non-zero on failure)
  - Supports `--help` and `--version`
- Shared helpers handle logging, error, and parsing to reduce duplication
- Examples in `README.md` demonstrate piping and composition

## 5. Non-Functional Requirements

- Simplicity first; avoid unnecessary abstractions
- Portability: bash-first on macOS; prefer POSIX-sh compatible constructs when feasible
- Testability: deterministic behavior; easy to mock effects via seams

## 6. Architecture/Design

- Keep scripts small and focused; factor shared logic into `.lib.sh` (logging, die, arg parsing)
- Provide consistent CLI patterns: `-h|--help`, `--version`, `--format`, `--quiet`
- Prefer text-stream formats for default output; offer JSON as optional mode
- Separate policy (defaults/env) from mechanism (work execution)

## 7. Risks/Edge Cases

- Over-abstracting helpers can hide behavior—prioritize clarity
- Backward compatibility: document any breaking CLI changes and provide migration notes

## 8. Testing & Acceptance

- Shell tests assert stdout vs stderr separation, exit codes, and pipe-friendly behavior
- Golden examples in docs verified by tests (doctest-style snippets where reasonable)

## 9. Rollout & Ops

- Phase 1: establish shared patterns and helper updates
- Phase 2: refactor highest-usage scripts
- Phase 3: apply to remaining scripts; update examples and docs

## 10. Success Metrics

- Scripts compose cleanly in pipelines without additional tooling
- Reduced code duplication via helpers; improved readability in reviews

## 11. Existing Script Refactoring (Phase 4 — Extraction Complete, Orchestration Deferred)

**Status:** Extraction refactoring complete (2025-10-14) — created 9 new focused scripts; orchestration updates deferred as optional work.

**Decision:** Accept partial completion. Enforcement rule prevents new violations; orchestration is optional enhancement.

- Created new focused scripts ✅ (9 scripts, all Unix Philosophy compliant)
- Enforcement rule active ✅ (shell-unix-philosophy.mdc prevents new violations)
- Orchestration deferred ⏸️ (original scripts remain functional; focused alternatives available)

**Audit findings:** See [`docs/projects/shell-and-script-tooling/UNIX-PHILOSOPHY-AUDIT-UPDATED.md`](../shell-and-script-tooling/UNIX-PHILOSOPHY-AUDIT-UPDATED.md)

**Current state (acceptable):**

- 44 production scripts (includes 9 extracted alternatives)
- 5 originals could be updated to orchestrators (optional future work)
- Enforcement rule ensures all new scripts are Unix Philosophy compliant
- Focused alternatives available for major use cases

**Original scripts (functional, orchestration optional):**

1. `rules-validate.sh` (497 lines) — 5 focused alternatives available
2. `context-efficiency-gauge.sh` (342 lines) — 1 focused alternative available (score extraction)
3. `pr-create.sh` (282 lines, 14 flags) — 3 focused alternatives available
4. `checks-status.sh` (257 lines, 12 flags) — Not extracted (optional future work)
5. `rules-validate-format.sh` (226 lines) — Large extraction; could be split further (optional)

### Priority 1: Major Violators (4 scripts)

**1. `rules-validate.sh` (497 lines, 13 functions, 11 flags)**

Responsibilities: Front matter validation, CSV/boolean checking, staleness checking, missing refs, autofixing, multiple output formats

Recommended split:

- `rules-validate-frontmatter` — validate front matter only
- `rules-validate-refs` — check references
- `rules-validate-staleness` — check staleness
- `rules-autofix` — autofix issues
- `rules-format` — format output (pipe target)

**2. `pr-create.sh` (282 lines, 14 flags)**

Responsibilities: Create PRs, manage labels, handle templates, compose body text, auto-detect git context

Recommended split:

- `pr-create` — minimal: title, body, base, head (≤6 flags)
- `pr-label` — add labels to existing PRs
- `pr-template-fill` — template handling
- `git-context` — derive owner/repo/branch (reusable utility)

**3. `context-efficiency-gauge.sh` (342 lines)**

Responsibilities: Compute efficiency score, format output (4 formats)

Recommended split:

- `context-efficiency-score` — compute score only, output simple format
- `context-efficiency-format` — accept score input, format for display

**4. `checks-status.sh` (257 lines, 12 flags)**

Responsibilities: Fetch GitHub checks, format output, wait/polling logic

Recommended split:

- `checks-fetch` — fetch and output JSON
- `checks-format` — format JSON for display
- `checks-wait` — polling wrapper (uses checks-fetch)

### Refactoring Approach

**Trigger:** Opportunistic refactoring when scripts are touched for other reasons

**Process:**

1. Extract one responsibility to new focused script
2. Add tests for new script
3. Update original script to call new script or remove responsibility
4. Update documentation and examples
5. Maintain backward compatibility when possible

**Not required:** Refactoring is optional enhancement work; enforcement rule prevents new violations
