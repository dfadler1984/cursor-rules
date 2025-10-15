## Tasks — ERD: Script Error Handling

## Relevant Files

- `.cursor/scripts/.lib.sh`
- `.cursor/scripts/error-validate.sh`
- `docs/projects/assistant-self-improvement/legacy/scripts/alp-logger.sh` (legacy; for reference only)
- `.cursor/scripts/pr-create.sh`
- `.cursor/scripts/pr-update.sh`
- `docs/projects/script-error-handling/erd.md`

### Notes

- Prefer centralized helpers: enable strict mode, traps, retries, tempdir cleanup.
- Keep validator simple and fast; allow explicit bypass comments for rare cases.
- Do not print secrets in error messages; redact where needed.

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [x] 1.0 Implement `.lib.sh` error-handling helpers — ✅ COMPLETE

  - [x] 1.1 Add `enable_strict_mode`, `die`, `warn`, `require_cmd`, `require_var` (enable*strict_mode, die, and log*\* implemented; require_cmd via have_cmd; require_var deferred as low priority)
  - [x] 1.2 Add `with_tempdir` and `on_exit_register` for deterministic cleanup (with_tempdir implemented; on_exit_register deferred—trap-based cleanup sufficient)
  - [ ] 1.3 Add `retry <attempts> <sleep>` wrapper with exponential backoff option — DEFERRED (low priority; not needed for current scripts)

- [x] 2.0 Create `error-validate.sh` — ✅ COMPLETE

  - [x] 2.1 Discover `.cursor/scripts/*.sh` excluding `*.test.sh`
  - [x] 2.2 Assert sourcing `.lib.sh` and calling `enable_strict_mode`
  - [x] 2.3 Verify `--help` includes Exit Codes section
  - [x] 2.4 Print concise report; exit non-zero on violations
  - All 37 scripts pass validation

- [x] 3.0 Migrate representative scripts — ✅ COMPLETE (All 37 scripts migrated)

  - [x] 3.1 Migrate `.cursor/scripts/alp-logger.sh` to helpers and strict mode (legacy version archived; active scripts use helpers)
  - [x] 3.2 Migrate `.cursor/scripts/pr-create.sh` and `pr-update.sh` (both migrated)
  - [x] 3.3 Confirm cleanup of temp artifacts and consistent exit codes (verified; all scripts use exit code catalog)

- [x] 4.0 Documentation and help alignment — ✅ COMPLETE

  - [x] 4.1 Add Exit Codes to `--help` outputs for migrated scripts (all 37 scripts have Exit Codes section)
  - [x] 4.2 Link error catalog from help and ERD; cross-link with help-generation project (documented in MIGRATION-GUIDE.md)

- [x] 5.0 Optional CI — ✅ COMPLETE

  - [x] 5.1 Add a CI step to run `error-validate.sh` on PRs (`.github/workflows/shell-validators.yml`)
  - [x] 5.2 Fail PRs when violations are detected; provide guidance to fix (blocking validation enabled)

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — 36/36 scripts pass `help-validate.sh`
- D2: ✅ Complete — 36/36 scripts validated by `error-validate.sh` (strict mode + proper traps)
- D3: ✅ Complete — All scripts use standardized exit codes (EXIT_USAGE, EXIT_CONFIG, EXIT_DEPENDENCY, etc.) and `die` helper from `.lib.sh`
- D4: ✅ Complete — Tests use seams; production scripts can make network calls per policy
- D5: ✅ Complete — All scripts portable (bash + git); optional deps have graceful degradation
- D6: ✅ Complete — Test runner isolates each test in subshell; no env leakage

See: `docs/projects/shell-and-script-tooling/erd.md` D2, D3 for detailed error handling standards and validators
