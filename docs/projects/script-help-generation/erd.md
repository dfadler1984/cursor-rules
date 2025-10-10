---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Script Help Generation (Lite)

Links: `docs/projects/script-help-generation/tasks.md`
Related: `docs/projects/scripts-unix-philosophy/erd.md`, `docs/projects/script-test-hardening/erd.md`, `docs/projects/shell-scripts/erd.md`

Mode: Lite

## 1. Introduction/Overview

Establish a standard for robust `--help` and `--version` output across all repository scripts and provide an automated generator that converts those help texts into navigable documentation. This allows the assistant (and humans) to understand usage without reading source code.

## 2. Goals/Objectives

- Ensure every maintained script implements consistent `-h|--help` and `--version` flags
- Define a minimal schema for help content (name, synopsis, description, options, env, examples, exit codes)
- Generate markdown documentation from `--help` outputs on demand (and optionally during CI)
- Keep outputs stable and linkable so assistants can reference a single catalog

## 3. Functional Requirements

1. Help conventions
   - Scripts must support `-h|--help` and `--version`
   - `--help` prints a structured help block with clearly delimited sections:
     - Name, Synopsis, Description
     - Options (flag, arg, default)
     - Environment Variables
     - Examples
     - Exit Codes
2. Generator CLI `.cursor/scripts/help-generate.sh`
   - Discovers scripts under `.cursor/scripts/*.sh` (exclude test files `*.test.sh`)
   - Runs each with `--help` (non-interactive) and captures stdout
   - Parses section headers and renders `docs/scripts/<script>.md`
   - Produces an index `docs/scripts/README.md` with links and one-line summaries
   - Supports `--format md|json` (default md)
   - Supports `--only <pattern>` to limit which scripts are processed
3. Validation CLI `.cursor/scripts/help-validate.sh`
   - Verifies presence of required sections in `--help`
   - Fails non-zero with a concise report when missing
4. Stability
   - Generator sorts options and normalizes whitespace
   - Idempotent outputs; reruns should produce identical files for unchanged help text

## 4. Acceptance Criteria

- All maintained scripts in `.cursor/scripts/` pass `help-validate.sh`
- Running `help-generate.sh` creates/updates `docs/scripts/` with one file per script and an index
- Each generated doc contains: title, synopsis, description, options table, env vars, examples, exit codes
- No script requires reading code to understand invocation for common tasks

## 5. Non-Functional Requirements

- Portability: bash-first on macOS; avoid GNU-only tools where possible
- Performance: full generation under 2s for ≤25 scripts on a typical laptop
- Security: generator executes `--help` only; never runs primary effects

## 6. Architecture/Design

- Enforce a lightweight help section marker convention in help text:
  - Section headers start with `## ` (e.g., `## Synopsis`)
  - Options lines use `--flag[=ARG]  Description. Default: <value>`
- Parsing uses simple awk/sed to split sections; no heavy dependencies
- Shared helpers in `.cursor/scripts/.lib.sh` for help formatting utilities

## 7. Risks/Edge Cases

- Scripts with side effects when invoked must gate effects behind subcommands/flags so `--help` is safe and fast
- Older scripts may need updates to conform; provide a migration checklist
- Non-standard help formats may resist parsing; prefer normalizing emitters rather than complex parsers

## 8. Rollout & Ops

- Phase 1: create validator and generator; convert 3 representative scripts
- Phase 2: migrate remaining scripts; enforce via CI check (optional)
- Phase 3: document usage and add a link from repository `README.md`

## 9. Success Metrics

- 100% of maintained scripts pass validation
- Single-stop docs index exists and stays current after generator runs
- Assistant uses generated docs instead of reading script code during tasks
