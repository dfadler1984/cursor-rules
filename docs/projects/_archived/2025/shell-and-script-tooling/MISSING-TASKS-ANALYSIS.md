# Missing Tasks Analysis — Shell & Script Tooling

**Date:** 2025-10-13  
**Purpose:** Document tasks that were planned but not implemented, with rationale and alternative approaches

## Overview

During the shell-and-script-tooling project, several originally-planned tasks were intentionally not implemented. This document explains each missing task, the decision rationale, and what was done instead.

## Summary Table

| Original Task                          | Status          | Reason                      | Alternative/Outcome                                              |
| -------------------------------------- | --------------- | --------------------------- | ---------------------------------------------------------------- |
| `help-generate.sh`                     | Not Implemented | Template approach chosen    | `.lib.sh` template functions provide inline help standardization |
| `script-rules-validate.sh`             | Not Created     | Functionality merged        | Split into `help-validate.sh` and `error-validate.sh`            |
| `.shellcheckrc`                        | Not Created     | Inline config sufficient    | `shellcheck-run.sh` uses `--exclude` and `--severity` flags      |
| `docs/scripts/` doc generation         | Not Created     | Template approach chosen    | Scripts use template functions; help is always in sync           |
| Token override flags                   | Not Implemented | D6 solved root cause        | Test runner subshell isolation prevents env leakage              |
| `get_env()` helper                     | Not Implemented | Not needed with D6          | Subshell isolation provides superior protection                  |
| Test snapshot/restore                  | Superseded      | D6 subshells eliminate need | Tests directly export vars; runner provides cleanup              |
| `require_param`, `resolve_env_default` | Deferred        | Low priority                | `die` and basic validation sufficient for current needs          |
| `retry()` wrapper                      | Deferred        | Low priority                | Not needed for current script set                                |

## Detailed Analysis

### 1. `help-generate.sh` — Not Implemented

**Original plan:** Create a script to parse `--help` output from scripts and generate markdown docs under `docs/scripts/`.

**Decision:** Use template functions instead of doc generation.

**Rationale:**

- Template functions (`print_usage`, `print_options`, `print_option`, `print_examples`, `print_exit_codes`) provide consistency without requiring a separate doc generation step
- Help is always in sync with implementation (no risk of stale docs)
- Simpler maintenance model: edit help in-place rather than regenerating docs
- All 37 scripts now use template functions

**What was done:**

- Added template functions to `.lib.sh`
- Migrated all 37 scripts to use template functions
- Created `docs/scripts/README.md` as a script inventory (not generated docs)
- Documented usage in `MIGRATION-GUIDE.md`

**Research notes:**

- If separate markdown docs are needed in the future, they can be generated from the standardized template function output
- Template functions already provide structured, parseable output (consistent sections, formatting)
- Trade-off: Discoverability (separate docs) vs maintainability (inline help always current)

---

### 2. `script-rules-validate.sh` — Not Created

**Original plan:** Create a monolithic validator to check all script rules (help, strict mode, exit codes, env access).

**Decision:** Split functionality across specialized validators.

**Rationale:**

- Specialized validators (`help-validate.sh`, `error-validate.sh`, `network-guard.sh`) are more maintainable
- Each validator has a focused responsibility
- Easier to run subset of validations (e.g., only help validation)
- Better error messages (validator name indicates failure category)
- Direct env access detection (1.3) deferred as low priority; handled in code review

**What was done:**

- Created `help-validate.sh` (D1 compliance)
- Created `error-validate.sh` (D2/D3 compliance)
- Created `network-guard.sh` (D4 informational)
- Created `shellcheck-run.sh` (D5 optional linting)

**Research notes:**

- All planned validation is covered by the specialized validators
- If a unified validator is needed, it could orchestrate the specialized ones
- Current approach allows granular CI integration (some validators blocking, some informational)

---

### 3. `.shellcheckrc` — Not Created

**Original plan:** Create a project-wide `.shellcheckrc` configuration file.

**Decision:** Use inline configuration via `shellcheck-run.sh` flags.

**Rationale:**

- Inline config provides flexibility (different exclusions for different script sets)
- Keeps configuration explicit per-invocation
- `.shellcheckrc` would add another config file without clear benefit
- Current approach works well: `shellcheck-run.sh` passes validation

**What was done:**

- `shellcheck-run.sh` supports `--exclude`, `--severity`, `--format` flags
- Scripts use inline `# shellcheck disable=SCXXXX` directives when needed
- Documentation in `MIGRATION-GUIDE.md` covers suppression patterns

**Research notes:**

- If consistent global exclusions emerge, `.shellcheckrc` could be added later
- Current inline approach makes overrides explicit and auditable
- Trade-off: Flexibility vs centralized defaults

---

### 4. `docs/scripts/` Doc Generation — Not Created

**Original plan:** Generate separate markdown files for each script under `docs/scripts/`.

**Decision:** Create inventory README instead of per-script docs.

**Rationale:**

- Template functions provide consistent inline help
- Per-script docs would duplicate help output
- Inventory approach provides discoverability without duplication
- Help is always in sync (no stale docs risk)

**What was done:**

- Created `docs/scripts/README.md` with script categories and inventory
- All scripts provide `--help` with standardized sections
- Migration guide documents help usage patterns

**Research notes:**

- If separate docs are needed (e.g., for website generation), template function output can be scraped
- Current approach prioritizes maintainability over separate artifacts
- Trade-off: Single source of truth vs separate browsable docs

---

### 5. Token Override Flags — Not Implemented

**Original plan:** Add `--token` flags to GitHub API scripts (pr-create.sh, pr-update.sh) to avoid env var reads in tests.

**Decision:** D6 subshell isolation solved the root cause.

**Rationale:**

- D6 (Test Isolation) runs each test in a subshell, preventing env var leakage
- Token override flags add complexity without addressing the root cause
- Subshell isolation protects all env vars, not just tokens
- Tests can directly export vars; runner provides automatic cleanup

**What was done:**

- Implemented D6: Test runner (`.cursor/scripts/tests/run.sh`) runs each test in subshell
- Removed snapshot/restore patterns from tests (e.g., `pr-create.test.sh`)
- Added regression test: `run.env-isolation.test.sh`
- Documented pattern in `MIGRATION-GUIDE.md` Section 7

**Research notes:**

- Token flags could still be added for user convenience, but not needed for test isolation
- D6 is the canonical solution for test env isolation
- Trade-off: Feature flags vs architectural solution

---

### 6. `get_env()` Helper — Not Implemented

**Original plan:** Add `get_env(var, default)` helper to centralize env var reads.

**Decision:** Not needed with D6 subshell isolation.

**Rationale:**

- Helper adds boilerplate without addressing root cause
- D6 subshell isolation provides superior protection
- Scripts can read env vars directly; tests inject via subshell exports
- No evidence of env-related bugs after D6 implementation

**What was done:**

- D6 subshell isolation implemented
- Tests verified: env vars don't leak across tests
- 46/46 tests passing with direct env var usage

**Research notes:**

- If env var reading patterns become complex, helper could be added later
- Current approach is simple and works well
- Trade-off: Centralized abstraction vs direct usage

---

### 7. Test Snapshot/Restore — Superseded

**Original plan:** Implement env var snapshot/restore in tests to prevent leakage.

**Decision:** D6 subshells eliminate the need.

**Rationale:**

- Snapshot/restore is boilerplate that masks the root problem
- D6 runner's subshell isolation is cleaner and handles all env changes
- Tests become simpler: set vars, run script, assert—no cleanup needed
- Single point of control (runner) vs per-test patterns

**What was done:**

- Removed snapshot/restore from `pr-create.test.sh`
- All tests now directly export vars
- Runner provides automatic cleanup via subshell
- Pattern documented in `MIGRATION-GUIDE.md`

**Research notes:**

- D6 is the definitive solution; snapshot/restore should not be reintroduced
- If env leakage reappears, verify runner's subshell implementation
- Trade-off: Per-test boilerplate vs architectural isolation

---

### 8. `require_param`, `resolve_env_default` — Deferred

**Original plan:** Add helpers to validate required parameters and resolve env vars with defaults.

**Decision:** Deferred as low priority; basic validation sufficient.

**Rationale:**

- Current pattern (`[ -n "$VAR" ] || die "$EXIT_USAGE" "..."`) is explicit and works well
- Helpers would save a few lines but add abstraction
- No evidence of validation bugs in current scripts
- Can be added later if validation patterns become complex

**What was done:**

- Scripts use inline validation with `die` helper
- Exit code constants provide semantic error codes
- All 37 scripts pass validation

**Research notes:**

- If validation becomes repetitive or error-prone, revisit these helpers
- Consider DSL-style validation if complexity grows
- Trade-off: Simplicity vs abstraction

---

### 9. `retry()` Wrapper — Deferred

**Original plan:** Add `retry <attempts> <sleep>` wrapper with exponential backoff.

**Decision:** Deferred; not needed for current scripts.

**Rationale:**

- No current scripts require retry logic
- Adding unused infrastructure increases maintenance burden
- Can be added when a concrete use case emerges (e.g., flaky network calls)

**What was done:**

- Nothing; task deferred until needed

**Research notes:**

- If retry logic is needed, consider pattern: `retry 3 5 command` or `retry command`
- Exponential backoff useful for API rate limiting
- Trade-off: Anticipatory infrastructure vs YAGNI

---

## Design Principles Observed

All missing task decisions align with these principles:

1. **YAGNI (You Aren't Gonna Need It):** Don't add infrastructure without concrete use cases
2. **Single Source of Truth:** Prefer inline help over generated docs to avoid staleness
3. **Root Cause Solutions:** D6 subshell isolation > token flags or snapshot/restore
4. **Separation of Concerns:** Specialized validators > monolithic validator
5. **Simplicity:** Inline validation > helper abstraction when patterns are simple

## Future Considerations

### If These Tasks Are Revisited

**`help-generate.sh`:**

- Trigger: Need for browsable docs website or searchable help index
- Approach: Parse template function output; maintain as derivable artifact

**`script-rules-validate.sh`:**

- Trigger: Need for single-command validation in local dev
- Approach: Orchestrate existing specialized validators

**`.shellcheckrc`:**

- Trigger: Common exclusions emerge across many scripts
- Approach: Create config; keep inline overrides for exceptions

**Token override flags:**

- Trigger: User requests for convenience (not needed for isolation)
- Approach: Add flags but keep D6 subshells for test isolation

**Retry wrapper:**

- Trigger: Flaky network calls or rate-limited APIs
- Approach: Implement with exponential backoff and max attempts

---

## Validation

All decisions validated by:

- ✅ 37/37 scripts pass `help-validate.sh` (D1 compliance)
- ✅ 37/37 scripts pass `error-validate.sh` (D2/D3 compliance)
- ✅ 46/46 tests passing (D6 isolation working)
- ✅ Network guard informational (5 scripts legitimately use network, per D4)
- ✅ CI enforcement (`.github/workflows/shell-validators.yml`)

---

**Conclusion:** All "missing" tasks represent intentional design decisions, not oversights. Alternative approaches were chosen based on simplicity, maintainability, and root-cause solutions.
