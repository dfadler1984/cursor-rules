## Tasks — ERD: Script Test Hardening

## Relevant Files

- `.cursor/scripts/pr-update.sh`
- `.cursor/scripts/pr-create.sh`
- `.cursor/scripts/.lib.sh`
- `.cursor/scripts/tests/run.sh`
- `docs/projects/script-test-hardening/erd.md`

## Todo

- [ ] 1.0 Add token override flags (`--token` or `--github-token`) to pr-create.sh and pr-update.sh
- [ ] 2.0 Add `get_env(var, default)` helper in `.lib.sh` and route env reads through it
- [ ] 3.0 Update tests to pass explicit token flags; snapshot/restore env per test file
- [ ] 4.0 Add a lightweight linter in tests to detect `export`/`unset` of critical vars
- [ ] 5.0 Update README with guidance: flags over env in tests; sourcing not required
