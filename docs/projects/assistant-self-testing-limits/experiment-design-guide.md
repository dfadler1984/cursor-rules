# Experiment Design Guide: Choosing Valid Measurement Approaches

**Purpose**: Decision framework for designing experiments that measure AI assistant behavior  
**Prerequisites**: Read [testing-paradox.md](testing-paradox.md) and [measurement-strategies.md](measurement-strategies.md)

---

## Quick Decision Framework

### Step 1: What are you measuring?

**A. Assistant behavior** (compliance, routing, following rules)  
→ Proceed to Step 2

**B. Artifact quality** (code correctness, test coverage, output format)  
→ Use external validation (automated checks, linters, tests)

**C. User experience** (helpfulness, clarity, speed)  
→ Use user-observed validation (qualitative feedback)

### Step 2: Do you need statistical confidence?

**YES** → Use historical analysis (large sample, retrospective)

**NO** → Proceed to Step 3

### Step 3: Is behavior change being tested?

**YES** (testing a fix or intervention)  
→ Use natural usage monitoring (before/after with sufficient sample)

**NO** (just checking current state)  
→ Use historical analysis (measure existing artifacts)

### Step 4: Do you have time to accumulate data?

**YES** → Use natural usage monitoring (wait for 20-30 operations)

**NO** → Use user-observed validation (spot check, qualitative)

### Step 5: Can automated tools check the outcome?

**YES** → Consider external validation (CI, hooks, linters)

**NO** → Stay with chosen qualitative/quantitative approach

---

## Decision Tree (Detailed)

```
┌─────────────────────────────────────────────────────────┐
│ Need to measure assistant behavioral compliance?       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
          ┌───────────────────────────────┐
          │ What's the research question? │
          └───────────────────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        ▼                                   ▼
┌──────────────────┐              ┌──────────────────┐
│ Current state?   │              │ Testing a change?│
│ "How compliant   │              │ "Does X improve  │
│  are we now?"    │              │  compliance?"    │
└──────────────────┘              └──────────────────┘
        │                                   │
        ▼                                   ▼
┌──────────────────┐              ┌──────────────────┐
│ HISTORICAL       │              │ Need baseline?   │
│ ANALYSIS         │              └──────────────────┘
│                  │                        │
│ Measure past     │              ┌─────────┴─────────┐
│ artifacts        │              ▼                   ▼
│                  │         ┌─────────┐         ┌─────────┐
│ Example:         │         │ YES     │         │ NO      │
│ Last 100 commits │         └─────────┘         └─────────┘
│ 74% script usage │              │                   │
└──────────────────┘              ▼                   │
                          ┌──────────────────┐        │
                          │ HISTORICAL       │        │
                          │ ANALYSIS FIRST   │        │
                          │ (baseline)       │        │
                          └──────────────────┘        │
                                  │                   │
                                  └──────┬────────────┘
                                         ▼
                                ┌──────────────────┐
                                │ Apply change     │
                                │ Work normally    │
                                │ (20-30 ops)      │
                                └──────────────────┘
                                         │
                                         ▼
                                ┌──────────────────┐
                                │ NATURAL USAGE    │
                                │ MONITORING       │
                                │                  │
                                │ Measure after    │
                                │ sufficient sample│
                                │                  │
                                │ Example:         │
                                │ 21 commits later │
                                │ 74% → 80%        │
                                └──────────────────┘
```

---

## Scenario Patterns

### Pattern 1: Baseline Measurement

**Question**: "What's our current compliance?"

**Approach**: Historical Analysis

**Steps**:

1. Define metric (e.g., "% conventional commits")
2. Query artifacts (git log)
3. Apply heuristic (parse commit format)
4. Calculate compliance
5. Document baseline

**Example from rules-enforcement-investigation**:

```bash
bash .cursor/scripts/check-script-usage.sh --limit 100
# Result: 74% baseline
```

**Valid because**: Measuring past behavior that already happened (no observer bias)

---

### Pattern 2: Fix Validation

**Question**: "Does this change improve compliance?"

**Approach**: Historical Analysis (baseline) + Natural Usage Monitoring (validation)

**Steps**:

1. **Baseline**: Historical analysis of current state
2. **Intervention**: Apply the fix/change
3. **Accumulation**: Work normally (20-30 operations minimum)
4. **Measurement**: Historical analysis of recent period
5. **Comparison**: Before vs after

**Example from rules-enforcement-investigation (H1)**:

```
Baseline (historical):    74% script usage (last 100 commits)
Intervention:             assistant-git-usage.mdc → alwaysApply: true
Accumulation:             21 commits of normal work
Measurement (historical): 80% script usage (last 21 commits)
Result:                   +6 points improvement validated
```

**Valid because**:

- Baseline is retrospective (no bias)
- Accumulation is natural usage (no test awareness)
- Post-measurement is retrospective (measures what naturally happened)

---

### Pattern 3: Feature Exploration

**Question**: "Does slash command `/commit` work in Cursor?"

**Approach**: User-Observed Validation (single trial, qualitative)

**Steps**:

1. User attempts feature naturally (no announcement)
2. Observe outcome (works / doesn't work / unexpected behavior)
3. Document finding (qualitative description)

**Example from rules-enforcement-investigation**:

```
User: "/status" (natural attempt)
Result: Cursor UI opened command palette
Discovery: Cursor's `/` is for prompt templates, not message routing
Time: 30 seconds
Conclusion: Runtime routing approach not viable
```

**Valid because**: One real usage attempt, no test awareness for assistant, existence proof sufficient

**Would NOT be valid**:

```
Assistant: "I will now test 50 slash command scenarios"
[Runs 50 biased trials]
```

---

### Pattern 4: Enforcement Implementation

**Question**: "Can we prevent violations automatically?"

**Approach**: External Validation (CI, hooks, linters)

**Steps**:

1. Create automated checker
2. Integrate with CI/hooks
3. Test checker logic independently
4. Deploy to workflow
5. Monitor violations prevented

**Example**:

```yaml
# .github/workflows/validate.yml
- name: Validate branch naming
  run: |
    bash .cursor/scripts/check-branch-names.sh
    if [ $? -ne 0 ]; then
      echo "Branch name must follow pattern: <login>/<type>-<feature>-<task>"
      exit 1
    fi
```

**Valid because**: Automated check has no observer bias, deterministic validation

---

### Pattern 5: Quick Spot Check

**Question**: "Is this specific behavior working?"

**Approach**: User-Observed Validation (qualitative)

**Steps**:

1. User issues natural request (no test framing)
2. Observe compliance (yes/no/partial)
3. Document finding (brief note)

**Example**:

```
User: "Commit these changes with message: fix: typo"
Observes: Assistant used git-commit.sh script ✅
OR
Observes: Assistant ran git commit directly ❌
```

**Valid because**: Single natural request, assistant unaware of test, qualitative check sufficient

---

## Invalid Patterns (Avoid These)

### ❌ Anti-Pattern 1: Prospective Self-Testing Trials

**Attempted approach**:

```
"Run 50 test trials where I issue git requests to myself.
 Measure how often I follow slash command rules."
```

**Why invalid**:

- Conscious test awareness → behavioral change
- Observer bias → results don't predict natural usage
- See [testing-paradox.md](testing-paradox.md) for detailed explanation

**Valid alternative**:

- Natural usage monitoring (work normally, measure after 20-30 operations)
- User-observed validation (user issues requests, observes compliance)

---

### ❌ Anti-Pattern 2: A/B Self-Comparison

**Attempted approach**:

```
"Test A: use explicit verbs (20 trials)
 Test B: use slash commands (20 trials)
 Compare compliance between A and B"
```

**Why invalid**:

- Requires two independent instances (not possible in single session)
- Test awareness for both conditions → bias in both
- Cannot control for order effects

**Valid alternative**:

- Historical analysis of two different time periods (before/after a change)
- Natural usage monitoring with single intervention

---

### ❌ Anti-Pattern 3: Continuous Measurement

**Attempted approach**:

```
Operation 1 → Measure compliance → Operation 2 → Measure → ...
```

**Why invalid**:

- Introduces test awareness (conscious of measurement)
- Changes behavior during accumulation period

**Valid alternative**:

```
[20-30 operations with no measurement] → Measure once after threshold
```

---

### ❌ Anti-Pattern 4: Announced Testing

**Attempted approach**:

```
User: "I'm going to test slash commands now."
[Issues test requests]
```

**Why invalid**:

- Assistant becomes test-aware
- Behavioral change during test period

**Valid alternative**:

```
User: "/commit" (natural use, no test announcement)
```

---

## When Experiments Are Infeasible

Some questions **cannot be answered** via self-testing:

### Example: "Which phrasing yields better routing?"

**Why infeasible**:

- Requires A/B comparison
- Both conditions need test awareness
- Cannot achieve blind testing in single assistant instance

**Alternatives**:

- Historical analysis of natural phrasing variations
- User preference feedback (qualitative)
- Accept limitation and use best-practice guidance instead of empirical data

### Example: "Does reminder X improve TDD compliance?"

**Why infeasible**:

- Adding reminder makes assistant test-aware
- Cannot measure natural baseline after reading reminder
- Observer effect fundamental to the measurement

**Alternatives**:

- Proxy metrics (e.g., do violations mention forgetting TDD?)
- User-observed spot checks (qualitative)
- External validation (CI fails when spec missing)

---

## Designing Valid Experiments

### Checklist Before Starting

- [ ] Is the system under test == the observer? (If YES, high risk of bias)
- [ ] Can I measure retrospectively? (Preferred)
- [ ] Can I accumulate data passively? (Valid if no continuous measurement)
- [ ] Does user need to observe? (Valid if natural requests)
- [ ] Can automation check? (Valid if deterministic)
- [ ] Would this require prospective self-testing trials? (Invalid if YES)

### Red Flags (Likely Invalid)

- 🚩 "Run N test trials and measure compliance"
- 🚩 "Compare A vs B with self-testing"
- 🚩 "Continuously measure during accumulation"
- 🚩 "Announce test context before measurement"

### Green Flags (Likely Valid)

- ✅ "Measure past behavior from git log"
- ✅ "Apply change, work normally for N ops, then measure"
- ✅ "User tries feature naturally, observes outcome"
- ✅ "CI checks artifacts automatically"

---

## Examples from Rules-Enforcement-Investigation

### ✅ Valid: H0 (Meta-Test)

**Question**: Can rules work when alwaysApply: true?

**Approach**: Historical analysis of self-improve rule (already alwaysApply: true)

**Result**: ✅ Self-improve pattern worked in past → proves rules CAN work

**Valid because**: Measured past behavior, no prospective testing needed

---

### ✅ Valid: H1 (Conditional Attachment)

**Question**: Does alwaysApply: true improve compliance?

**Approach**: Historical baseline + natural usage monitoring

**Steps**:

1. Baseline: 74% (retrospective)
2. Fix: alwaysApply: false → true
3. Accumulation: 21 commits (normal work)
4. Measurement: 80% (retrospective)

**Result**: +6 points improvement validated

**Valid because**: Both measurements retrospective, accumulation passive

---

### 🔄 Partially Valid: H2 (Send Gate)

**Question**: Does visible gate improve compliance?

**Approach**: Passive monitoring (observe gate visibility during normal work)

**Status**: Monitoring active, not yet measured

**Valid because**: Passive observation during natural usage, measure after sufficient sample

---

### 🔄 Partially Valid: H3 (Query Visibility)

**Question**: Does visible query output improve compliance?

**Approach**: Passive monitoring (observe query output during git operations)

**Status**: Monitoring active, not yet measured

**Valid because**: Passive observation, no test trials

---

### ⏸️ Deferred: Slash Commands Phase 3

**Question**: Do slash commands improve routing accuracy?

**Original approach**: 50 prospective self-testing trials

**Why deferred**: Invalid due to observer bias

**Alternative**: H1 at 80% reduces urgency; real usage already validates (user tried `/status`)

---

## Summary Decision Table

| Scenario                     | Approach                   | Reason                 | Valid? |
| ---------------------------- | -------------------------- | ---------------------- | ------ |
| "What's current compliance?" | Historical Analysis        | Retrospective          | ✅     |
| "Does fix X work?"           | Historical + Natural Usage | Before/after passive   | ✅     |
| "Does feature Y exist?"      | User-Observed              | One natural trial      | ✅     |
| "Prevent violations?"        | External Validation        | Automated checks       | ✅     |
| "Run 50 test trials"         | Prospective Self-Testing   | Observer bias          | ❌     |
| "A/B comparison"             | Self-Testing               | Requires blind testing | ❌     |

---

## Key Principles

1. **Retrospective > Prospective** for assistant behavior
2. **Passive > Active** accumulation
3. **Natural > Artificial** requests
4. **External > Self-observed** when automation possible
5. **Acknowledge limits** when experiments are infeasible

---

## Further Reading

- [testing-paradox.md](testing-paradox.md) — Why self-testing is invalid
- [measurement-strategies.md](measurement-strategies.md) — How to use each valid approach
- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Real-world examples

---

**Quick Summary**: Prefer retrospective analysis and passive monitoring. Avoid prospective self-testing trials. Use user observation for spot checks and external validation for enforcement. Some experiments are infeasible — accept the limitation and use proxy approaches.
