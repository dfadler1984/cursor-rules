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
  - Added to Session Management section at line 122
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

- [ ] Define risk tiers with clear criteria and examples
- [ ] Expand safe read-only allowlist based on common operations
- [ ] Improve composite consent-after-plan signal detection
- [ ] Add consent state tracking across turns
- [ ] Create consent decision flowchart for assistant reference

### Portability & Platform Compatibility

- [ ] Classify consent behaviors as repo-specific vs portable (mark in rules)
- [ ] Audit scripts for POSIX compatibility and document Linux/macOS differences
- [ ] Document which rules/scripts are reusable in other projects vs this-repo-only

## Phase 3: Validation

### Real-Session Testing

- [ ] Test `/commit` executes without "Proceed?" prompt in real session
- [ ] Test `/pr` executes without "Proceed?" prompt
- [x] Test `/branch` executes without "Proceed?" prompt — ✅ VALIDATED: Created `dfadler1984/feat-consent-gates-core-fixes` without prompt (2025-10-22)
- [ ] Test `/allowlist` displays current session state correctly
- [ ] Test natural language "show active allowlist" trigger works
- [ ] Test "Grant standing consent for: git push" adds to allowlist
- [ ] Test "Revoke consent for: git push" removes from allowlist
- [ ] Test "Revoke all consent" clears entire allowlist
- [ ] Monitor for intent routing inconsistency examples (collect specific cases)

### Test Suite Development

- [ ] Create consent test suite with ≥15 test cases covering:
  - Slash command execution (no prompt)
  - Read-only allowlist (imperative + safe command)
  - Session allowlist (grant/revoke/query)
  - Composite consent-after-plan
  - Category switches
  - Ambiguous requests
  - Edge cases

### Platform Testing (If In Scope)

- [ ] Test scripts on Linux environment (bash, common distros)
- [ ] Test scripts on macOS environment (zsh, current OS version)

### Metrics Collection

- [ ] Measure over-prompting reduction (compare before/after)
- [ ] Verify safety maintained (zero inappropriate risky operations)
- [ ] Track allowlist usage patterns
- [ ] Monitor for 1-2 weeks, collect user feedback

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
