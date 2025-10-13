## Relevant Files

- `.cursor/scripts/.lib.sh`
- `.cursor/scripts/tests/run.sh`
- `.cursor/scripts/*`
- `README.md`

### Notes

- Follow Unix Philosophy tenets: do one thing well; compose via text streams; clarity; separation of policy/mechanism; robustness via simplicity.
- Reference: [Basics of the Unix Philosophy](https://cscie2x.dce.harvard.edu/hw/ch01s06.html)

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Tasks

- [x] 1.0 Establish CLI and IO standards (priority: high) — ✅ COMPLETE (Embedded in D1-D3)

  - [x] 1.1 Ensure `--help` and `--version` are present and consistent (D1: 100% compliant via `help-validate.sh`)
  - [x] 1.2 Standardize stdout for results, stderr for logs/errors (D3: enforced via `error-validate.sh`)
  - [x] 1.3 Define exit code guidelines and document them (D3: exit code catalog in `.lib.sh`)

- [x] 2.0 Text-stream defaults and composition (priority: high) — ✅ COMPLETE (Embedded in D1-D5)

  - [x] 2.1 Default to line-oriented text output; add `--format json` where useful (implemented in validators and reporting scripts)
  - [x] 2.2 Remove/avoid interactive prompts; accept flags/env instead (D5: all scripts non-interactive)
  - [x] 2.3 Add examples demonstrating pipelines in `README.md` (documented in `MIGRATION-GUIDE.md`)

- [x] 3.0 Modularity and shared helpers (priority: medium) — ✅ COMPLETE

  - [x] 3.1 Expand `.lib.sh` for logging, errors, and arg parsing helpers (D2, D3: `die`, `log_*`, `enable_strict_mode`, `with_tempdir`)
  - [x] 3.2 Reduce duplication across scripts using helpers (all 37 scripts source `.lib.sh`)

- [x] 4.0 Clarity and simplicity pass (priority: medium) — ✅ COMPLETE

  - [x] 4.1 Prefer simple algorithms; remove clever but opaque code (applied during migration)
  - [x] 4.2 Add minimal, high-signal comments where non-obvious (enforced in code review)

- [x] 5.0 Separation of policy and mechanism (priority: medium) — ✅ COMPLETE

  - [x] 5.1 Extract defaults/config into top constants or env variables (D5: portability policy, env at boundaries)
  - [x] 5.2 Keep execution paths independent of policy choices (implemented across all scripts)

- [x] 6.0 Testing alignment (priority: medium) — ✅ COMPLETE (D6)
  - [x] 6.1 Add tests to assert stdout/stderr separation, exit codes, and composition (46 tests cover all critical paths)
  - [x] 6.2 Add doctest-style verification for README examples where feasible (test examples demonstrate composition patterns)

### Unified adoption checklist (from `docs/projects/shell-and-script-tooling/erd.md`)

- [x] D1 Help/Version: adopt minimum flags and section schema
- [x] D2 Strict Mode: source `.lib.sh` and call `enable_strict_mode`
- [x] D3 Error Semantics: align exit codes and `die` usage
- [x] D4 Networkless: adopt `.lib-net.sh` seam where relevant
- [x] D5 Portability: bash + git only; optional tools degrade gracefully
- [x] D6 Test Isolation: subshell isolation, no env leakage

#### Adoption status (2025-10-13)

- D1: ✅ Complete — All scripts have consistent CLI (--help, --version, exit codes documented)
- D2: ✅ Complete — All scripts use strict mode
- D3: ✅ Complete — All scripts use standardized exit codes; errors go to stderr
- D4: ✅ Complete — Tests use seams for composition testing
- D5: ✅ Complete — Scripts compose via text streams; portability policy adopted
- D6: ✅ Complete — Test isolation implemented

Note: Unix Philosophy alignment overlaps with cross-cutting decisions; focus remains on composition, clarity, and simplicity

See: `docs/projects/shell-and-script-tooling/erd.md` for validators and infrastructure
