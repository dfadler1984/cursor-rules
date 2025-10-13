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

- [ ] 1.0 Add network effects seam library (priority: high)

  - [ ] 1.1 Create `.cursor/scripts/.lib-net.sh` with `net_request` (no HTTP) and fixture helpers
  - [ ] 1.2 Document env overrides `CURL_BIN`, `HTTP_BIN` and fixture loading

- [ ] 2.0 Migrate `pr-create.sh` to use seam (priority: high) (dependencies: [1.0])

  - [ ] 2.1 Replace direct `curl` with `net_request` (no HTTP)
  - [ ] 2.2 Emit deterministic fixture output and/or compare URL guidance (no API call)
  - [ ] 2.3 Add tests: missing token path is handled without reading env; outputs deterministic

- [ ] 3.0 Migrate `security-scan.sh` (priority: medium) (dependencies: [1.0])

  - [ ] 3.1 Ensure no network invoked; simulate outputs deterministically
  - [ ] 3.2 Add tests: with/without `package.json` and no network path

- [ ] 4.0 Sweep remaining scripts for network usage (priority: medium) (dependencies: [1.0])

  - [ ] 4.1 Replace any direct or transitive network calls with seam usage (no HTTP)
  - [ ] 4.2 Add a guard test that fails if `curl`/`gh` is executed at all

- [ ] 5.0 Update documentation (priority: medium)

  - [ ] 5.1 Update `README.md` with no-network policy, seam usage, and examples
  - [ ] 5.2 Note environment variables and fixtures location

- [ ] 6.0 Validation and metrics (priority: medium)
  - [ ] 6.1 Ensure test suite config enforces no-network and blocks clients by default
  - [ ] 6.2 Verify 0 network calls via guard test

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
