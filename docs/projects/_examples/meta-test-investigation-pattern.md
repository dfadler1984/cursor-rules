# Meta-Test Investigation Pattern

**Pattern Type**: Investigation methodology  
**Source**: [rules-enforcement-investigation](../rules-enforcement-investigation/README.md)  
**Discovered**: 2025-10-15

---

## Problem This Pattern Solves

When investigating why a system behaves unexpectedly, you need empirical evidence, not speculation. Traditional investigation approaches (e.g., multi-week test plans) can be slow and may not identify root causes.

**Key Insight**: If you have an existing mechanism that works correctly, you can use it as a "meta-test" to validate your hypothesis about what's broken.

---

## Pattern Description

**Compare a working example to a broken example** to isolate the root cause in minutes rather than weeks.

### Core Concept

1. Identify a **working reference case** (a similar mechanism that behaves correctly)
2. Identify the **broken case** (the mechanism that's failing)
3. **Compare their structures** to find the critical difference
4. **Validate the hypothesis** by observing both in parallel

### Why It Works

- **Empirical**: Observes actual behavior, not theoretical expectations
- **Fast**: Direct comparison reveals differences immediately
- **Definitive**: When structures differ in exactly one way and behaviors differ correspondingly, you've found root cause

---

## Example: Rules Enforcement Investigation

**Problem**: Assistant violated git-usage rules despite rules being properly configured

**Traditional Approach**:

- Design 4-week test plan
- Test hypotheses about rule processing
- Run controlled experiments
- Analyze results

**Meta-Test Approach** (actual outcome: <5 minutes):

1. **Working Reference**: Self-improve rule (`alwaysApply: true`) was followed perfectly

   - Pattern detection worked
   - Checkpoint triggered correctly
   - Proposal format correct

2. **Broken Case**: Git-usage rule (`alwaysApply: false`) was violated

   - Script-first not followed
   - Multiple violations observed

3. **Critical Difference Found**: `alwaysApply: true` vs `false`

4. **Hypothesis Confirmed**: Conditional attachment (`alwaysApply: false`) is the root cause

**Result**: 4 weeks → <1 day, with high confidence

---

## When to Use This Pattern

### Good Fit

✅ You have a working reference case available  
✅ The working and broken cases share similar mechanics  
✅ You can observe both cases in parallel  
✅ The root cause is likely structural (configuration, architecture)

### Poor Fit

❌ No working reference exists  
❌ Cases are too different to compare meaningfully  
❌ Root cause is likely environmental or timing-dependent  
❌ You need to understand all possible failure modes (not just fix the immediate issue)

---

## Step-by-Step Application

### Phase 0: Reconnaissance (5-10 minutes)

1. **Identify candidates** for working reference

   - Similar mechanisms in the same system
   - Recently working code that now fails
   - Analogous patterns in related domains

2. **Validate the reference**
   - Verify it actually works as expected
   - Confirm it's similar enough to the broken case
   - Check that it's subject to the same rules/constraints

### Phase 1: Structure Comparison (10-30 minutes)

1. **List structural elements** of each case

   - Configuration settings
   - Code structure
   - Dependencies
   - Metadata (front matter, annotations, etc.)

2. **Diff the structures**
   - Find elements that differ
   - Identify which differences are intentional vs accidental
   - Rank differences by likelihood of causing the issue

### Phase 2: Hypothesis Formation (5 minutes)

1. **Pick the most likely difference**

   - Usually the simplest structural difference
   - Often a configuration/metadata difference
   - Sometimes an order/timing difference

2. **State the hypothesis precisely**
   - "If X is the root cause, then changing broken case to match working case should fix it"

### Phase 3: Validation (variable time)

1. **Apply the fix** to the broken case
2. **Observe the behavior** in the same way you observed the working case
3. **Confirm the fix** worked

---

## Anti-Patterns

### Anti-Pattern 1: Ignoring the Working Reference

**Wrong**: "Let's debug the broken case in isolation"

**Why It Fails**: You'll spend time on theories when you have empirical evidence right in front of you

**Right**: "The working case shows us exactly what structure is needed"

### Anti-Pattern 2: Comparing Too Many Things

**Wrong**: "Let's compare 10 different cases to find patterns"

**Why It Fails**: More comparisons = more noise; harder to isolate single root cause

**Right**: "Pick the single best working reference and compare to the broken case"

### Anti-Pattern 3: Stopping at Speculation

**Wrong**: "It's probably X because that makes sense theoretically"

**Why It Fails**: Confirmation bias; you haven't validated empirically

**Right**: "The structures differ in X; let's observe if that's the cause"

---

## Reusable Checklist

- [ ] **Working reference identified**: System/mechanism that works correctly
- [ ] **Broken case identified**: System/mechanism that fails
- [ ] **Similarity confirmed**: Both use same underlying infrastructure/rules
- [ ] **Structural diff performed**: List of differences identified
- [ ] **Hypothesis stated**: "If X is root cause, then Y fix should work"
- [ ] **Validation observable**: Can observe both cases under same conditions
- [ ] **Fix applied**: Made broken case match working case in the hypothesized dimension
- [ ] **Behavior confirmed**: Broken case now works like working case

---

## Variations

### Variation 1: Temporal Meta-Test

**When**: Same system worked before, broken now

**Approach**: Compare current version to last-known-good version

**Example**: Git bisect to find breaking commit

### Variation 2: Cross-System Meta-Test

**When**: Another system handles the problem correctly

**Approach**: Study how the working system is structured

**Example**: Taskmaster/Spec-kit comparison in original investigation

### Variation 3: Synthetic Meta-Test

**When**: No natural working reference exists

**Approach**: Create a minimal working example, then gradually make it match broken case

**Example**: Minimal repro in testing

---

## Documentation Template

When documenting a meta-test investigation:

```markdown
## Meta-Test Results

**Working Reference**: [What worked]

- Structure: [Key elements]
- Behavior: [Observed correctly working behavior]

**Broken Case**: [What failed]

- Structure: [Key elements]
- Behavior: [Observed failure mode]

**Critical Difference**: [The ONE thing that differs]

**Hypothesis**: If [difference] is root cause, then [fix] should work

**Validation**:

- Applied fix: [What changed]
- Result: [Worked/Didn't work]
- Confidence: [HIGH/MEDIUM/LOW]
```

---

## Related Patterns

- **Binary Search**: Narrow down a large search space by halving it repeatedly
- **Differential Diagnosis**: Medical pattern for comparing symptoms to known conditions
- **A/B Testing**: Compare two variants to see which performs better
- **Git Bisect**: Automated binary search for breaking commits

**Difference**: Meta-test focuses on structural comparison of working vs broken, not just behavior measurement.

---

## Success Metrics

A meta-test investigation is successful when:

- **Time Saved**: Achieves result in <10% of traditional investigation time
- **Confidence**: High confidence in root cause (empirical validation, not speculation)
- **Actionable**: Produces a concrete fix, not just analysis
- **Reusable**: Creates artifacts (test cases, fixes) that prevent regression

---

## References

- Original Investigation: [docs/projects/rules-enforcement-investigation/discovery.md](../rules-enforcement-investigation/discovery.md) (Part 10)
- Self-Improve Rule: `.cursor/rules/assistant-behavior.mdc` (lines 259-291)
- Git-Usage Rule: `.cursor/rules/assistant-git-usage.mdc`

---

**Status**: Pattern extracted and documented  
**Reusability**: HIGH — applicable to any system with working and broken instances  
**Evidence**: Saved 3.5 weeks in original investigation
