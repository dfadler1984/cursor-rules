---
status: active
owner: rules-maintainers
lastUpdated: 2025-10-05
---

# Engineering Requirements Document — Scripts Refactor Aligned to Unix Philosophy

Reference: [Basics of the Unix Philosophy](https://cscie2x.dce.harvard.edu/hw/ch01s06.html)

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
