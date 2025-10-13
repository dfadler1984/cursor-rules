## Tasks — ERD: Bash Script Standards

## Relevant Files

- `docs/projects/bash-scripts/erd.md`

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Todo

- [x] 1.0 Draft ERD skeleton with safety and header
- [ ] 2.0 Add example header and safe patterns
- [ ] 3.0 Link ERD from README and progress doc

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
