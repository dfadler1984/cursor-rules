# Valid Measurement Strategies for AI Assistant Behavior

**Purpose**: Practical guide for measuring assistant compliance without observer bias  
**Context**: [testing-paradox.md](testing-paradox.md) explains why prospective self-testing is invalid

---

## Quick Decision Tree

```
Need to measure assistant behavior?
│
├─ Can you measure from past artifacts?
│  └─ YES → Historical Analysis (most reliable)
│
├─ Can you accumulate data during normal work?
│  └─ YES → Natural Usage Monitoring (preferred for validation)
│
├─ Can user observe during real requests?
│  └─ YES → User-Observed Validation (qualitative)
│
├─ Can automation check outcomes?
│  └─ YES → External Validation (CI/hooks/linters)
│
└─ None of the above?
   └─ Experiment likely infeasible for self-testing
```

---

## Strategy 1: Historical Analysis (Retrospective)

### When to Use

- Establishing baselines
- Measuring past compliance
- Before/after comparisons
- Statistical analysis (large samples)

### How It Works

**Principle**: Measure behavior from artifacts created during natural usage (before measurement was planned).

**Data sources**:

- Git commit history
- Branch names
- PR descriptions
- File structures
- Test coverage reports

**Example**: Script usage baseline

```bash
# Measure conventional commits in last 100 commits
bash .cursor/scripts/check-script-usage.sh --limit 100

# Result: 74% compliance (before any fix applied)
```

### Strengths

- ✅ No observer bias (past behavior can't be changed)
- ✅ Large samples available (git history)
- ✅ Statistical confidence possible
- ✅ Objective measurement

### Limitations

- ❌ Can't measure future behavior
- ❌ Limited to artifacts that exist
- ❌ Can't test changes until after they're applied

### Implementation Pattern

1. **Define metric** (e.g., "% of commits using git-commit.sh")
2. **Query artifacts** (e.g., git log, parse commit messages)
3. **Apply heuristic** (e.g., detect conventional commit format)
4. **Calculate compliance** (e.g., 74 conventional / 100 total = 74%)
5. **Report baseline** (document before any intervention)

---

## Strategy 2: Natural Usage Monitoring (Passive)

### When to Use

- Validating a fix or change
- Measuring sustained compliance
- Real-world effectiveness testing
- Accumulating validation data

### How It Works

**Principle**: Apply change, work normally (no conscious testing), measure after sufficient sample.

**Critical requirement**: **No continuous measurement or test awareness during accumulation period.**

**Example**: H1 validation (alwaysApply fix)

```bash
# Step 1: Apply fix (2025-10-15)
# Changed assistant-git-usage.mdc → alwaysApply: true

# Step 2: Work normally for 21 commits (no testing)
# Regular development workflow, no special test scenarios

# Step 3: Measure after threshold (2025-10-16)
bash .cursor/scripts/compliance-dashboard.sh --limit 100

# Result: 74% → 80% (+6 points improvement)
```

### Strengths

- ✅ Reflects natural usage patterns
- ✅ Observer bias minimized (measure after work, not during)
- ✅ Real-world validation
- ✅ Can detect sustained vs temporary improvement

### Limitations

- ⏳ Requires time (20-30 operations minimum)
- 📊 Smaller samples than historical analysis
- ❌ Can't control variables

### Implementation Pattern

1. **Apply intervention** (e.g., change rule to alwaysApply: true)
2. **Set threshold** (e.g., 20-30 commits)
3. **Work normally** (ignore compliance during work)
4. **Accumulate naturally** (no artificial test scenarios)
5. **Measure after threshold** (run dashboard/checkers once)
6. **Compare to baseline** (historical analysis provides baseline)

### Anti-Pattern (Invalid)

❌ **Don't do this**:

```
Apply fix → Issue test request #1 → Measure → Test #2 → Measure → ...
```

This introduces test awareness and observer bias.

✅ **Do this instead**:

```
Apply fix → Work normally (20-30 operations) → Measure once
```

---

## Strategy 3: User-Observed Validation (Qualitative)

### When to Use

- Spot checking specific behaviors
- Qualitative feedback needed
- Quick validation of presence/absence
- User experience evaluation

### How It Works

**Principle**: User issues natural requests without telling assistant it's a test; observes compliance.

**Example**: Slash commands discovery

```
User: "/status"  (natural attempt to use slash command)
Result: Cursor opened command palette (not sent to assistant)
Discovery: Cursor's `/` is for UI commands, not message routing
Time: 30 seconds
```

**Contrast with prospective self-testing**:

- 50 trials: 8-12 hours, biased results
- 1 real attempt: 30 seconds, valid discovery

### Strengths

- ✅ Fast (seconds to minutes)
- ✅ Reflects user experience
- ✅ Valid for existence proofs
- ✅ No observer bias (assistant unaware of test)

### Limitations

- ❌ Not statistical (small sample)
- ❌ Subjective assessment
- ❌ Requires user availability

### Implementation Pattern

1. **User issues natural request** (no "test this" framing)
2. **Assistant responds normally** (unaware it's being evaluated)
3. **User observes compliance** (notes presence/absence of issue)
4. **Document finding** (qualitative description)

### When NOT Valid

❌ User says: "I'm going to test slash commands. Can you comply?"

- This introduces test awareness for the assistant
- Results become biased

✅ User simply uses slash commands naturally

- Assistant unaware of testing context
- Observations valid

---

## Strategy 4: External Validation (Automated)

### When to Use

- CI enforcement needed
- Deterministic checks possible
- Automated gates preferred
- Pre-commit/pre-push validation

### How It Works

**Principle**: Automated tools check artifacts independently of assistant.

**Examples**:

**CI checks**:

```yaml
# .github/workflows/validate.yml
- name: Check branch naming
  run: bash .cursor/scripts/check-branch-names.sh
```

**Pre-commit hooks**:

```bash
# .git/hooks/pre-commit
bash .cursor/scripts/git-commit.sh --validate
```

**Linters**:

```bash
eslint --fix src/
```

### Strengths

- ✅ Zero observer bias
- ✅ Automated enforcement
- ✅ Fast feedback
- ✅ Prevents violations before commit/push

### Limitations

- ⚠️ Only checks artifacts (not assistant reasoning)
- ⚠️ Deterministic rules only (not behavioral nuance)
- ⚠️ Setup cost (scripts, CI config)

### Implementation Pattern

1. **Create checker script** (e.g., validate conventional commits)
2. **Integrate with CI** (run on PRs)
3. **Add pre-commit hook** (local enforcement)
4. **Fail build on violation** (forcing function)

---

## Comparison Matrix

| Strategy                        | Speed             | Sample Size    | Observer Bias | Use Case                 |
| ------------------------------- | ----------------- | -------------- | ------------- | ------------------------ |
| **Historical Analysis**         | Instant           | Large (100s)   | None          | Baselines, comparisons   |
| **Natural Usage Monitoring**    | Slow (days/weeks) | Medium (20-30) | Minimal       | Fix validation           |
| **User-Observed**               | Fast (seconds)    | Small (1-5)    | None          | Spot checks, qualitative |
| **External Validation**         | Instant           | Any            | None          | Automated enforcement    |
| ❌ **Prospective Self-Testing** | Slow (hours)      | Any            | **High**      | **INVALID**              |

---

## Combining Strategies

**Best practice**: Use multiple strategies for comprehensive validation.

### Example: H1 Validation (AlwaysApply Fix)

1. **Historical Analysis** → Baseline: 74% script usage (100 commits)
2. **Apply fix** → `assistant-git-usage.mdc` → `alwaysApply: true`
3. **Natural Usage Monitoring** → Work normally for 21 commits
4. **Historical Analysis again** → Post-fix: 80% script usage
5. **Result** → +6 points improvement validated via natural usage

### Example: Branch Naming Enforcement

1. **Historical Analysis** → Baseline: 62% compliance (139 branches)
2. **External Validation** → Add pre-push hook
3. **User-Observed** → Spot check: does hook block bad names?
4. **Natural Usage Monitoring** → Create 10 branches normally
5. **Historical Analysis again** → Post-hook: measure improvement

---

## Anti-Patterns to Avoid

### ❌ Continuous Measurement During Work

**Bad**:

```
Commit 1 → Check compliance → Commit 2 → Check compliance → ...
```

**Why**: Introduces test awareness, changes behavior

**Good**:

```
20 commits → Check compliance once
```

### ❌ Announcing Tests to Assistant

**Bad**:

```
User: "I'm going to test whether you use slash commands correctly."
```

**Why**: Creates observer bias

**Good**:

```
User: "/commit" (natural use, no test announcement)
```

### ❌ Prospective Self-Testing Trials

**Bad**:

```
Assistant issues 50 test requests to itself, measures compliance
```

**Why**: Invalid due to observer bias (see [testing-paradox.md](testing-paradox.md))

**Good**:

```
Work normally, accumulate 50 operations, measure retrospectively
```

---

## Recommendations by Scenario

### Scenario: "I want to know current compliance"

→ Use **Historical Analysis** (instant, large sample)

### Scenario: "I changed a rule; does it help?"

→ Use **Natural Usage Monitoring** (wait for 20-30 operations, then measure)

### Scenario: "Does this specific behavior work?"

→ Use **User-Observed Validation** (try it naturally, observe result)

### Scenario: "I need to prevent violations"

→ Use **External Validation** (CI checks, pre-commit hooks)

### Scenario: "I want to run test trials"

→ ❌ **Invalid for assistant behavior measurement** (observer bias)

---

## Tools & Scripts

### For Historical Analysis

- `check-script-usage.sh` — Conventional commit compliance
- `check-tdd-compliance.sh` — Spec file correlation
- `check-branch-names.sh` — Branch naming compliance
- `compliance-dashboard.sh` — Aggregate metrics

### For Natural Usage Monitoring

- Same tools as historical analysis
- Run periodically (every ~5 commits for trend, full analysis after threshold)

### For External Validation

- `.git/hooks/pre-commit` — Local enforcement
- `.git/hooks/pre-push` — Branch naming validation
- `.github/workflows/*.yml` — CI checks

---

## Key Principles

1. **Measure outcomes, not awareness** (artifacts, not assistant reasoning)
2. **Retrospective > prospective** (past behavior is unbiased)
3. **Passive > active** (accumulate first, measure after)
4. **Real usage > test trials** (natural requests beat artificial scenarios)
5. **Multiple strategies** (triangulate for confidence)

---

## Related

- [testing-paradox.md](testing-paradox.md) — Why prospective self-testing is invalid
- [experiment-design-guide.md](experiment-design-guide.md) — When to use each approach
- [rules-enforcement-investigation](../rules-enforcement-investigation/) — Real-world application

---

**Summary**: Use historical analysis for baselines, natural usage monitoring for validation, user observation for spot checks, and external validation for enforcement. Avoid prospective self-testing due to observer bias.
