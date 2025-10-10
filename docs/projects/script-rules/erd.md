---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Script Rules (Lite)

Links: `docs/projects/script-rules/tasks.md`
Related: `docs/projects/scripts-unix-philosophy/erd.md`, `docs/projects/script-test-hardening/erd.md`, `docs/projects/portability/erd.md`, `docs/projects/script-help-generation/erd.md`

Mode: Lite

## 1. Introduction/Overview

Establish best practices for repository scripts to ensure they are safe, portable, discoverable, and easy to maintain. Core pillars: robust `--help` output, predictable error handling, and parameterized configuration (no direct environment variable reads in business logic).

## 2. Goals/Objectives

- Ensure every script provides consistent `-h|--help` and `--version` flags with structured sections.
- Enforce predictable error handling: explicit exit codes, `set -euo pipefail` or equivalent safety, and concise failure messages.
- Prohibit direct environment variable access in logic; require parameters with optional env-derived defaults resolved at the boundary.
- Provide lightweight helpers and validators to make compliance easy.

## 3. Functional Requirements

1. Help requirements
   - Scripts MUST implement `-h|--help` and `--version`.
   - `--help` MUST include: Name, Synopsis, Description, Options, Environment, Examples, Exit Codes.
   - Help MUST be non-interactive and fast; zero side effects.
2. Error handling
   - Use `set -euo pipefail` at the top of scripts (or explicit `trap`-based handling when not suitable).
   - Provide a `die()` helper for uniform error messages to stderr and controlled exits.
   - Reserve exit code 0 for success; non-zero codes are documented in help.
3. Parameterization over env
   - Do NOT read `"$ENV_VAR"` directly inside core logic.
   - Accept inputs via flags/args; if env is allowed, resolve once at the CLI boundary into variables (e.g., `: "${FOO:=default}"` or explicit mapping) and pass as parameters.
   - Provide a `require_param` helper to validate required inputs.
4. Validators
   - Add a validator `.cursor/scripts/script-rules-validate.sh` that checks for: help flags present, presence of safety prologue, no raw `"$[A-Z_][A-Z0-9_]*"` reads in logic blocks (allowlist boundary patterns), and `die()` usage for errors.
   - Integrate with `help-validate.sh` from `script-help-generation`.

## 4. Acceptance Criteria

- All maintained scripts in `.cursor/scripts/` pass `script-rules-validate.sh` and `help-validate.sh`.
- Sampling 3 scripts shows: parameterized config, consistent errors, and documented exit codes.
- No script performs side effects when invoked with `--help` or without required arguments (fails fast with clear message).

## 5. Non-Functional Requirements

- Portability: bash-first; avoid GNU-only flags; prefer POSIX sh where reasonable.
- Clarity: concise error text; stable, grep-friendly help structure.
- Security: never echo secrets; redaction in error paths if needed.

## 6. Architecture/Design

- Shared helpers in `.cursor/scripts/.lib.sh`:
  - `print_help` utilities matching the help schema.
  - `die` for errors; `require_param` for validation.
  - `resolve_env_default VAR DEFAULT` used only at the boundary.
- Validator uses ripgrep/awk to detect anti-patterns and missing sections.

## 7. Risks/Edge Cases

- Legacy scripts might rely on implicit env; migration guide must be included.
- Some scripts need interactive prompts; require `--yes`/`--no-input` flags to gate effects.

## 8. Rollout & Ops

- Phase 1: create validator and helpers; convert 2–3 scripts.
- Phase 2: migrate remaining scripts; optionally add CI gate.
- Phase 3: document patterns and cross-link from repository `README.md` and `docs/scripts/` index.

## 9. Success Metrics

- 100% of maintained scripts pass validators.
- New scripts adopt helpers by default; diffs show minimal boilerplate repetition.
