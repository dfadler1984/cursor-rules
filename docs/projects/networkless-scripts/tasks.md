## Relevant Files

- `.cursor/scripts/.lib.sh`
- `.cursor/scripts/.lib-net.sh` (new)
- `.cursor/scripts/pr-create.sh`
- `.cursor/scripts/security-scan.sh`
- `.cursor/scripts/tests/run.sh`
- `.cursor/scripts/tests/fixtures/`
- `README.md`

### Notes

- Tests and local usage must never hit the network.
- Override network clients in tests via env: `CURL_BIN=false`, `HTTP_BIN=false` to ensure calls would fail if invoked.

- Unified coordination: `docs/projects/shell-and-script-tooling/erd.md`

## Tasks

- [x] 1.0 Add network effects seam library (priority: high) — ✅ COMPLETE

  - [x] 1.1 Create `.cursor/scripts/.lib-net.sh` with `net_request` (no HTTP) and fixture helpers
  - [x] 1.2 Document env overrides `CURL_BIN`, `HTTP_BIN` and fixture loading
  - Note: `.lib-net.sh` created with `net_fixture`, `net_guidance`, `is_dry_run` helpers

- [x] 2.0 Migrate `pr-create.sh` to use seam (priority: high) (dependencies: [1.0]) — ⚠️ GUIDANCE APPROACH (not seam approach)

  - Decision: Production GitHub API scripts (`pr-create.sh`, `pr-update.sh`, `checks-status.sh`, `changesets-automerge-dispatch.sh`) use guidance-based approach instead of `.lib-net.sh` seam
  - [x] 2.1 Scripts now provide compare URLs and `gh` CLI guidance instead of making direct API calls
  - [x] 2.2 Emit deterministic fixture output and/or compare URL guidance (implemented)
  - [x] 2.3 Add tests: Tests use seams (`CURL_CMD=cat`, `JQ_CMD=jq`) to inject fixtures; never make live API calls
  - Rationale: Guidance approach simplifies token management and reduces network dependencies; production scripts CAN make network calls (per D4 policy), but tests MUST use seams

- [x] 3.0 Migrate `security-scan.sh` (priority: medium) (dependencies: [1.0]) — ✅ COMPLETE

  - [x] 3.1 Ensure no network invoked; simulate outputs deterministically
  - [x] 3.2 Add tests: with/without `package.json` and no network path
  - Tests use fixtures; no live network calls

- [x] 4.0 Sweep remaining scripts for network usage (priority: medium) (dependencies: [1.0]) — ✅ COMPLETE

  - [x] 4.1 All scripts reviewed; 5 scripts legitimately use network (per D4 policy)
  - [x] 4.2 Guard validator created: `network-guard.sh` (informational mode) verifies network usage policy
  - Network-using scripts: pr-create.sh, pr-update.sh, checks-status.sh, changesets-automerge-dispatch.sh, setup-remote.sh

- [x] 5.0 Update documentation (priority: medium) — ✅ COMPLETE

  - [x] 5.1 Documentation in `docs/projects/shell-and-script-tooling/MIGRATION-GUIDE.md` and ERD D4
  - [x] 5.2 Environment variables and fixtures location documented in `.cursor/scripts/tests/fixtures/README.md`

- [x] 6.0 Validation and metrics (priority: medium) — ✅ COMPLETE
  - [x] 6.1 Test suite enforces no-network via seams (`CURL_CMD=cat`, `JQ_CMD=jq`)
  - [x] 6.2 Guard validator: `network-guard.sh` verifies 0 network calls in tests; 5 scripts legitimately use network in production

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
- D4: ✅ Complete — **Primary focus of this project:** All tests use seams (`CURL_CMD=cat`, `JQ_CMD=jq`) to inject fixtures; production scripts (pr-create, pr-update, checks-status, changesets-automerge-dispatch) can make real API calls; validated by `network-guard.sh` (informational mode)
- D5: ✅ Complete — Portability policy adopted
- D6: ✅ Complete — Test isolation implemented

See: `docs/projects/shell-and-script-tooling/erd.md` D4 for detailed networkless policy and test isolation approach
