## Relevant Files

- `.cursor/scripts/shellcheck-run.sh`
- `.shellcheckrc`
- `.github/workflows/shellcheck.yml` (optional)

### Notes

- TDD-first (Shell): add failing tests for the runner, then implement; see `tdd-first-sh.mdc` and `test-quality-sh.mdc`.
- Prefer minimal exclusions; when disabling a rule, include a brief rationale.

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Tasks

- [ ] 1.0 Implement local ShellCheck runner script (priority: high)

  - [ ] 1.1 Add usage/help and version flags
  - [ ] 1.2 Handle missing `shellcheck` binary with guidance
  - [ ] 1.3 Support `--paths`, `--exclude`, `--severity` options
  - [ ] 1.4 Exit non‑zero on findings; print summary
  - [ ] 1.5 Add focused shell tests under `.cursor/scripts/tests/`

- [ ] 2.0 Add project configuration (priority: medium)

  - [ ] 2.1 Create `.shellcheckrc` with sensible defaults
  - [ ] 2.2 Document suppression pattern with examples

- [ ] 3.0 Optional CI workflow (priority: low)

  - [ ] 3.1 Add `shellcheck.yml` workflow for PRs touching `*.sh`
  - [ ] 3.2 Ensure clear failure output and paths

- [ ] 4.0 Documentation (priority: medium)
  - [ ] 4.1 Update `README.md` with local and CI usage
  - [ ] 4.2 Add troubleshooting and common rule explanations

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — `shellcheck-run.sh` has full help documentation with Options, Examples, Exit Codes
- D2: ✅ Complete — `shellcheck-run.sh` uses strict mode
- D3: ✅ Complete — `shellcheck-run.sh` uses exit code catalog
- D4: ✅ Complete — N/A (shellcheck-run.sh is a local linter; no network usage)
- D5: ✅ Complete — **Primary focus:** `shellcheck-run.sh` degrades gracefully when shellcheck binary is absent (exits 0 with guidance); optional tool with clear installation instructions
- D6: ✅ Complete — Test isolation implemented

See: `docs/projects/shell-and-script-tooling/erd.md` D5 for portability policy and graceful degradation pattern
