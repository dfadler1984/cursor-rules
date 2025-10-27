# Tasks — Consent Gates Refinement

## Phase 1: Analysis

- [x] Document recent consent gate issues (over-prompting, missed gates, unclear state) — Consolidated into ERD Section 1
- [x] Categorize common operations by risk: safe → moderate → risky (prioritize cursor commands as Tier 1) — Consolidated into ERD Section 6
- [x] Review current exception mechanisms and identify gaps — Consolidated into ERD Section 6
- [ ] Measure baseline: over-prompting rate, missed risky ops, exception usage — Requires real usage monitoring
- [ ] Answer open questions from ERD:
  - [ ] Collect specific examples of intent routing inconsistency (same request → different consent behavior)
  - [x] Design explicit revoke command syntax and behavior (per-command vs all-at-once) — Completed in Phase 2, documented in `assistant-behavior.mdc` line 80

## Phase 2: Refinement

### Core Consent Fixes (High Priority)

- [x] **Fix slash command bypass**: Modify `assistant-behavior.mdc` lines 22-27 to add explicit check: "If slash command, skip consent gate"
  - Added new section at line 29: "Exception — Slash commands bypass consent gate (HIGHEST PRIORITY)"
  - Slash commands now checked BEFORE other consent gate logic
  - Clear rationale documented: typing `/commit` IS the consent
- [x] **Implement `/allowlist` command**: Add to `intent-routing.mdc` slash commands section
  - Added to Session Management section at line 122 in intent-routing.mdc
  - Created cursor command file: `.cursor/commands/allowlist.md`
  - Displays active session standing consent grants
  - Includes revoke instructions in output format
- [x] **Add natural language trigger**: Route "show allowlist" / "list active consent" to display session state
  - Added intent trigger at line 33 in `intent-routing.mdc`
  - Multiple phrase variations supported: "show allowlist", "list session consent", "what has standing consent"
  - Works alongside `/allowlist` cursor command
- [x] **Document revoke syntax**: Add explicit revoke command format to `assistant-behavior.mdc` session allowlist section
  - Added Grant/Revoke/Query Syntax subsection at line 80
  - Grant format: `"Grant standing consent for: <exact-command>"`
  - Revoke formats: per-command OR all-at-once (`"Revoke all consent"`)
  - Query formats: natural language OR `/allowlist` cursor command
  - Standard output format specified with revoke instructions

### Additional Refinements

- [x] Define risk tiers with clear criteria and examples — Created `risk-tiers.md` with Tier 1/2/3 criteria, examples, decision flowchart
- [x] Expand safe read-only allowlist based on common operations — Updated `assistant-behavior.mdc` with expanded git commands and read-only scripts
- [x] Improve composite consent-after-plan signal detection — Created `composite-consent-signals.md` with high/medium confidence phrases, concreteness criteria, modification handling; updated `assistant-behavior.mdc`, `user-intent.mdc`, `intent-routing.mdc`
- [x] Add consent state tracking across turns — Created `consent-state-tracking.md` with state model, persistence rules, reset conditions; added section to `assistant-behavior.mdc`
- [x] Create consent decision flowchart for assistant reference — Created `consent-decision-flowchart.md` with comprehensive decision tree, matrix, templates

### Portability & Platform Compatibility

- [ ] Classify consent behaviors as repo-specific vs portable (mark in rules)
- [ ] Audit scripts for POSIX compatibility and document Linux/macOS differences
- [ ] Document which rules/scripts are reusable in other projects vs this-repo-only

## Phase 3: Validation

### Real-Session Testing

- [x] Test `/commit` executes without "Proceed?" prompt in real session — ✅ VALIDATED: Committed 4x without prompts (2025-10-22)
- [x] Test `/pr` executes without "Proceed?" prompt — ✅ VALIDATED: Created PR #155 without prompt (2025-10-22)
- [x] Test `/branch` executes without "Proceed?" prompt — ✅ VALIDATED: Created `dfadler1984/feat-consent-gates-core-fixes` without prompt (2025-10-22)
- [x] Test `/allowlist` displays current session state correctly — ✅ VALIDATED: Displayed empty allowlist without prompt (2025-10-22)
- [ ] Test natural language "show active allowlist" trigger works
- [ ] Test "Grant standing consent for: git push" adds to allowlist
- [ ] Test "Revoke consent for: git push" removes from allowlist
- [ ] Test "Revoke all consent" clears entire allowlist
- [ ] Monitor for intent routing inconsistency examples (collect specific cases)

### Test Suite Development

- [x] Create consent test suite with ≥15 test cases covering:
  - Slash command execution (no prompt) — 4 tests
  - Read-only allowlist (imperative + safe command) — 3 tests
  - Session allowlist (grant/revoke/query) — 5 tests
  - Composite consent-after-plan — 4 tests
  - Risk tiers — 4 tests
  - Category switches — 3 tests
  - State tracking — 4 tests
  - Ambiguous requests — 2 tests
  - Edge cases — 4 tests
  - **Total**: 33 test scenarios in `consent-test-suite.md`

### Platform Testing (If In Scope)

- [ ] Test scripts on Linux environment (bash, common distros)
- [ ] Test scripts on macOS environment (zsh, current OS version)

### Metrics Collection

- [ ] Measure over-prompting reduction (compare before/after) — Ongoing during monitoring period
- [ ] Verify safety maintained (zero inappropriate risky operations) — Ongoing during monitoring period
- [ ] Track allowlist usage patterns — Ongoing during monitoring period
- [ ] Monitor for 1-2 weeks, collect user feedback — Started 2025-10-24, ends ~2025-11-07

### Documentation Updates

- [ ] Update `assistant-behavior.mdc` if refinements needed based on validation
- [ ] Mark portability classifications (repo-specific vs reusable) if in scope
- [ ] Document Linux/macOS differences if platform work in scope

## Phase 4: Optional Refinements (Based on Phase 3 Results)

- [ ] Formalize risk-based gating thresholds (if validation shows gaps)
- [ ] Improve composite consent detection (if misses observed)
- [ ] Add consent state tracking across turns (if confusion occurs)
- [ ] Create consent decision flowchart (if helpful for debugging)

## Related Files

- `.cursor/rules/assistant-behavior.mdc` (consent-first section)
- `.cursor/rules/security.mdc` (command execution rules)
- `.cursor/rules/user-intent.mdc`
