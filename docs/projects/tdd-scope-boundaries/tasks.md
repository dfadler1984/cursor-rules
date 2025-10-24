# Tasks — TDD Scope Boundaries

## Phase 1: Scope Definition

- [ ] Document recent false positives (docs/configs triggering TDD gate)
- [x] Define explicit include/exclude globs for TDD scope
- [x] Create decision tree for TDD applicability
- [x] List edge cases and clarification thresholds

## Phase 2: Implementation

- [x] Update `tdd-first.mdc` with scope definition and decision tree
- [x] Add pre-edit scope check before TDD gate
- [x] Add status transparency: note "TDD: in-scope" or "TDD: exempt (reason)"
- [x] Create `.cursor/scripts/tdd-scope-check.sh <file>` validation helper

## Phase 3: Validation

- [x] Create TDD scope test suite with ≥10 file types (12 test cases, 24 assertions)
- [ ] Test with real workflows: code edits (TDD), docs (no TDD), configs (no TDD)
- [ ] Verify zero false negatives and zero false positives
- [x] Setup monitoring structure (findings/ folder, ACTIVE-MONITORING.md entry)
- [ ] Monitor for 1 week and adjust edge cases (Started: 2025-10-24, Ends: ~2025-10-31)

## Related Enhancement: Slash Command Consent

**Context**: During PR workflow for this project, discovered consent friction with slash commands (`/branch`, `/commit`, `/pr`)

- [x] Document policy: slash commands = explicit consent (no "Proceed?" needed)
- [x] Update `assistant-behavior.mdc` with new section
- [x] Update `commands.caps.mdc` with Git commands and policy reference
- [ ] Monitor: verify slash commands execute immediately without extra confirmation

**Rationale**: User typing `/commit` IS the consent; asking "Proceed?" after adds unnecessary friction.

## Monitoring Status

**Active**: Phase 3 validation monitoring (2025-10-24 to ~2025-10-31)

**Where to document findings**:

- Location: `docs/projects/tdd-scope-boundaries/findings/`
- Pattern: `issue-##-<short-name>.md` (individual files, numbered)
- See: `docs/projects/tdd-scope-boundaries/findings/README.md` for template

**What to monitor**:

- False negatives (code changes skip TDD gate) — **Priority: Critical**
- False positives (docs/configs trigger TDD gate)
- Ambiguity rate (% requiring clarification — target: <5%)
- Edge cases (file types not covered by globs)

**Cross-reference**: See `docs/projects/ACTIVE-MONITORING.md` for project scope boundaries

## Related Files

- `.cursor/rules/tdd-first.mdc`
- `.cursor/rules/testing.mdc`
- `.cursor/rules/code-style.mdc`
- `.cursor/rules/assistant-behavior.mdc` (slash command policy)
- `.cursor/rules/commands.caps.mdc` (command reference)
- `.cursor/scripts/tdd-scope-check.sh` (validation helper)
