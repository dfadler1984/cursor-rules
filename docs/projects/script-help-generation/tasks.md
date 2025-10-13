## Tasks — ERD: Script Help Generation

## Relevant Files

- `.cursor/scripts/help-validate.sh`
- `.cursor/scripts/help-generate.sh`
- `.cursor/scripts/.lib.sh`
- `docs/projects/script-help-generation/erd.md`
- `docs/scripts/README.md`
- `docs/scripts/*.md`

### Notes

- Generating docs should run `--help` only and must not perform external effects.
- Prefer simple, robust parsing by enforcing a consistent help format in emitters.

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [x] 1.0 Create `help-validate.sh` (required sections check) — ✅ COMPLETE

  - [x] 1.1 Detect scripts under `.cursor/scripts/*.sh` excluding `*.test.sh`
  - [x] 1.2 For each script, run `--help` and verify sections: Name, Synopsis, Description, Options, Exit Codes
  - [x] 1.3 If missing sections, print a concise report and exit non-zero

- [x] 2.0 Create `help-generate.sh` (emit markdown from `--help`) — ⚠️ NOT IMPLEMENTED (Decision: Template approach used instead)

  - Decision: Instead of generating docs from `--help` output, scripts use `.lib.sh` template functions (`print_usage`, `print_options`, `print_option`, `print_examples`, `print_exit_codes`) to emit standardized help directly
  - Rationale: Template functions provide consistency without requiring a separate doc generation step; help is always in sync with implementation
  - See: `docs/projects/shell-and-script-tooling/MIGRATION-GUIDE.md` for template function usage
  - Tasks 2.1-2.4 superseded by template approach

- [x] 3.0 Update `.cursor/scripts/.lib.sh` helpers — ✅ COMPLETE

  - [x] 3.1 Add small helpers to print standardized help headers/sections (print_usage, print_options, print_option, print_examples, print_example, print_exit_codes)
  - [x] 3.2 Provide option formatting helper to align flags and defaults (built into print_option)

- [x] 4.0 Migrate representative scripts — ✅ COMPLETE (All 37 scripts migrated)

  - [x] 4.1 Update `pr-create.sh`, `git-branch-name.sh`, `rules-validate.sh` to emit standardized help
  - [x] 4.2 Ensure `--help` runs fast and without side effects
  - All 37 production scripts now use template functions and pass `help-validate.sh`

- [x] 5.0 Documentation and linkage — ⚠️ PARTIAL (Migration guide exists; docs/scripts/ not created)

  - Decision: `docs/scripts/README.md` not needed; template functions provide inline help standardization
  - [x] 5.2 Guidance included in `docs/projects/shell-and-script-tooling/MIGRATION-GUIDE.md`
  - [ ] 5.1 Link to `docs/scripts/README.md` from repo `README.md` — NOT APPLICABLE (directory not created)

- [x] 6.0 Optional CI — ✅ COMPLETE

  - [x] 6.1 Add a lightweight CI step to run `help-validate.sh` (`.github/workflows/shell-validators.yml`)
  - [x] 6.2 Fail PRs when required help sections are missing (blocking validation)

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — 36/36 scripts have standardized help using `.lib.sh` template functions (print_usage, print_options, print_option, print_examples, print_exit_codes); validated by `help-validate.sh`
- D2: ✅ Complete — All scripts use strict mode
- D3: ✅ Complete — All scripts use exit code catalog
- D4: ✅ Complete — Tests use seams
- D5: ✅ Complete — Portability policy adopted
- D6: ✅ Complete — Test isolation implemented

See: `docs/projects/shell-and-script-tooling/erd.md` D1 for detailed help documentation standards and validator
