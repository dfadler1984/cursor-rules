# TDD Compliance Investigation — Why 17% Non-Compliance?

**Date**: 2025-10-20  
**Status**: INVESTIGATION PLANNED  
**Purpose**: Understand why TDD rules are violated 17% of the time even when loaded via globs

---

## Problem Statement

**What we know**:

- ✅ TDD rules have globs that work (`**/*.ts,**/*.tsx,...` and `.cursor/scripts/*.sh`)
- ✅ Rules load correctly when editing matching files
- ⚠️ **But**: 17% non-compliance measured (83% compliance)
- ❓ **Question**: Why are rules ignored even when loaded?

**Key insight from user**: "I've never said that we have had a problem with globs. From what I've seen the globs work, but sometimes the agent still ignores the rules"

---

## Investigation Hypotheses

### Hypothesis 1: Rule Content Unclear

**Description**: The rule loads but doesn't clearly communicate the immediate requirement

**Evidence to examine**:

- `tdd-first-sh.mdc` is reference-heavy (points to 3 other rules)
- Doesn't spell out immediate action: "Before editing X.sh, ensure X.test.sh exists"
- Multiple hops to understand requirement: rule → test-quality-sh → testing → tdd-first

**Questions**:

- Is the rule language actionable enough in the moment of editing?
- Does the reference chain create friction?
- Should the rule include a direct "Before editing" checklist?

**Investigation tasks**: See tasks list below

---

### Hypothesis 2: Conflicting Rules

**Description**: Another rule (consent, scope-check) blocks TDD workflow

**Potential conflicts**:

```
TDD rule says: "Create test file before implementation"
Consent rule says: "Ask before creating files"
Scope-check says: "Clarify acceptance criteria before acting"
```

**Questions**:

- Do the rules create decision paralysis?
- Which rule takes precedence when they conflict?
- Is there an escape valve documented?

**Investigation tasks**: See tasks list below

---

### Hypothesis 3: Measurement Error — Legitimate Exceptions

**Description**: The 17% might include legitimate exceptions that shouldn't count as violations

**Possible legitimate reasons**:

1. **Library files** (`.lib-net.sh`) - shared utilities, tested via consumers
2. **Test files themselves** (`.test.sh`, `.spec.sh`) - don't need their own tests
3. **Configuration/generated files** - no behavior to test
4. **Trivial changes** - typo fixes, comments, formatting only
5. **Refactoring without behavior change** - tests already exist, code just moved

**Questions**:

- Did the compliance checker account for these exceptions?
- What percentage of the 17% are legitimate exceptions?
- Should we update the checker to filter these out?

**Investigation tasks**: See tasks list below

---

### Hypothesis 4: Habit/Oversight — The Core Mystery

**Description**: Even with rule loaded, why would the agent ignore it?

**Possible explanations**:

1. **Competing priorities**: Other rules (consent, scope-check) feel more urgent
2. **Cognitive load**: Too many rules loaded at once, some get missed
3. **Workflow interruption**: TDD requires stopping to create test first, feels disruptive
4. **Unclear consequences**: Rule doesn't say what happens if violated
5. **Pattern not established**: Haven't internalized the habit yet
6. **Context window size**: Rule present but "far" from the active editing context

**Questions**:

- What other rules are typically loaded alongside TDD rules?
- Is there a pattern to when violations occur (start of session? middle? end?)?
- Do violations correlate with conversation length or complexity?
- Does the visible pre-send gate catch TDD violations?

**Investigation tasks**: See tasks list below

---

## Investigation Plan

### Phase 1: Data Analysis (Examine Actual Violations)

**1.1 Run compliance checker and capture results**

```bash
bash .cursor/scripts/check-tdd-compliance.sh --limit 100 > /tmp/tdd-compliance-full.txt
```

**1.2 Analyze the data**

- How many total violations?
- What file types? (JS/TS vs shell scripts)
- Recent vs old violations?

**1.3 Pick 3-5 violations to deep-dive**

- For each: What files changed? Tests missing or not updated?
- Classify: Legitimate exception vs real violation

**1.4 Calculate adjusted compliance**

- If legitimate exceptions found, recalculate: (total - exceptions) / total
- Determine: Is real non-compliance closer to 5%, 10%, or 17%?

---

### Phase 2: Rule Content Analysis

**2.1 Map the reference chain**

- Document all cross-references: tdd-first-sh → test-quality-sh → testing → tdd-first
- Identify: How many hops to get actionable guidance?

**2.2 Extract immediate requirements**

- What should agent do BEFORE editing `.cursor/scripts/foo.sh`?
- What should agent do BEFORE editing `src/component.ts`?
- Is this spelled out clearly in first 50 lines of rule?

**2.3 Review rule language**

- Count "must" vs "should" vs "see other-rule.mdc"
- Identify vague language: "Provide practical enforcement" vs "Create X.test.sh before editing X.sh"

**2.4 Compare to high-compliance rules**

- How does `assistant-git-usage.mdc` (96%) structure its requirements?
- What makes those requirements more "sticky"?

---

### Phase 3: Rule Interaction Analysis

**3.1 List rules typically loaded together**

- When editing `.cursor/scripts/foo.sh`, what else loads?
  - tdd-first.mdc (alwaysApply: true)
  - tdd-first-sh.mdc (glob match)
  - test-quality-sh.mdc (glob match)
  - assistant-behavior.mdc (alwaysApply: true) - consent, TDD gate, scope-check
  - scope-check.mdc (alwaysApply: true)
  - Others?

**3.2 Map decision points**

- Agent wants to edit foo.sh
- Which rule fires first?
- What does each rule require?
- Where might they conflict?

**3.3 Test conflict scenarios**

- Scenario: Create new script without test
  - TDD says: Create test first
  - Consent says: Ask before creating files
  - Which wins? What does agent actually do?

**3.4 Review escape valves**

- Does `assistant-behavior.mdc` document TDD precedence?
- Is there one-shot consent that covers test + impl together?
- Or does each file creation require separate consent?

---

### Phase 4: Pattern Analysis

**4.1 Examine violation contexts**

- Review chat history for 3-5 violations (if accessible)
- Questions:
  - How long was the conversation?
  - How many rules were loaded?
  - Was there user time pressure? ("quickly", "just", "simple")
  - Was test creation discussed but skipped?

**4.2 Look for violation patterns**

- Time of day? (Start of session vs end)
- File type? (JS/TS vs shell)
- Change type? (New file vs edit existing vs refactor)
- Request type? (Bug fix vs feature vs cleanup)

**4.3 Analyze compliance successes**

- For the 83% compliant cases, what was different?
- Was test creation explicit in conversation?
- Were there fewer competing rules?
- Shorter/clearer user requests?

---

## Investigation Tasks

### H1: Rule Content Clarity

- [ ] Map tdd-first-sh reference chain (all cross-references)
- [ ] Extract immediate pre-edit requirements
- [ ] Count directive language ("must" vs "see other rule")
- [ ] Compare to assistant-git-usage (96% compliance) structure
- [ ] Draft clearer "Before editing" checklist
- [ ] Propose rule language improvements

### H2: Rule Conflicts

- [ ] List all rules that load when editing shell scripts
- [ ] List all rules that load when editing JS/TS files
- [ ] Map decision flow: agent wants to create foo.sh + foo.test.sh
- [ ] Identify conflicts between TDD, consent, and scope-check
- [ ] Review escape valves in assistant-behavior.mdc
- [ ] Test conflict scenario in practice
- [ ] Propose precedence documentation

### H3: Measurement Accuracy

- [ ] Run compliance checker with full output
- [ ] Categorize violations: library/test file/config/trivial/behavior change
- [ ] Calculate percentage of legitimate exceptions
- [ ] Determine adjusted "real" compliance rate
- [ ] Propose checker improvements (filter exceptions)
- [ ] Document what counts as legitimate exception

### H4: Habit/Oversight Patterns

- [ ] For 3-5 violations, examine conversation context (if available)
- [ ] Analyze: conversation length, rules loaded, time pressure signals
- [ ] Look for violation patterns (time/type/context)
- [ ] Compare to compliance successes (what was different?)
- [ ] Examine pre-send gate: does it catch TDD violations?
- [ ] Propose habit reinforcement mechanisms

---

## Success Criteria

**Investigation complete when**:

1. ✅ All 4 hypotheses examined with data
2. ✅ Root cause(s) identified with evidence
3. ✅ Specific recommendations made (not just "make alwaysApply")
4. ✅ Adjusted compliance rate calculated (accounting for exceptions)
5. ✅ Action plan created based on findings

**Possible outcomes**:

- **Real compliance is >90%** (most 17% are exceptions) → Update checker, document exceptions
- **Rule content is unclear** → Improve language, add checklist, reduce hops
- **Rules conflict** → Document precedence, add escape valves
- **Habit issue** → Add visible reminders, strengthen pre-send gate
- **Multiple factors** → Address highest-impact issue first, iterate

---

## Next Steps

1. ⏸️ User approval to proceed with investigation
2. ⏸️ Phase 1: Run compliance checker, analyze violations
3. ⏸️ Phase 2-4: Execute based on Phase 1 findings
4. ⏸️ Document findings and recommendations
5. ⏸️ Implement approved improvements
6. ⏸️ Re-measure and validate

---

**Status**: Ready to begin Phase 1  
**Estimated effort**: 3-4 hours for full investigation  
**Expected outcome**: Data-driven recommendations for improving TDD compliance
