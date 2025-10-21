# AlwaysApply Rules Review — Comprehensive Analysis

**Date**: 2025-10-20  
**Purpose**: Review all rules to determine optimal alwaysApply settings based on validated enforcement patterns

---

## Executive Summary

**Current State**:

- 20 rules with `alwaysApply: true` (always loaded)
- 25 rules with `alwaysApply: false` (conditionally loaded)
- 11 `.caps.mdc` files (capabilities summaries, no alwaysApply field)

**Validated Patterns**:

- ✅ AlwaysApply: 96% compliance for `assistant-git-usage.mdc` (was 74%)
- ❌ Hooks: Not available (organization policy)
- ⏸️ Commands/Prompt templates: Unexplored
- ✅ External validation: 100% where implemented (CI/pre-commit)

**Key Finding**: AlwaysApply works but has context cost (~2k tokens per rule). Need to be selective about which rules get always-on status.

---

## Current AlwaysApply Rules (20 total)

### Core Laws & Behavior (4 rules)

**1. `00-assistant-laws.mdc`** — alwaysApply: true ✅

- **Why**: Fundamental truth/accuracy/consistency requirements
- **Must be always-on**: Yes (foundation for all behavior)
- **Recommendation**: Keep alwaysApply: true

**2. `assistant-behavior.mdc`** — alwaysApply: true ✅

- **Why**: Consent-first, status updates, TDD gates, send gate
- **Validated**: H2 visible gate at 100% visibility
- **Must be always-on**: Yes (cross-cutting behavioral requirements)
- **Recommendation**: Keep alwaysApply: true

**3. `user-intent.mdc`** — alwaysApply: true ✅

- **Why**: Intent classification (guidance vs implementation)
- **Supports**: Guidance-first, scope-check protocols
- **Must be always-on**: Yes (affects routing and consent)
- **Recommendation**: Keep alwaysApply: true

**4. `global-defaults.mdc`** — alwaysApply: true ✅

- **Why**: Links to consent-first, status, TDD, citations (avoid duplication)
- **Must be always-on**: Yes (referenced by many other rules)
- **Recommendation**: Keep alwaysApply: true

### Git & Repository Operations (4 rules)

**5. `assistant-git-usage.mdc`** — alwaysApply: true ✅ **VALIDATED**

- **Why**: Script-first for git operations, conventional commits
- **Validated**: 74% → 96% compliance after alwaysApply enabled
- **Evidence**: H1 validation with 8 commits (96% rate)
- **Must be always-on**: Yes (critical workflow, proven improvement)
- **Recommendation**: Keep alwaysApply: true

**6. `git-slash-commands.mdc`** — alwaysApply: true ⚠️

- **Why**: Experimental slash commands for git operations
- **Status**: Runtime routing wrong (Cursor uses `/` for prompt templates)
- **Recommendation**: **Change to alwaysApply: false** (experiment failed, not used)

**7. `github-api-usage.mdc`** — alwaysApply: true ✅

- **Why**: No GH CLI constraint, use scripts for PRs
- **Must be always-on**: Yes (critical constraint, prevents errors)
- **Recommendation**: Keep alwaysApply: true

**8. `github-config-only.mdc`** — alwaysApply: true ✅

- **Why**: Keep `.github/` for platform config only
- **Must be always-on**: Yes (prevents scope creep)
- **Recommendation**: Keep alwaysApply: true

### Code Quality & Style (3 rules)

**9. `code-style.mdc`** — alwaysApply: true ✅

- **Why**: Functional/declarative style for all JS/TS
- **Must be always-on**: Yes (affects all code edits)
- **Recommendation**: Keep alwaysApply: true

**10. `dependencies.mdc`** — alwaysApply: true ✅

- **Why**: Dependency selection policy, lockfile enforcement
- **Must be always-on**: Yes (prevents security/quality issues)
- **Recommendation**: Keep alwaysApply: true

**11. `security.mdc`** — alwaysApply: true ✅

- **Why**: Secrets handling, command execution safety
- **Must be always-on**: Yes (critical security requirements)
- **Recommendation**: Keep alwaysApply: true

### TDD & Testing (1 rule - core only)

**12. `tdd-first.mdc`** — alwaysApply: true ✅

- **Why**: Core TDD methodology (Three Laws, Red→Green→Refactor)
- **Language extensions**: tdd-first-js, tdd-first-sh are conditional
- **Must be always-on**: Yes (foundation for language-specific rules)
- **Recommendation**: Keep alwaysApply: true

### Workflow & Protocols (8 rules)

**13. `capabilities.mdc`** — alwaysApply: true ✅

- **Why**: What assistant can do (rules/MCP/scripts catalog)
- **Must be always-on**: Yes (discoverability)
- **Recommendation**: Keep alwaysApply: true

**14. `cursor-platform-capabilities.mdc`** — alwaysApply: true ✅

- **Why**: Cursor-specific features and limits (cite docs)
- **Must be always-on**: Yes (prevents incorrect statements)
- **Recommendation**: Keep alwaysApply: true

**15. `direct-answers.mdc`** — alwaysApply: true ✅

- **Why**: Root-cause-first format for "why" questions
- **Must be always-on**: Yes (communication protocol)
- **Recommendation**: Keep alwaysApply: true

**16. `favor-tooling.mdc`** — alwaysApply: true ✅

- **Why**: Prefer automated tools over manual scanning
- **Must be always-on**: Yes (default working mode)
- **Recommendation**: Keep alwaysApply: true

**17. `intent-routing.mdc`** — alwaysApply: true ✅

- **Why**: Routes user intent to appropriate rules (ERD, tasks, git, etc.)
- **Must be always-on**: Yes (routing layer for conditional rules)
- **Recommendation**: Keep alwaysApply: true

**18. `scope-check.mdc`** — alwaysApply: true ✅

- **Why**: Vague goal → clarify/split protocol
- **Must be always-on**: Yes (prevents scope creep)
- **Recommendation**: Keep alwaysApply: true

**19. `script-execution.mdc`** — alwaysApply: true ✅

- **Why**: Direct execution of scripts (no shell wrappers when not needed)
- **Must be always-on**: Yes (affects all script invocations)
- **Recommendation**: Keep alwaysApply: true

**20. `self-improve.mdc`** — alwaysApply: true ✅

- **Why**: Pattern observation and rule improvement proposals
- **Must be always-on**: Yes (continuous improvement)
- **Recommendation**: Keep alwaysApply: true

---

## Conditional Rules (25 total) — Analysis

### High-Priority Candidates for AlwaysApply

**Based on investigation findings (17% TDD non-compliance, test quality issues)**:

### TDD & Testing Rules (6 rules) — RECOMMENDED FOR ALWAYS-ON

**1. `tdd-first-js.mdc`** — alwaysApply: false → **CHANGE TO TRUE** ⚠️

- **Why change**: 83% TDD compliance (17% non-compliance measured)
- **Evidence**: Investigation baseline shows violations
- **Pattern**: Same as assistant-git-usage (was 74%, now 96%)
- **Context cost**: ~2k tokens
- **Expected improvement**: 83% → 90%+
- **Recommendation**: **Change to alwaysApply: true**

**2. `tdd-first-sh.mdc`** — alwaysApply: false → **CHANGE TO TRUE** ⚠️

- **Why change**: Shell scripts changed without tests (suspected violations)
- **Pattern**: Same enforcement needs as tdd-first-js
- **Context cost**: ~2k tokens
- **Expected improvement**: Similar to JS (likely 80% → 90%+)
- **Recommendation**: **Change to alwaysApply: true**

**3. `testing.mdc`** — alwaysApply: false → **CONSIDER ALWAYS-ON** ⚠️

- **Why**: Test structure and quality standards
- **Evidence**: Weak assertions, missing owner coupling observed
- **When needed**: During test file creation/editing
- **Context cost**: ~2k tokens
- **Alternative**: Could remain conditional (intent routing works)
- **Recommendation**: **Consider alwaysApply: true** OR improve intent routing

**4. `test-quality.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Language-agnostic quality guidelines
- **Attached via**: test-quality-js.mdc, test-quality-sh.mdc (language-specific)
- **Recommendation**: Keep conditional, rely on language-specific rules

**5. `test-quality-js.mdc`** — alwaysApply: false → **CONSIDER ALWAYS-ON** ⚠️

- **Why**: JS/TS test quality (coverage, owner coupling, sabotage checks)
- **Trigger**: `**/*.{spec,test}.{ts,tsx,js,jsx}`
- **Evidence**: Test quality issues observed
- **Context cost**: ~1.5k tokens
- **Recommendation**: **Consider alwaysApply: true** if test quality remains an issue

**6. `test-quality-sh.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Shell test quality (behavior evidence, focused harness)
- **Trigger**: `.cursor/scripts/**/*.spec.sh`
- **Usage**: Less frequent than JS/TS tests
- **Recommendation**: Keep conditional (intent routing sufficient)

### Refactoring & Code Changes (2 rules)

**7. `refactoring.mdc`** — alwaysApply: false → **CONSIDER ALWAYS-ON** ⚠️

- **Why**: Safety checklist for refactors
- **Evidence**: Suspected violations (refactors without test coverage)
- **Risk level**: High (breaking changes)
- **Context cost**: ~1.5k tokens
- **Alternative**: Improve intent routing ("refactor" verb triggers)
- **Recommendation**: **Consider alwaysApply: true** OR strengthen routing

**8. `imports.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Import organization (grouping, alphabetization)
- **Enforced by**: Linter (external validation preferred)
- **Recommendation**: Keep conditional, rely on linter

### Project Lifecycle & Planning (7 rules)

**9. `project-lifecycle.mdc`** — alwaysApply: false → **IMPROVE ROUTING** ⚠️

- **Why**: Project completion policy
- **Evidence**: Confirmed violation (this project marked complete prematurely)
- **Current trigger**: `docs/projects/**` paths
- **Issue**: Not triggered on completion actions
- **Recommendation**: **Improve intent routing** (add "complete", "archive", "mark done" triggers)

**10. `create-erd.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: ERD creation workflow
- **Current trigger**: "create ERD for X" phrases
- **Evidence**: Intent routing works well
- **Recommendation**: Keep conditional

**11. `generate-tasks-from-erd.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Task generation two-phase flow
- **Current trigger**: "generate tasks" phrases
- **Evidence**: Intent routing works well
- **Recommendation**: Keep conditional

**12. `spec-driven.mdc`** — alwaysApply: false → **IMPROVE ROUTING** ⚠️

- **Why**: Specification workflow (plan before implement)
- **Evidence**: Suspected violations (skip planning phase)
- **Current trigger**: "plan", "specify" phrases
- **Issue**: Not triggered when should be
- **Recommendation**: **Improve intent routing** (add more trigger phrases)

**13. `guidance-first.mdc`** — alwaysApply: false → **IMPROVE ROUTING** ⚠️

- **Why**: Guidance vs implementation intent classification
- **Evidence**: Confirmed violation (over-implementation when guidance requested)
- **Current trigger**: "how can we", "what's best" phrases
- **Issue**: Misses some guidance requests
- **Recommendation**: **Improve intent routing** (add "should we", "would you recommend")

**14. `deterministic-outputs.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Spec/Plan/Tasks templates
- **Usage**: Project-specific, infrequent
- **Recommendation**: Keep conditional

**15. `test-plan-template.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Standard structure for test plans
- **Usage**: Investigation-specific, rare
- **Recommendation**: Keep conditional

### Rule Authoring & Maintenance (5 rules)

**16. `front-matter.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Front matter structure for rules
- **Trigger**: Editing `.cursor/rules/*.mdc`
- **Usage**: Infrequent (rule creation/updates)
- **Recommendation**: Keep conditional

**17. `rule-creation.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: How to create rules
- **Trigger**: "create rule", "update rule" phrases
- **Usage**: Infrequent
- **Recommendation**: Keep conditional

**18. `rule-maintenance.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Rule maintenance cadence, validation
- **Trigger**: Rule maintenance actions
- **Usage**: Periodic, not constant
- **Recommendation**: Keep conditional

**19. `rule-quality.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Rule validation checklist
- **Trigger**: Rule creation/updates
- **Usage**: Infrequent
- **Recommendation**: Keep conditional

### Shell & Architecture (1 rule)

**20. `shell-unix-philosophy.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Unix Philosophy for shell scripts
- **Trigger**: `.cursor/scripts/**/*.sh` files
- **Evidence**: Scripts follow philosophy well
- **Recommendation**: Keep conditional

### Low-Priority Conditional Rules (5 rules)

**21. `changelog.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Changesets workflow
- **Usage**: PR-specific
- **Recommendation**: Keep conditional

**22. `context-efficiency.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Context health scoring rubric
- **Trigger**: "show gauge" phrases
- **Usage**: On-demand
- **Recommendation**: Keep conditional

**23. `dry-run.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Plan-only mode when message starts with "DRY RUN:"
- **Trigger**: Exact phrase match (highest priority)
- **Usage**: Explicit opt-in
- **Recommendation**: Keep conditional

**24. `five-whys.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Root-cause analysis method
- **Usage**: Investigation-specific
- **Recommendation**: Keep conditional

**25. `workspace-security.mdc`** — alwaysApply: false → KEEP CONDITIONAL ✅

- **Why**: Cursor workspace trust, autorun prevention
- **Trigger**: Workspace security concerns
- **Usage**: Infrequent
- **Recommendation**: Keep conditional

---

## Recommendations Summary

### Immediate Changes (High Confidence)

**1. Add AlwaysApply to TDD Rules** ⚠️

- `tdd-first-js.mdc`: false → **true**
- `tdd-first-sh.mdc`: false → **true**
- **Rationale**: 17% TDD non-compliance measured; same pattern as git-usage success
- **Expected impact**: 83% → 90%+ compliance
- **Context cost**: +4k tokens (~6% increase)

**2. Remove AlwaysApply from Failed Experiment** ⚠️

- `git-slash-commands.mdc`: true → **false**
- **Rationale**: Experiment failed (runtime routing wrong), rule not used
- **Impact**: -2k tokens saved

### Consider for AlwaysApply (Medium Confidence)

**3. Testing Quality Rules** ⚠️

- `testing.mdc`: Consider true (if test quality issues persist)
- `test-quality-js.mdc`: Consider true (if JS test quality issues persist)
- **Alternative**: Improve intent routing first, monitor compliance

**4. Refactoring Safety** ⚠️

- `refactoring.mdc`: Consider true (if refactor violations observed)
- **Alternative**: Strengthen intent routing ("refactor" verb)

### Improve Intent Routing (High Confidence)

**5. Medium-Risk Rules with Confirmed Violations**

- `project-lifecycle.mdc`: Add triggers ("complete", "archive", "mark done")
- `spec-driven.mdc`: Add triggers (more planning phrases)
- `guidance-first.mdc`: Add triggers ("should we", "would you recommend")

### Keep Conditional (High Confidence)

**6. All Other Rules** ✅

- Low-frequency usage
- Intent routing works well
- No evidence of violations

---

## Context Cost Analysis

### Current State (20 alwaysApply rules)

- Estimated: ~40k tokens (~4% of 1M context)

### Scenario A: Add TDD Rules Only (Recommended)

- Add: tdd-first-js, tdd-first-sh
- Remove: git-slash-commands
- Net change: +2k tokens
- Total: ~42k tokens (~4.2% of context)
- **Impact**: Minimal, manageable

### Scenario B: Add TDD + Testing Quality

- Add: tdd-first-js, tdd-first-sh, testing, test-quality-js
- Remove: git-slash-commands
- Net change: +5.5k tokens
- Total: ~45.5k tokens (~4.6% of context)
- **Impact**: Still reasonable if quality issues persist

### Scenario C: Add TDD + Testing + Refactoring

- Add: tdd-first-js, tdd-first-sh, testing, test-quality-js, refactoring
- Remove: git-slash-commands
- Net change: +7k tokens
- Total: ~47k tokens (~4.7% of context)
- **Impact**: Getting expensive; consider alternatives first

---

## Decision Framework

For each conditional rule, assess:

**1. Violation Evidence**

- ✅ Confirmed: Observed in git history or investigation
- ⚠️ Suspected: Similar to confirmed violations
- ✅ None: No known violations

**2. Routing Reliability**

- ❌ Unreliable: Conditional attachment + implicit triggers
- ⚠️ Moderate: Phrase-based intent routing
- ✅ Reliable: External validation or explicit user action

**3. Risk Level**

- 🔴 Critical: Breaks workflows or safety
- 🟡 High: Frequent violations or significant impact
- 🟢 Medium: Context-dependent, moderate impact
- ⚪ Low: Infrequent triggers, guidance-only

**4. Context Cost Acceptance**

- ✅ Worth it: High risk + confirmed violations + unreliable routing
- ⚠️ Consider: Medium risk + suspected violations OR high risk + moderate routing
- ❌ Skip: Low risk OR reliable routing OR no violations

**Recommendation**:

- **AlwaysApply** if: High/Critical risk + (Confirmed violations OR Unreliable routing) + Cost acceptable
- **Improve routing** if: Medium risk + Moderate routing + Confirmed violations
- **Keep conditional** if: Low risk OR Reliable routing OR No violations

---

## Next Steps

1. ✅ Review completed
2. ⏸️ **User decision needed**: Accept Scenario A (TDD rules only) OR Scenario B/C?
3. ⏸️ Apply approved changes to rule files
4. ⏸️ Validate improvements (accumulate 20-30 commits)
5. ⏸️ Document final enforcement patterns

---

**Status**: Review complete, awaiting user approval for changes  
**Recommended**: Scenario A (add TDD rules, remove git-slash-commands)  
**Alternative**: Scenario B (add testing quality rules if issues persist)
