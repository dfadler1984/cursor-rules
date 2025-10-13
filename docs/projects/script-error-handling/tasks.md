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

- [ ] 1.0 Implement `.lib.sh` error-handling helpers

  - [ ] 1.1 Add `enable_strict_mode`, `die`, `warn`, `require_cmd`, `require_var`
  - [ ] 1.2 Add `with_tempdir` and `on_exit_register` for deterministic cleanup
  - [ ] 1.3 Add `retry <attempts> <sleep>` wrapper with exponential backoff option

- [ ] 2.0 Create `error-validate.sh`

  - [ ] 2.1 Discover `.cursor/scripts/*.sh` excluding `*.test.sh`
  - [ ] 2.2 Assert sourcing `.lib.sh` and calling `enable_strict_mode`
  - [ ] 2.3 Verify `--help` includes Exit Codes section
  - [ ] 2.4 Print concise report; exit non-zero on violations

- [ ] 3.0 Migrate representative scripts

  - [ ] 3.1 Migrate `.cursor/scripts/alp-logger.sh` to helpers and strict mode (legacy reference lives under `docs/projects/assistant-self-improvement/legacy/scripts/`)
  - [ ] 3.2 Migrate `.cursor/scripts/pr-create.sh` and `pr-update.sh`
  - [ ] 3.3 Confirm cleanup of temp artifacts and consistent exit codes

- [ ] 4.0 Documentation and help alignment

  - [ ] 4.1 Add Exit Codes to `--help` outputs for migrated scripts
  - [ ] 4.2 Link error catalog from help and ERD; cross-link with help-generation project

- [ ] 5.0 Optional CI

  - [ ] 5.1 Add a CI step to run `error-validate.sh` on PRs
  - [ ] 5.2 Fail PRs when violations are detected; provide guidance to fix

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
