---
status: completed
completed: 2025-10-28
owner: repo-maintainers
lastUpdated: 2025-10-28
---

# Engineering Requirements Document — Consent Gates Refinement

Mode: Lite

## 1. Introduction/Overview

Conduct a deep dive on consent-first gating and exceptions to fix issues where consent gates aren't working as expected.

**Context**: Current consent gating has exceptions (read-only commands, session allowlists, composite consent-after-plan) but the user reports these aren't working smoothly. Need to identify specific friction points and refine the flow.

**Reported issues** (collected 2025-10-22):

1. **Cursor commands over-gated** (High Priority): Slash commands (e.g., `/commit`, `/branch`, `/pr`) should execute without consent prompts. Typing `/commit` is already direct consent; asking "proceed?" adds unnecessary friction.

2. **Intent routing inconsistency** (Medium Priority): Same intent sometimes requires consent, sometimes doesn't, depending on routing path. Need specific examples to diagnose.

3. **Session allowlist visibility** (Enhancement): Not clear which commands currently have standing consent. Need `/allowlist` command to display active grants.

4. **Composite consent-after-plan** (Working as intended): Correctly re-asks consent when deviating from approved plan. No change needed.

5. **Under-prompting** (Low Priority): Risky operations occasionally execute without consent. Low frequency; needs monitoring for specific examples.

### Uncertainty / Assumptions

- **Clarified**: Primary issue is cursor commands (slash commands) being over-gated; should execute without consent prompt
- **Clarified**: Mixed direction—both too aggressive (cursor commands) and occasionally too lax (risky ops, but rare)
- Assumption: Core consent policy is in `assistant-behavior.mdc`
- [OPEN: Need specific examples of intent routing inconsistency]
- **Portability consideration**: Rules/scripts in this repo serve two purposes:
  - **Repo-specific**: Project lifecycle, ERD workflows, rule management (not portable)
  - **Reusable**: TDD rules, code style, testing conventions, consent patterns (should be portable to other projects)
- **Platform portability**: All scripts/rules must work on Linux and macOS environments

## 2. Goals/Objectives

- Identify specific failures in consent gating (over-prompting, under-prompting, unclear exceptions)
- Streamline exception handling for safe/obvious operations
- Improve user experience without compromising safety
- Create clear, predictable consent behavior

## 3. User Stories

- As a user, I want obvious read-only commands to execute without extra prompts
- As a user, I want risky operations to always require explicit consent
- As a user, I want session allowlists to work consistently
- As a user, I want consent-after-plan to recognize when I've already approved

## 4. Functional Requirements

### 4.1 Analysis Phase

1. Document recent consent gate issues (over-prompting, missed gates, unclear state)
2. Categorize operations by risk: safe (read-only) → moderate (local edits) → risky (git push, destructive)
3. Review current exception mechanisms (read-only allowlist, session allowlist, composite consent)
4. Identify gaps: operations that should be in allowlist but aren't, or vice versa

### 4.2 Refinement Phase

1. **Fix slash command bypass**: Add explicit check in `assistant-behavior.mdc` lines 22-27 to skip consent gate for cursor commands
2. **Implement session allowlist visibility**: Add `/allowlist` cursor command and natural language trigger ("show allowlist")
3. Expand safe read-only allowlist based on common operations
4. Clarify session allowlist grant/revoke workflow (document explicit syntax)
5. Improve composite consent-after-plan detection (better signal matching)
6. Add explicit "consent state" tracking across turns
7. Create consent decision flowchart for assistant reference

## 5. Non-Functional Requirements

- **Safety first**: Default to asking when uncertain
- **Predictability**: Same operation should yield same consent behavior
- **Transparency**: User always knows why consent was requested or skipped
- **Minimal friction**: Eliminate redundant prompts for safe operations
- **Portability**: Consent rules must distinguish repo-specific vs reusable patterns
- **Platform compatibility**: Scripts and rules must work on Linux and macOS (POSIX-compatible where possible)

## 6. Architecture/Design

### Current State: Exception Mechanisms

**Analyzed**: `.cursor/rules/assistant-behavior.mdc` and `.cursor/rules/intent-routing.mdc` (2025-10-22)

1. **One-shot consent** (lines 22-27): First command per tool category requires consent
2. **Read-only allowlist** (lines 42-54): Imperative phrasing + safe command (git status, etc.) → execute without prompt
3. **Session allowlist** (lines 62-82): User grants standing consent for named commands; assistant records and announces but doesn't re-prompt
4. **Slash commands** (lines 98-106): Slash command invocation IS direct consent — **Gap: Policy exists but not enforced**
5. **Composite consent-after-plan** (lines 108-111): Previous plan + "go ahead" → implementation without re-asking

**Identified gaps**:

- 🔴 **Slash commands not bypassing consent gate** (policy exists but not enforced in practice)
- ⚠️ **No visibility mechanism** for session allowlist (user can't query active grants)
- ⚠️ **No explicit revoke command** documented
- ⚠️ **Deviation triggers undocumented** (what counts as deviating from a plan)

### Proposed Improvements

1. **Risk-based gating** (operations categorized by risk)

   **Tier 1 (Safe - No consent)**:

   - Cursor commands: `/commit`, `/pr`, `/branch`, `/allowlist`
   - Read-only git: `git status`, `git log`, `git diff --stat`, `git branch --show-current`
   - File reads: `read_file`, `list_dir`, `grep`, `codebase_search`
   - Read-only scripts: rules-list, rules-validate (without --autofix), tdd-scope-check

   **Tier 2 (Moderate - One-shot per category)**:

   - Local file edits: write, search_replace, delete_file
   - Local git ops: `git add`, `git checkout -b`, `git stash`
   - Test runs: `yarn test`, `npm test`
   - Non-destructive scripts: git-commit.sh, git-branch-name.sh

   **Tier 3 (Risky - Always ask)**:

   - Remote git: `git push`, `git push --force`
   - Destructive git: `git reset --hard`, `git clean -fd`, `git branch -D`
   - Network: web_search, API calls
   - Security-sensitive: secrets access, .git/ modifications

2. **Consent state persistence**

   - Track `consentState: granted|required|not-applicable` per operation
   - Carry state across turns within same workflow

3. **Clearer exception triggers**

   - Imperative phrasing + safe command → execute
   - Previous concrete plan + consent phrase → implementation
   - Add confidence check: if uncertain, ask once

4. **Session allowlist improvements**

   - Standardize grant format: "Grant standing consent for: `<command>`"
   - Add revoke command: "Revoke consent for: `<command>`" (needs design/syntax clarification)
   - Show active allowlist on request (implement `/allowlist` cursor command + natural language "show allowlist")
   - Visibility mechanism: display active grants with format, timestamps, revoke instructions

5. **Portability classification**

   - Mark consent behaviors as "repo-specific" vs "portable"
   - Repo-specific: Project lifecycle gates, ERD workflow consent, rule management operations
   - Portable: TDD pre-edit gate, git operations, file edits, testing consent patterns
   - Document which rules/scripts are intended for export vs local use only

6. **Platform compatibility**
   - Use POSIX-compatible shell features where possible
   - Document Linux/macOS differences and provide alternatives
   - Test scripts on both platforms before considering complete

## 7. Data Model and Storage

### Consent State (per operation)

```typescript
{
  "operation": "git-commit|pr-create|edit-file|...",
  "risk": "safe|moderate|risky",
  "consentState": "granted|required|not-applicable",
  "source": "explicit|allowlist|composite|exception",
  "timestamp": "ISO-8601"
}
```

## 8. API/Contracts

### Consent Decision Output

```json
{
  "operation": "git-commit",
  "command": "git commit -m 'feat: add feature'",
  "risk": "moderate",
  "consentRequired": true,
  "reason": "First git command in turn",
  "allowlistEligible": true
}
```

## 9. Integrations/Dependencies

- Related: `assistant-behavior.mdc` (consent-first section)
- Related: `security.mdc` (command execution rules)
- Related: `user-intent.mdc` (intent classification)
- Scripts: Consider adding `.cursor/scripts/consent-audit.sh` to review consent decisions

## 10. Edge Cases and Constraints

- **Ambiguous imperative**: "Can you commit?" (question or directive?)
- **Multi-step workflows**: Plan → implement → test → commit (consent at each step?)
- **Category switch mid-turn**: Local edit → git commit (requires fresh consent?)
- **Retry after failure**: Command failed, retry with fix (re-ask consent?)
- **Portability boundary**: Some consent behaviors apply only to this repo's workflows (e.g., project lifecycle gates) vs universal patterns (e.g., TDD pre-edit gate)
- **Platform variations**: Command syntax differences between Linux and macOS (e.g., `stat`, `sed`, `grep` flags)

## 11. Testing & Acceptance

### Test Cases

1. **Safe read-only**: "Run `git status`" → execute without prompt
2. **Obvious risky**: "Push to main" → always ask consent
3. **Session allowlist**: Grant consent for `git-commit.sh`, then request commit → execute
4. **Composite consent**: Previous plan + "go ahead" → implementation without re-asking
5. **Ambiguous**: "We should commit" → ask clarification
6. **Category switch**: Edit file (granted) → then `git add` → ask consent for git category

### Acceptance Criteria

The solution is complete when:

- **Analysis complete**: Baseline issues documented, operations categorized by risk tier, exception gaps identified ✅
- **Core fixes implemented**: Slash commands bypass consent gate, `/allowlist` visibility mechanism exists, grant/revoke syntax documented ✅
- **Risk-based gating functional**: Operations categorized into safe/moderate/risky tiers with appropriate consent behavior ✅
- **Test coverage adequate**: Consent test suite covers ≥15 scenarios including slash commands, allowlist, edge cases ✅
- **User validation positive**: Smoother consent flow reported, safety maintained (zero inappropriate risky operations) ✅ (slash commands validated)
- **Portability clarity**: Consent behaviors marked as repo-specific vs reusable (if in scope) ⏸️ Deferred
- **Platform compatibility**: Scripts work on Linux and macOS (if in scope) ⏸️ Deferred
- **Documentation complete**: Clear guidance on which features are reusable in other projects (if in scope) ⏸️ Deferred

**Project Status**: ✅ **Completed** 2025-10-28 (early completion assessment)

**Observational Validation Extracted**: Extended validation tasks moved to [consent-gates-monitoring](../consent-gates-monitoring/) (started 2025-10-28)

Evidence of completion:

- Analysis documents: Risk tiers defined, exception gaps identified (consolidated in ERD)
- Implementation artifacts: Modified 3 rules files, created 5 specification documents (~2,750 lines)
- Validation results: Real-session testing confirms slash commands work without prompts (4/4 tests passed)
- Test suite: 33 scenarios created (220% of minimum requirement)
- Observational validation: Extracted to [consent-gates-monitoring](../consent-gates-monitoring/) for organic tracking

## 12. Rollout Plan

**Approach**: Phased rollout with validation gates

1. **Phase 1 (Analysis)**: Document baseline, categorize operations, identify gaps
2. **Phase 2 (Implementation)**: Implement core fixes (slash command bypass, `/allowlist`, revoke syntax), defer additional refinements pending validation
3. **Phase 3 (Validation)**: Real-session testing (1-2 weeks), collect metrics, identify any new issues
4. **Phase 4 (Optional Refinements)**: Based on Phase 3 results, implement additional improvements if needed

**Validation gates**:

- After Phase 2: Core fixes must be implemented before moving to Phase 3 ✅ Complete
- After Phase 3: Positive user validation required before considering complete ✅ Complete (slash commands validated)
- Portability/platform work: Optional based on Phase 3 feedback → Deferred (not pursued)
- Extended observational validation: Extracted to [consent-gates-monitoring](../consent-gates-monitoring/) (2025-10-28)

**Rollback plan**: Rules are version-controlled; can revert to previous version if new issues introduced

## 13. Success Metrics

### Objective Measures

- **Over-prompting reduction**: % decrease in redundant consent requests (target: >50%)
  - **Status**: ✅ Achieved for slash commands (primary friction point)
  - **Extended tracking**: See [consent-gates-monitoring](../consent-gates-monitoring/)
- **Safety maintained**: Zero risky operations executed without consent
  - **Status**: ✅ No violations observed; risk tiers enforced
- **Allowlist usage**: % of safe commands using exception (target: >80%)
  - **Status**: ⏸️ Deferred to observational monitoring
- **Composite consent hit rate**: % of "go ahead" correctly recognized (target: >90%)
  - **Status**: ⏸️ Deferred to observational monitoring

### Qualitative Signals

- User reports fewer unnecessary prompts ✅ (slash commands validated)
- Risky operations still feel appropriately gated ✅ (risk tiers documented)
- Session allowlist is easy to understand and use ⏸️ (deferred to organic usage)

## 14. Open Questions

**Resolved During Implementation**:

1. **Risk classification**: ✅ Defined 3 tiers (see `risk-tiers.md`)
2. **State persistence**: ✅ Defined by tier and workflow (see `consent-state-tracking.md`)
3. **Multi-step consent**: ✅ Composite consent-after-plan mechanism (see `composite-consent-signals.md`)
4. **Failure retry**: ✅ Documented in state tracking reset conditions
5. **Revoke workflow**: ✅ Explicit syntax documented (grant/revoke/revoke-all)

**Extracted to Observational Monitoring** ([consent-gates-monitoring](../consent-gates-monitoring/)):

6. **Intent routing inconsistency examples**: Will document if observed during organic usage
7. **Portability boundary**: Deferred until reuse pattern emerges
8. **Platform testing**: Deferred; consent rules are platform-agnostic
9. **Export mechanism**: Deferred until portability needs validated

---

Owner: repo-maintainers  
Created: 2025-10-11  
Motivation: Consent gating and exceptions not working as smoothly as expected; need refinement for better UX without compromising safety
