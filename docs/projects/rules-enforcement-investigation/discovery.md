# Rules Enforcement & Effectiveness Discovery

**Date**: 2025-10-15  
**Purpose**: Analyze existing rules for enforcement patterns that drive deterministic behavior and tooling usage

---

## Executive Summary

After analyzing 15+ core rules, clear patterns emerge:

### Strong Enforcement Signals Found

1. **Pre-action gates** with explicit checklists (e.g., `assistant-behavior.mdc` → Compliance-first send gate)
2. **Script-first defaults** with verification steps (e.g., `assistant-git-usage.mdc` → "Query capabilities.mdc before ANY git operation")
3. **Hard gates with "must"** language and no skip path (e.g., `tdd-first.mdc` → Hard gate, repo-wide, no skip)
4. **Tool constraints** that eliminate alternatives (e.g., `github-api-usage.mdc` → "GH CLI is not installed")

### Weak Enforcement Patterns Found

1. **Advisory prose** without verification steps
2. **Buried requirements** in middle of long sections
3. **Soft gates** ("should", "prefer") without explicit checks
4. **No verification protocol** before sending

### Key Finding

Rules with **explicit pre-action protocols + verification checklists** are more likely to be enforced than rules stated as general principles.

---

## Part 1: Enforcement Patterns Catalog

### Pattern A: Pre-Send Gate (Strongest Enforcement)

**Example**: `assistant-behavior.mdc` → Compliance-first send gate

**Structure**:

```
## Compliance-first send gate (must)

Before sending any message that includes actions or tool results, explicitly verify:

- Links: all URLs converted to Markdown links...
- Status update: present whenever tools/edits ran...
- TODOs: reconciled before starting...
- Consent: first command per tool category obtained...
- TDD gate: for implementation edits, owner spec added/updated...
- Scripts: before git/terminal commands, checked capabilities.mdc for repo scripts...
- Messaging: bullets and short sections...
- If any item fails, revise the message; do not send.
```

**Enforcement Signals**:

- ✅ Explicit checklist format
- ✅ "Must" language at section header
- ✅ **Verification protocol**: "Before sending... explicitly verify"
- ✅ **Failure handling**: "If any item fails, revise the message; do not send"
- ✅ Placed prominently (lines 165-207 of 285 total)

**Effectiveness Hypothesis**: HIGH — combines checklist format with explicit gate + failure handling

**Observed Violations**:

- ERD mentions violations of script-first default despite this gate including "Scripts: before git/terminal commands, checked capabilities.mdc"
- Suggests gate may not be consistently applied or verification step is skipped

---

### Pattern B: Script-First with Explicit Query (Strong Enforcement)

**Example**: `assistant-git-usage.mdc` → Script-First Default

**Structure**:

```
## Script-First Default (must)

Before ANY git operation (commit, branch, PR), explicitly check `capabilities.mdc` for available repo scripts:

1. **Query**: "Is there a script in capabilities.mdc for this git operation?"
2. **Use script if exists**:
   - Commits: use `git-commit.sh`...
   - Branch names: use `git-branch-name.sh`...
   - PR creation: use `pr-create.sh`...
3. **Raw git only if no script exists** for that operation

**Rationale**: Repo scripts enforce conventions... This must be verified at pre-send gate per `assistant-behavior.mdc`.
```

**Enforcement Signals**:

- ✅ Top-of-file placement (lines 15-28 of 171 total)
- ✅ "Must" in header
- ✅ **Numbered protocol steps** (Query → Use → Fallback)
- ✅ **Explicit cross-reference** to pre-send gate enforcement
- ✅ **Rationale provided**
- ✅ Specific tool paths (no ambiguity)

**Effectiveness Hypothesis**: HIGH — step-by-step protocol + cross-reference to gate

**Observed Violations**:

- ERD mentions "used `git commit --amend` instead of `git-commit.sh`"
- ERD mentions "used `git push -f` instead of checking for `pr-update.sh`"
- **Pattern**: Despite strong signals, violations occurred

---

### Pattern C: Hard Gate with No Skip Path (Strong Enforcement)

**Example**: `tdd-first.mdc` → Hard gate

**Structure**:

```
## Pre-edit Gate

- Before editing list owner spec path(s) colocated with the source file
- Red: add or update a failing owner spec
- Green: implement minimal change to pass
- Refactor: clean up while keeping tests green

...

## Hard gate (repo‑wide, no skip)

- Scope: applies to all maintained sources: `**/*.{ts,tsx,js,jsx,mjs,cjs,sh}` excluding node_modules...
- Owner spec rule (deterministic): for any edited file `f.ext`, the owner spec is the colocated `f.spec.ext`...
- New files: creating `a.ts` requires creating `a.spec.ts`...
- No skip path: if direct integration is brittle, extract a pure resolver (effects seam)...
```

**Enforcement Signals**:

- ✅ Explicit "Hard gate" header
- ✅ "repo-wide, no skip" in header
- ✅ **Deterministic rule**: clear mapping (f.ext → f.spec.ext)
- ✅ **Scope declaration** with explicit globs
- ✅ Referenced in `assistant-behavior.mdc` send gate
- ✅ Top placement (lines 16-22) before any prose

**Effectiveness Hypothesis**: HIGH — combines hard gate declaration + deterministic rule + send gate integration

**Note**: TDD gate is in send gate checklist, so should be caught by compliance-first pattern

---

### Pattern D: Tool Constraint (Eliminates Alternatives)

**Example**: `github-api-usage.mdc` → Tooling Constraint

**Structure**:

```
## Tooling Constraint (must)

**GitHub CLI (`gh`) is not installed.** Always use the repository scripts...

- ✅ Use: `.cursor/scripts/pr-create.sh`, `curl` with GitHub API
- ❌ Never use: `gh pr create`, `gh pr list`, `gh api`, or any `gh` commands
```

**Enforcement Signals**:

- ✅ Top placement (lines 13-19 of 51 total)
- ✅ "Must" in header
- ✅ **Bold statement** of constraint
- ✅ **Visual indicators** (✅ ❌) for do/don't
- ✅ **Specific paths** to allowed tools
- ✅ **Explicit prohibition** of alternatives

**Effectiveness Hypothesis**: HIGH — eliminates choice, clear visual cues

---

### Pattern E: Preflight Checklist (Before Side Effects)

**Example**: `favor-tooling.mdc` → Preflight Checklist

**Structure**:

```
### Preflight Checklist (before side effects)

- Consult the relevant rule's Contract for prescribed tools (e.g., `logging-protocol.mdc` → `alp-logger.sh`).
- Prefer official scripts over ad‑hoc shell writes: announce the chosen tool before executing.
- For writes with fallbacks (e.g., logs): attempt default destination first; note the fallback reason...
- If a script is not executable, ask the user for permission...
```

**Enforcement Signals**:

- ✅ Subsection header "before side effects"
- ✅ Checklist format (bullets)
- ✅ **Cross-references to other rules** for lookup
- ⚠️ Nested under "Default Behavior" (line 30)
- ⚠️ No explicit "must" language

**Effectiveness Hypothesis**: MEDIUM — good structure but buried placement, softer language

---

### Pattern F: Advisory Prose (Weakest Enforcement)

**Example**: `global-defaults.mdc` (link-only pattern)

**Structure**:

```
## Consent-first behavior (must)

- Ask once before running local commands, web research, or script executions.
- Respect session allowlists for safe, read-only commands; announce each execution.
- Default to pause on missing consent.
```

**Enforcement Signals**:

- ✅ "Must" in header
- ✅ Clear bullets
- ⚠️ **No verification protocol** ("how to check?")
- ⚠️ **No failure handling** ("what if violated?")
- ⚠️ Very short (38 lines total) — relies on links to `assistant-behavior.mdc`

**Effectiveness Hypothesis**: LOW-MEDIUM — good as a summary/reference, but relies on linked rules for enforcement details

---

## Part 2: High-Value Rules Deep Dive

### Rule: `00-assistant-laws.mdc`

**Status**: `alwaysApply: true`  
**Purpose**: Highest-priority behavioral contract

**Key Sections**:

1. **First Law**: Truth and Accuracy (must not provide incorrect info)
2. **Second Law**: Consistency and Transparency
3. **Third Law**: Self-Correction and Accountability

**Enforcement Approach**:

- Uses "Laws" metaphor (Asimov-style) to signal priority
- Lists behavioral requirements under each law
- Includes "Through inaction" clause

**Tooling Coupling**: NONE (principle-based, no specific tools referenced)

**Determinism Signals**:

- ⚠️ High-level principles, not specific pre-action steps
- ✅ Clear "must not" prohibitions
- ⚠️ No verification checklist

**Placement**: Placed at top of always-applied rules (filename `00-` ensures sort order)

**Effectiveness Hypothesis**: MEDIUM — provides overarching principles but lacks operational checklists

---

### Rule: `assistant-behavior.mdc`

**Status**: `alwaysApply: true`  
**Purpose**: Core behavioral guidance for AI assistant interactions

**Key Sections**:

1. Consent-first behavior (lines 11-16)
2. Command/tool consent gate (mandatory) (lines 22-60)
3. **Compliance-first send gate** (lines 165-207) ← CRITICAL
4. TDD pre-edit gate (lines 234-250)
5. Habit Bias Controls (lines 273-280)

**Enforcement Approach**:

- **Two major gates**: consent gate (pre-command) + send gate (pre-message)
- Checklist format in send gate
- Explicit "If any item fails, revise the message; do not send"

**Tooling Coupling**: STRONG

- References `capabilities.mdc` (line 205: "checked capabilities.mdc for repo scripts")
- References `tdd-first.mdc` for owner spec rules
- References `scope-check.mdc` for acceptance bundle

**Determinism Signals**:

- ✅ Pre-action protocol: "Before the first local shell command in a turn, ask one-shot consent..."
- ✅ Pre-send protocol: "Before sending any message that includes actions... explicitly verify"
- ✅ Failure handling: "do not send"
- ✅ Tool categories defined (lines 31-38)

**Observed Violations** (per ERD):

- Script-first: used raw git commands instead of checking capabilities
- Consent-first: multiple amend/push cycles without asking

**Gap Analysis**:

- Send gate EXISTS and is comprehensive
- But violations still occurred
- **Hypothesis**: Gate may not be actively checked/enforced before every send, OR the check is happening but being bypassed

---

### Rule: `capabilities.mdc`

**Status**: `alwaysApply: true`  
**Purpose**: Discoverable capabilities for the repo's AI assistant

**Key Sections**:

- Git assistance (lines 59-67)
- Testing & TDD (lines 99-104)
- Shell Scripts & Unix Philosophy (lines 106-116)
- Discovery (rules, MCP, local scripts) (lines 89-97)

**Enforcement Approach**:

- **Inventory pattern**: lists all available scripts with exact paths
- Cross-references to detailed rules
- Provides command examples

**Tooling Coupling**: MAXIMUM

- Contains explicit paths to every automation script
- Format: `[.cursor/scripts/git-commit.sh](.cursor/scripts/git-commit.sh) --type ... --description ...`

**Determinism Signals**:

- ✅ Exact paths (no ambiguity)
- ✅ Command examples with flags
- ⚠️ **No pre-action query protocol** (just a catalog)
- ⚠️ **No verification requirement** stated in this file

**Gap Analysis**:

- This is the catalog that `assistant-git-usage.mdc` says to query
- But `capabilities.mdc` itself doesn't say "you must query me before git ops"
- **Pattern**: The enforcement is in the consumer (`assistant-git-usage.mdc`), not the provider (`capabilities.mdc`)

---

### Rule: `favor-tooling.mdc`

**Status**: `alwaysApply: true`  
**Purpose**: Favor tooling over manual steps; detective mode only when needed

**Key Sections**:

1. Principles (lines 15-20)
2. Default Behavior (lines 22-28)
3. **Preflight Checklist (before side effects)** (lines 30-35)
4. When to Enter Detective Mode (triggered) (lines 37-50)
5. Tooling Catalog (lines 52-59)

**Enforcement Approach**:

- **Preflight checklist** before side effects
- "Consult the relevant rule's Contract for prescribed tools"
- "Prefer official scripts over ad-hoc shell writes"

**Tooling Coupling**: STRONG (meta-level)

- References other rules' "Contract" sections
- Lists categories of tools (linters, type checkers, tests)

**Determinism Signals**:

- ✅ Checklist format for preflight
- ✅ "Before side effects" trigger
- ⚠️ "Prefer" language (not "must")
- ⚠️ No explicit verification protocol

**Effectiveness Hypothesis**: MEDIUM-HIGH — good principle but relies on "consult" action which may not always happen

---

### Rule: `tdd-first.mdc`

**Status**: `alwaysApply: true`, `globs: **/*`  
**Purpose**: TDD-First — Three Laws, R/G/R, owner specs, effects seam

**Key Sections**:

1. **Pre-edit Gate** (lines 16-22) ← TOP PLACEMENT
2. **Hard gate (repo-wide, no skip)** (lines 116-122)
3. Three Laws (nano-cycle) (lines 45-55)
4. Execution protocol (assistant) (lines 124-128)

**Enforcement Approach**:

- **Hard gate declaration**: "repo-wide, no skip"
- **Deterministic rule**: `f.ext` → `f.spec.ext`
- **Referenced in send gate**: `assistant-behavior.mdc` includes TDD gate check

**Tooling Coupling**: MODERATE

- References `tdd-first-js.mdc` and `tdd-first-sh.mdc` for language specifics
- Execution protocol: "Run focused tests for the current spec"

**Determinism Signals**:

- ✅ **Hard gate** (explicit, no skip)
- ✅ **Deterministic mapping** (one source → one spec)
- ✅ **Scope declaration** with globs
- ✅ **Execution protocol** (step-by-step)
- ✅ Top placement

**Gap Analysis**:

- This rule has the strongest structural signals
- Referenced in `assistant-behavior.mdc` send gate
- **Question**: Are violations happening because the gate check is bypassed, or because the gate is checked but results ignored?

---

### Rule: `assistant-git-usage.mdc`

**Status**: `alwaysApply: false` ← NOTE: Not always-applied!  
**Purpose**: Git usage — commits, branch naming, changesets, commit gates

**Key Sections**:

1. **Script-First Default (must)** (lines 15-28) ← TOP PLACEMENT
2. Commit Messages (lines 30-55)
3. Pull Requests (lines 71-108)
4. **Changesets (must)** (lines 110-132)

**Enforcement Approach**:

- **Explicit query protocol**: "Is there a script in capabilities.mdc for this operation?"
- **Numbered steps**: Query → Use → Fallback
- **Cross-reference**: "This must be verified at pre-send gate per `assistant-behavior.mdc`"

**Tooling Coupling**: MAXIMUM

- Exact script paths for every git operation
- Explicit "use X, not Y" guidance

**Determinism Signals**:

- ✅ **Query protocol** (step 1: check capabilities.mdc)
- ✅ **Tool mapping** (commit → git-commit.sh, PR → pr-create.sh)
- ✅ **Rationale provided**
- ✅ Top placement
- ✅ Cross-reference to send gate

**Critical Finding**: `alwaysApply: false`

- This rule is NOT automatically attached!
- Must be triggered by intent routing (`intent-routing.mdc`)
- Triggers: <git-term> (commit, branch, PR, etc.)

**Gap Hypothesis**:

- If the user says "commit these changes" but doesn't use the word "commit" in a way that triggers routing...
- OR if the assistant initiates a git action without user prompting...
- Then `assistant-git-usage.mdc` may not be in context!

---

### Rule: `intent-routing.mdc`

**Status**: `alwaysApply: true`  
**Purpose**: Lightweight router attaching rules via phrases, keywords, signals

**Key Sections**:

1. Triggers → Rules mapping (lines 28-106)
2. File/context signals (lines 114-121)
3. Decision policy (lines 123-132)

**Enforcement Approach**:

- **Trigger-based attachment**: phrases/keywords → attach specific rules
- File signals (e.g., `*.spec.*` → attach testing rules)
- Precedence: exact phrase > composite consent > keyword > file signals

**Tooling Coupling**: META (routes to other rules)

**Git Trigger** (lines 66-69):

```
- Git usage
  - Triggers: <git-term>
    - Terms: commit|commit message|commits|branch|branch name|...
  - Attach: `assistant-git-usage.mdc`
```

**Determinism Signals**:

- ✅ Explicit trigger patterns
- ✅ Precedence rules
- ⚠️ Relies on keyword matching

**Critical Finding**:

- `assistant-git-usage.mdc` only attached when git terms detected
- **What if**: assistant decides to commit without user using git terms?
- **Example**: User says "save this work" → might not trigger git routing

---

## Part 3: Structural Patterns Analysis

### Pattern Comparison Table

| Pattern               | Example Rule              | Placement | Language             | Verification       | Tooling     | Hypothesis |
| --------------------- | ------------------------- | --------- | -------------------- | ------------------ | ----------- | ---------- |
| Pre-Send Gate         | `assistant-behavior.mdc`  | Prominent | "must"               | Explicit checklist | Strong ref  | HIGH       |
| Script-First Protocol | `assistant-git-usage.mdc` | Top       | "must"               | Query steps        | Exact paths | HIGH       |
| Hard Gate             | `tdd-first.mdc`           | Top       | "hard gate, no skip" | Deterministic rule | Moderate    | HIGH       |
| Tool Constraint       | `github-api-usage.mdc`    | Top       | "never use X"        | Visual do/don't    | Elimination | HIGH       |
| Preflight Checklist   | `favor-tooling.mdc`       | Nested    | "prefer"             | Consult action     | Meta-ref    | MEDIUM     |
| Advisory Prose        | Various                   | Varies    | "should"             | None               | Weak/None   | LOW        |

### Forcing Function Indicators

**Strong Forcing Functions** (observed):

1. ✅ Explicit gate with failure protocol ("if any item fails, do not send")
2. ✅ Numbered steps with query protocol ("Step 1: Check X")
3. ✅ Deterministic mapping with no alternatives ("f.ext → f.spec.ext, no skip")
4. ✅ Tool constraint that eliminates alternatives ("gh is not installed")
5. ✅ Cross-reference to enforcement point ("must be verified at pre-send gate")

**Weak Forcing Functions** (observed):

1. ⚠️ Soft language ("prefer", "should", "consider")
2. ⚠️ No verification protocol ("consult" without verification)
3. ⚠️ Advisory placement (middle of file, nested under principles)
4. ⚠️ Conditional attachment (`alwaysApply: false` + keyword triggers)

---

## Part 4: Effectiveness Hypotheses

### Hypothesis 1: Conditional Attachment is a Weak Point

**Observation**:

- `assistant-git-usage.mdc` has `alwaysApply: false`
- Only attached when `intent-routing.mdc` detects git terms
- ERD reports violations: "used `git commit --amend` instead of `git-commit.sh`"

**Theory**:

- If assistant initiates a git action without explicit git terms in user message
- Or if context is full and rule is not prioritized
- Then script-first protocol may not be in context

**Test**: Change `assistant-git-usage.mdc` to `alwaysApply: true`

**Expected Result**: Violations decrease (script-first would always be in context)

---

### Hypothesis 2: Send Gate Exists But May Not Block

**Observation**:

- `assistant-behavior.mdc` has comprehensive send gate
- Gate includes: "Scripts: before git/terminal commands, checked capabilities.mdc"
- Violations still occurred

**Theory**:

- Gate may be checked but not enforced (advisory vs blocking)
- OR gate check happens but results don't stop the message
- OR gate is self-assessed but assessment can be incorrect

**Test**: Add explicit "STOP: Gate failed" marker before continuing

**Expected Result**: If gate is truly checked, we'd see stop markers when violations occur

---

### Hypothesis 3: Query Protocol Needs Visible Execution

**Observation**:

- `assistant-git-usage.mdc` says: "Query: 'Is there a script in capabilities.mdc for this operation?'"
- No evidence in ERD that this query actually happens

**Theory**:

- Query step is stated but not executed
- No output requirement (silent check)
- Could be optimized away or skipped

**Test**: Require visible output of query result before proceeding

**Expected Result**: Seeing "Checked capabilities.mdc: found git-commit.sh" would prove query happened

---

### Hypothesis 4: Intent Routing Has Gaps

**Observation**:

- `intent-routing.mdc` maps keywords → rules
- Git terms: "commit|commits|branch|branch name|..."
- Gaps: "amend", "push", "force push" not in trigger list

**Theory**:

- User or assistant might use git operations without trigger keywords
- Example: "fix the last commit" → might not trigger "commit" routing
- Example: "push this" → "push" not in git trigger list

**Test**: Add all git commands to trigger list, OR make git-usage always-apply

**Expected Result**: More consistent attachment of git-usage rule

---

### Hypothesis 5: Habit Bias Overrides Rules

**Observation**:

- `assistant-behavior.mdc` includes "Habit Bias Controls" (lines 273-280)
- Mentions: "Local-first hard gate", "Category switch protocol"
- ERD context: "Assistant violated rules despite alwaysApply: true"

**Theory**:

- Model may have prior training or patterns that override rules
- "Habit" (prior behavior) stronger than stated rules
- Rules act as soft guidance, not hard constraints

**Test**: Requires external validation (can't test with rules alone)

**Expected Result**: If true, would explain why even strong rules are violated

---

## Part 5: Comparison to External Patterns

### Taskmaster Pattern (from ai-workflow-integration project)

**ERD Reference**: `docs/projects/ai-workflow-integration/erd.md`

**Key Characteristics**:

- Uses slash commands for task operations
- Structured prompts force specific workflows
- Explicit state transitions vs implicit routing

**Hypothesis from ERD**:

> "Explicit commands create forcing functions that intent routing lacks."

**Comparison to Our Patterns**:

- Our `intent-routing.mdc` uses keywords (implicit)
- Taskmaster uses `/task` commands (explicit)
- **Difference**: Explicit commands are unambiguous (no keyword matching needed)

**Forcing Function**:

- Slash commands: User types `/commit` → unambiguous tool invocation
- Intent routing: User types "save this work" → keyword matching needed, may miss

---

### Spec-kit Pattern (from ai-workflow-integration project)

**Key Characteristics**:

- Uses `/spec`, `/plan`, `/analyze` commands
- Commands have required arguments
- Explicit safety gates

**Comparison**:

- Similar to our `dry-run.mdc` (explicit prefix `DRY RUN:`)
- But `/spec` is terser and more discoverable

**Forcing Function**:

- Required arguments: Can't proceed without all params
- Our rules: Many optional, relying on consent prompts

---

### Hypothesis: Slash Commands > Intent Routing for High-Risk Ops

**Evidence**:

1. Slash commands eliminate ambiguity (explicit invocation)
2. Required arguments enforce completeness
3. Command not recognized → clear error (vs silently proceeding)

**Application to Git Operations**:

- Current: User says "commit this" → `intent-routing` detects "commit" → attaches `assistant-git-usage` → assistant should use `git-commit.sh`
- Proposed: User says `/commit` → immediately routes to `git-commit.sh` wrapper
- **Advantage**: No keyword matching, no attachment delay, no conditional behavior

---

## Part 6: Structural Improvements (Proposed)

### Improvement 1: Make High-Risk Rules Always-Apply

**Target Rules**:

- `assistant-git-usage.mdc` (currently `alwaysApply: false`)
- Any rule that prevents data loss or inconsistency

**Rationale**:

- Git operations are high-risk (data loss if wrong)
- Script-first default is critical for conventions
- Currently relies on intent routing (keyword triggers)
- **Gap**: If routing misses, rule not in context

**Change**:

```diff
---
description: Assistant Git usage — commits, branch naming, changesets
- alwaysApply: false
+ alwaysApply: true
```

**Expected Impact**: Script-first protocol always in context, violations decrease

---

### Improvement 2: Add Visible Query Execution to Send Gate

**Target**: `assistant-behavior.mdc` → Compliance-first send gate

**Current** (line 205):

```
- Scripts: before git/terminal commands, checked capabilities.mdc for repo scripts; used script if available.
```

**Proposed**:

```
- Scripts (MUST SHOW): before git/terminal commands, OUTPUT result of checking capabilities.mdc:
  - Format: "Checked capabilities.mdc for [operation]: [script-path or 'none found']"
  - If script found: use it. If not found: proceed with raw command + consent.
  - Example: "Checked capabilities.mdc for commit: found .cursor/scripts/git-commit.sh"
```

**Rationale**:

- Current gate is self-assessed with no visible output
- Visible output creates accountability
- User can verify gate was actually checked

**Expected Impact**: Makes silent skips visible

---

### Improvement 3: Slash Command Gating for Git Operations

**Proposal**: Add mandatory slash commands for high-risk git ops

**Implementation**:

```markdown
## Git Operation Commands (mandatory for high-risk ops)

### Mandatory Commands

- `/commit` → routes to `git-commit.sh` with prompt for type/scope/description
- `/pr` → routes to `pr-create.sh` with prompt for title/body
- `/branch` → routes to `git-branch-name.sh` with prompt for task/type

### Enforcement

- Before any commit/PR/branch operation, assistant must:
  1. Check if user provided slash command
  2. If not: prompt "Use `/commit` to create a conventional commit. Proceed?"
  3. Only on explicit "yes" fall back to manual git command

### Rationale

- Slash commands eliminate keyword ambiguity
- Create forcing function (can't miss the route)
- User-visible invocation (clear what's happening)
```

**Expected Impact**:

- Reduces routing misses
- Makes tool usage explicit
- User knows when automation is used

---

### Improvement 4: Pre-Send Gate Self-Check Template

**Target**: `assistant-behavior.mdc` → Compliance-first send gate

**Current**: Gate is a checklist in the rule text

**Proposed**: Require visible self-check output before sending

**Implementation**:

```markdown
### Pre-Send Gate Self-Check (must output before sending)

When a message includes actions or tool results, OUTPUT this checklist:
```

Pre-Send Gate Check:

- [ ] Links: converted to Markdown?
- [ ] Status: included?
- [ ] TODOs: reconciled?
- [ ] Consent: obtained for first command in each category?
- [ ] TDD: owner spec updated? (if impl edits)
- [ ] Scripts: checked capabilities.mdc? Result: [...]
- [ ] Messaging: bullets and citations?

Gate Status: [PASS/FAIL]

```

If any item is unchecked: STOP, revise message, re-check.
```

**Rationale**:

- Makes gate execution visible
- Creates forcing function (can't skip without being obvious)
- User can verify compliance

**Expected Impact**: Catches violations before send OR makes violations visible

---

### Improvement 5: Measurement Hooks (Post-Hoc Validation)

**Proposal**: Create script to validate rule compliance after the fact

**Implementation**:

```bash
#!/usr/bin/env bash
# .cursor/scripts/rules-compliance-check.sh
# Post-hoc validation of rule compliance

# Check git operations
echo "Checking git operations..."
git log --oneline -n 10 | while read commit; do
  msg=$(git log --format=%B -n 1 "$commit")
  if ! [[ $msg =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert) ]]; then
    echo "❌ Non-conventional commit: $commit"
  fi
done

# Check for direct git commands in chat logs (if available)
# ...

# Report
echo "Compliance Score: [passed/total]"
```

**Usage**: Run after session to measure compliance rate

**Expected Impact**: Objective measurement of rule effectiveness

---

## Part 7: Measurement Framework Proposal

### Objective Measures (Automatable)

1. **Script Usage Rate**

   - Metric: `(git ops using repo scripts) / (total git ops)`
   - Data source: Git history (commit messages, branch names) + script logs
   - Target: >90%

2. **Consent Request Rate**

   - Metric: `(commands with prior consent prompt) / (total commands)`
   - Data source: Chat logs (search for consent prompts before `run_terminal_cmd`)
   - Target: 100% for first command in each tool category

3. **TDD Compliance Rate**

   - Metric: `(impl commits with corresponding spec changes) / (total impl commits)`
   - Data source: Git diffs (check for f.spec._ changes alongside f._ changes)
   - Target: >95%

4. **Send Gate Visibility**
   - Metric: `(messages with visible gate check) / (messages with actions)`
   - Data source: Chat logs (search for gate check output)
   - Target: 100% (if we implement visible gate output)

### Qualitative Signals (Manual Review)

1. **Explicit Capability Queries**

   - Look for: "Checked capabilities.mdc for [operation]: found [script]"
   - Target: Should appear before every git/script operation

2. **Routing Transparency**

   - Look for: Status updates mentioning which signal triggered routing
   - Target: "Triggered by: git term 'commit' → attached assistant-git-usage.mdc"

3. **Error Corrections**
   - Look for: Self-corrections when violations caught
   - Target: "Correction: should have used git-commit.sh instead of git commit"

---

## Part 8: Next Steps & Experiments

### Experiment 1: Query Visibility (Immediate)

**Hypothesis**: Adding visible output of capability queries will improve compliance

**Implementation**:

1. Add to `assistant-behavior.mdc` send gate:
   ```
   - Scripts: Output capability query result before executing
   ```
2. Update `assistant-git-usage.mdc` Script-First section:
   ```
   1. Query: "Is there a script in capabilities.mdc for this git operation?"
   2. OUTPUT result: "Checked capabilities.mdc for [op]: [found X | not found]"
   3. Use script if exists, else raw git with consent
   ```

**Test**: Request a commit and observe output

**Success Criteria**: See "Checked capabilities.mdc for commit: found .cursor/scripts/git-commit.sh" before commit

---

### Experiment 2: Always-Apply Git Usage (Immediate)

**Hypothesis**: Making `assistant-git-usage.mdc` always-apply will reduce violations

**Implementation**:

1. Change `assistant-git-usage.mdc`:
   ```diff
   - alwaysApply: false
   + alwaysApply: true
   ```

**Test**: Request a commit without using the word "commit" (e.g., "save this work")

**Success Criteria**: Script-first protocol followed even without git keyword

---

### Experiment 3: Slash Command Gating (Medium Effort)

**Hypothesis**: Requiring slash commands for git ops creates stronger forcing function

**Implementation**:

1. Create new rule `git-slash-commands.mdc`:

   ```markdown
   ## Mandatory Slash Commands for Git Operations

   - Before committing: prompt user with "/commit or manual?"
   - Before PR: prompt user with "/pr or manual?"
   - On manual choice: use raw git with consent
   ```

2. Add to `intent-routing.mdc`:
   ```
   - `/commit` → route to git-commit.sh wrapper
   - `/pr` → route to pr-create.sh wrapper
   ```

**Test**: Try to commit without `/commit` and observe prompt

**Success Criteria**: Assistant suggests `/commit` before proceeding

---

### Experiment 4: Visible Pre-Send Gate (Medium Effort)

**Hypothesis**: Visible gate output will catch violations or make them obvious

**Implementation**:

1. Update `assistant-behavior.mdc`:

   ```markdown
   ### Compliance-first send gate (must)

   Before sending any message with actions, OUTPUT:
   ```

   Pre-Send Gate:

   - Links: [✓/✗]
   - Status: [✓/✗]
   - Scripts: Checked capabilities.mdc? [✓/✗] Result: [...]
     ...
     Gate: [PASS/FAIL]

   ```

   If FAIL: revise and re-check.
   ```

**Test**: Any message with actions should show gate output

**Success Criteria**: Gate output visible in every message with actions

---

## Part 9: Open Questions

### Question 1: Are rules constraints or reference material?

**Evidence**:

- Strong structural signals exist (hard gates, must language, send gate)
- Violations still occurred despite `alwaysApply: true` and send gate
- **Current hypothesis**: Rules are reference material that can be consulted but not enforced as hard constraints by the platform

**Test Needed**: Experiment 1 (visible query) will reveal if consultation happens

---

### Question 2: Can send gates be self-enforcing?

**Evidence**:

- Send gate exists with comprehensive checklist
- Includes "If any item fails, revise the message; do not send"
- Violations occurred anyway

**Possible Explanations**:

1. Gate is checked but check can be wrong (self-assessment bias)
2. Gate is not actually checked before every send
3. Gate is advisory ("should check") not blocking ("cannot send without")

**Test Needed**: Experiment 4 (visible gate) will reveal if gate is checked

---

### Question 3: What creates a forcing function?

**Strong Candidates** (from analysis):

1. Slash commands (explicit, unambiguous invocation)
2. Tool constraints (eliminate alternatives)
3. Visible output requirements (makes compliance observable)
4. Always-apply rules (no conditional attachment)

**Weak Candidates**:

1. Keyword-triggered routing (can miss)
2. Self-assessed gates (can be wrong)
3. "Prefer" language (advisory, not blocking)
4. Nested/buried requirements (easy to skip)

**Test Needed**: Experiments 2-4 will test these hypotheses

---

### Question 4: Should high-risk operations require slash commands?

**Rationale**:

- Git operations can cause data loss or inconsistency
- Slash commands eliminate routing ambiguity
- Other tools (taskmaster, spec-kit) use slash commands successfully

**Trade-offs**:

- Pro: Unambiguous, explicit, user-visible
- Con: Requires user to learn commands, changes interaction model

**Decision Framework**:

- HIGH-RISK: Require slash command (commit, PR, branch, push --force)
- MEDIUM-RISK: Suggest slash command, allow fallback (status, diff, log)
- LOW-RISK: No slash command needed (read-only ops)

---

### Question 5: How do we measure compliance objectively?

**Proposed Metrics** (from Part 7):

1. Script usage rate (automatable via git history)
2. Consent request rate (requires chat log parsing)
3. TDD compliance rate (automatable via git diffs)
4. Visible gate output rate (requires chat log parsing)

**Challenges**:

- Chat logs may not be structured/parseable
- Need baseline measurement before experiments
- Observer effect (assistant knows it's being measured)

**Next Step**: Create `.cursor/scripts/rules-compliance-check.sh` (Experiment 5)

---

## Part 10: Summary & Recommendations

### Key Findings

1. **Strong patterns exist** but are not consistently followed

   - Pre-send gates, script-first protocols, hard gates all have good structure
   - Violations still occurred despite `alwaysApply: true` and comprehensive gates

2. **Conditional attachment is a weakness**

   - `assistant-git-usage.mdc` relies on keyword triggers
   - Can be missed if wrong words used or rule not in context

3. **Verification protocols lack visibility**

   - Gates say "check X" but no visible output
   - Can't verify if check actually happened

4. **Forcing functions need to be explicit**
   - Slash commands > keyword routing (based on taskmaster/spec-kit comparison)
   - Tool constraints > preferences (elimination vs advisory)

### Top Recommendations

1. **Make git-usage always-apply** (Experiment 2)

   - Immediate, low-effort change
   - Ensures script-first protocol always in context

2. **Add visible query output** (Experiment 1)

   - Require "Checked capabilities.mdc for X: found Y" output
   - Makes consultation observable and accountable

3. **Implement slash command gating** (Experiment 3)

   - For high-risk ops: commit, PR, branch, push --force
   - Creates strong forcing function

4. **Add visible pre-send gate** (Experiment 4)

   - Output gate checklist before every message with actions
   - Makes violations obvious or catches them pre-send

5. **Build measurement tools** (Part 7)
   - Objective: script usage rate, TDD compliance rate
   - Qualitative: visible queries, routing transparency

### Success Metrics

After implementing improvements:

- Script usage rate: baseline → target >90%
- Visible capability queries: 0% → target 100%
- TDD compliance: baseline → target >95%
- User-reported consistency: "increased confidence in assistant consistency"

---

## Appendices

### Appendix A: Rules Read (Full List)

1. `00-assistant-laws.mdc` — Highest-priority behavioral contract
2. `assistant-behavior.mdc` — Core behavioral guidance (consent, gates)
3. `capabilities.mdc` — Script inventory and discovery
4. `favor-tooling.mdc` — Tooling-first working mode
5. `script-execution.mdc` — Direct exec vs wrapper policy
6. `global-defaults.mdc` — High-level defaults (link-only)
7. `tdd-first.mdc` — TDD methodology, hard gate
8. `scope-check.mdc` — Vague/oversized request handling
9. `intent-routing.mdc` — Trigger-based rule attachment
10. `user-intent.mdc` — Intent classification
11. `testing.mdc` — Testing conventions
12. `assistant-git-usage.mdc` — Git usage, script-first
13. `github-api-usage.mdc` — GitHub API constraint
14. `guidance-first.mdc` — Guidance vs implementation
15. `dry-run.mdc` — Plan-only mode

### Appendix B: Enforcement Pattern Quick Reference

| Want Deterministic Behavior?   | Use This Pattern                | Example                   |
| ------------------------------ | ------------------------------- | ------------------------- |
| Block action before it happens | Pre-Send Gate                   | `assistant-behavior.mdc`  |
| Ensure tool is used            | Query Protocol + Explicit Paths | `assistant-git-usage.mdc` |
| No skip path                   | Hard Gate + "must"              | `tdd-first.mdc`           |
| Eliminate alternatives         | Tool Constraint                 | `github-api-usage.mdc`    |
| User-visible invocation        | Slash Commands                  | (proposed)                |
| Verify compliance              | Visible Output + Measurement    | (proposed)                |

### Appendix C: Violation Patterns (from ERD)

From `docs/projects/rules-enforcement-investigation/erd.md`:

1. **Script-first violation**:

   - Expected: use `git-commit.sh`
   - Actual: used `git commit --amend`
   - Rule: `capabilities.mdc` (alwaysApply: true) + `assistant-git-usage.mdc`

2. **Script-first violation (PR)**:

   - Expected: check for `pr-update.sh`
   - Actual: used `git push -f`
   - Rule: `assistant-git-usage.mdc`

3. **Consent-first violation**:
   - Expected: ask before each operation category
   - Actual: multiple amend/push cycles without asking
   - Rule: `assistant-behavior.mdc` (consent gate)

**Pattern**: Rules present but not consulted before action

---

## Conclusion

This discovery document provides:

1. **Catalog** of enforcement patterns across 15+ rules
2. **Analysis** of what makes rules effective (forcing functions)
3. **Hypotheses** about why violations occur despite strong rules
4. **Experiments** to test hypotheses and improve enforcement
5. **Measurement framework** for objective validation

**Next Action**: Review hypotheses and select experiments to run (recommend Experiments 1 & 2 as high-value, low-effort starting points).

---

**Document Status**: Draft for review  
**Owner**: rules-enforcement-investigation project  
**Last Updated**: 2025-10-15
