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

- [ ] D1 Help/Version: adopt minimum flags and section schema
- [ ] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [ ] D3 Error Semantics: align exit codes and `die` usage
- [ ] D4 Networkless: adopt `.lib-net.sh` seam where relevant

#### Adoption status

- D1: Not started —
- D2: Not started —
- D3: Not started —
- D4: Not started —
