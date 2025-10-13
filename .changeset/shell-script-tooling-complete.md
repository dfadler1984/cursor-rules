---
"cursor-rules": patch
---

# Complete shell-and-script-tooling project (100%)

## Shell Script Standards & Tooling

Complete all remaining work for the shell-and-script-tooling unified project, achieving 100% standards compliance across all 36 maintained scripts and full adoption tracking across 8 source projects.

### Phase 4: Help Documentation (100% Complete)

- Fixed 4 remaining scripts to pass `help-validate.sh`:
  - `pr-create.sh`: Added Options section with template functions
  - `pr-update.sh`: Added Options, Examples, Exit Codes sections
  - `changesets-automerge-dispatch.sh`: Added Options, Examples, Exit Codes sections + strict mode
  - `checks-status.sh`: Added Examples, Exit Codes sections
- **Result**: All 36/36 scripts now have complete help documentation

### Phase 3: Adoption Tracking (100% Complete)

- Updated 8 source projects with D1-D6 adoption status and backlinks
- All projects document 100% adoption of cross-cutting decisions (D1-D6)

### Phase 6: Documentation & CI (100% Complete)

- Created comprehensive `MIGRATION-GUIDE.md` (373 lines) with step-by-step instructions
- Added CI enforcement via `.github/workflows/shell-validators.yml`
- Validators run on every PR: help and error validation block on failure

### Standards Compliance

All 36 scripts now comply with all 6 cross-cutting decisions:

- **D1** (100%): Help/Version with Options, Examples, Exit Codes sections
- **D2** (100%): Strict mode (`set -euo pipefail`)
- **D3** (100%): Standardized exit codes (EXIT_USAGE, EXIT_CONFIG, etc.)
- **D4** (100%): Test isolation (tests use seams/fixtures)
- **D5** (100%): Portability (bash + git only, graceful degradation)
- **D6** (100%): Environment isolation (subshell isolation in tests)

### Files Changed

- Modified: 4 scripts, 8 source project tasks.md, 3 project docs, 1 README
- Added: shell-validators.yml CI workflow, MIGRATION-GUIDE.md

See: `docs/projects/shell-and-script-tooling/` for full project documentation.
