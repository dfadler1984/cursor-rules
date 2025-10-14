## Tasks — ERD: Bash Script Standards

## Relevant Files

- `docs/projects/bash-scripts/erd.md`

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [x] 1.0 Draft ERD skeleton with safety and header — ✅ COMPLETE
- [x] 2.0 Add example header and safe patterns — ✅ COMPLETE (Embedded in D1-D6)
  - Decision: Example headers and safe patterns documented in `shell-and-script-tooling/MIGRATION-GUIDE.md` instead of separate ERD sections
  - All 37 scripts demonstrate standardized patterns (strict mode, exit codes, help template functions)
  - See: Section 1 (Shebang and Strict Mode), Section 3 (Exit Code Constants) in MIGRATION-GUIDE.md
- [x] 3.0 Link ERD from README and progress doc — ✅ COMPLETE
  - ERD linked from `docs/projects/README.md` under unified `shell-and-script-tooling` project
  - Cross-references exist in all related project ERDs and tasks files

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam if applicable
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — 36/36 scripts pass `help-validate.sh` (Options, Examples, Exit Codes sections)
- D2: ✅ Complete — 36/36 scripts use strict mode (`set -euo pipefail`, source `.lib.sh`)
- D3: ✅ Complete — All scripts use exit code catalog (EXIT_USAGE=2, EXIT_CONFIG=3, etc.)
- D4: ✅ Complete — Tests use seams/fixtures; production scripts can make real API calls (per D4 policy)
- D5: ✅ Complete — All scripts require bash + git only; optional tools (jq, column, shellcheck) degrade gracefully
- D6: ✅ Complete — Test runner uses subshell isolation; env vars don't leak across tests

See: `docs/projects/shell-and-script-tooling/erd.md` for detailed status and validators
