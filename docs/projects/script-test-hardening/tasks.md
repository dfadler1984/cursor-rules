## Tasks — ERD: Script Test Hardening

## Relevant Files

- `.cursor/scripts/pr-update.sh`
- `.cursor/scripts/pr-create.sh`
- `.cursor/scripts/.lib.sh`
- `.cursor/scripts/tests/run.sh`
- `docs/projects/script-test-hardening/erd.md`

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [ ] 1.0 Add token override flags (`--token` or `--github-token`) to pr-create.sh and pr-update.sh
- [ ] 2.0 Add `get_env(var, default)` helper in `.lib.sh` and route env reads through it
- [ ] 3.0 Update tests to pass explicit token flags; snapshot/restore env per test file
- [ ] 4.0 Add a lightweight linter in tests to detect `export`/`unset` of critical vars
- [ ] 5.0 Update README with guidance: flags over env in tests; sourcing not required

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — All scripts have help documentation
- D2: ✅ Complete — All scripts use strict mode
- D3: ✅ Complete — All scripts use exit code catalog
- D4: ✅ Complete — Tests use seams
- D5: ✅ Complete — Portability policy adopted
- D6: ✅ Complete — **Primary focus of this project:** Test runner isolates each test in subshell (`.cursor/scripts/tests/run.sh`); env vars don't leak across tests; tmp directories use `.test-artifacts/` with proper cleanup traps; resolved tmp-scan/ and .github/ deletion issues

See: `docs/projects/shell-and-script-tooling/erd.md` D6 and `docs/projects/tests-github-deletion/erd.md` for detailed test isolation approach and fixes
