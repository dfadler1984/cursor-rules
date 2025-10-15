# Test Plan: Measurement Framework — Automated Compliance Monitoring

**Objective**: Build automated tools to measure rule compliance objectively, enabling ongoing validation and regression detection.

**Related Discovery Section**: Part 7 → Measurement Framework Proposal

---

## Background

**Problem**: Currently no objective way to measure if rules are being followed

**Need**:

- Baseline measurements before improvements
- Post-change validation
- Ongoing monitoring for regressions
- Objective success criteria for all tests

**Approach**: Build scripts to analyze git history, chat logs, and code changes for compliance signals

---

## Measurement Components

### Component 1: Script Usage Rate Checker

**Purpose**: Measure what % of git operations use repo scripts vs raw git

**Data Source**: Git commit history

**Method**:

```bash
#!/usr/bin/env bash
# .cursor/scripts/compliance/check-script-usage.sh

# Analyze recent commits for conventional commit format
# (indicator that git-commit.sh was used)

count_conventional=0
count_nonconventional=0

# Get last N commits
git log --oneline -n "$limit" | while read -r commit_msg; do
  if [[ "$commit_msg" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert) ]]; then
    ((count_conventional++))
  else
    ((count_nonconventional++))
  fi
done

usage_rate=$(awk "BEGIN {print ($count_conventional / ($count_conventional + $count_nonconventional)) * 100}")
echo "Script usage rate: $usage_rate%"
echo "Conventional commits: $count_conventional"
echo "Non-conventional commits: $count_nonconventional"
```

**Output**:

```
Script usage rate: 73.5%
Conventional commits: 147
Non-conventional commits: 53

Compliance target: >90%
Status: BELOW TARGET
```

---

### Component 2: TDD Compliance Checker

**Purpose**: Measure what % of implementation commits include corresponding spec changes

**Data Source**: Git diffs

**Method**:

```bash
#!/usr/bin/env bash
# .cursor/scripts/compliance/check-tdd-compliance.sh

# For each commit that changes implementation files,
# check if corresponding spec file was also changed

compliant_commits=0
total_impl_commits=0

git log --oneline -n "$limit" --name-only | while read -r commit; do
  # Get changed files
  changed_files=$(git show --name-only --format= "$commit")

  # Check if any implementation files changed
  impl_changed=$(echo "$changed_files" | grep -E '\.(ts|tsx|js|jsx|mjs|cjs|sh)$' | grep -v '\.spec\.')

  if [[ -n "$impl_changed" ]]; then
    ((total_impl_commits++))

    # Check if corresponding spec files changed
    for impl_file in $impl_changed; do
      # Derive spec file name
      spec_file="${impl_file%.*}.spec.${impl_file##*.}"

      if echo "$changed_files" | grep -q "$spec_file"; then
        ((compliant_commits++))
        break
      fi
    done
  fi
done

compliance_rate=$(awk "BEGIN {print ($compliant_commits / $total_impl_commits) * 100}")
echo "TDD compliance rate: $compliance_rate%"
echo "Compliant commits: $compliant_commits"
echo "Total impl commits: $total_impl_commits"
```

**Output**:

```
TDD compliance rate: 68.2%
Compliant commits: 45
Total impl commits: 66

Compliance target: >95%
Status: BELOW TARGET
```

---

### Component 3: Chat Log Analyzer (Manual/Semi-Automated)

**Purpose**: Analyze assistant responses for compliance signals

**Data Source**: Chat transcripts (if available)

**Signals to detect**:

1. **Consent requests**: "Proceed?", "May I...", consent prompts
2. **Capability queries**: "Checked capabilities.mdc", script path mentions
3. **Gate output**: "Pre-Send Gate Check", gate status
4. **Routing transparency**: "Triggered by:", "Attached rules:"

**Method** (pseudo-code):

```bash
#!/usr/bin/env bash
# .cursor/scripts/compliance/analyze-chat-log.sh

# Parse chat log for compliance signals
# Note: Assumes chat log is available in structured format

consent_requests=$(grep -c "Proceed\?" "$chat_log")
capability_queries=$(grep -c "Checked capabilities.mdc" "$chat_log")
gate_outputs=$(grep -c "Pre-Send Gate Check" "$chat_log")
routing_transparency=$(grep -c "Triggered by:" "$chat_log")

total_messages=$(count_assistant_messages "$chat_log")

consent_rate=$(awk "BEGIN {print ($consent_requests / $total_messages) * 100}")
query_visibility=$(awk "BEGIN {print ($capability_queries / $total_messages) * 100}")

echo "Consent request rate: $consent_rate%"
echo "Capability query visibility: $query_visibility%"
echo "Gate output visibility: $(awk "BEGIN {print ($gate_outputs / $total_messages) * 100}")%"
```

**Limitation**: Requires structured chat logs; may not be available

---

### Component 4: Branch Name Compliance Checker

**Purpose**: Measure what % of branches follow naming convention

**Data Source**: Git branches

**Method**:

```bash
#!/usr/bin/env bash
# .cursor/scripts/compliance/check-branch-names.sh

# Pattern: <login>/<type>-<feature>-<task> or <login>/<task>
# Examples: userLogin/feat-thing-endpoints, userLogin/task-123

compliant_branches=0
total_branches=0

git branch -r | grep -v HEAD | while read -r branch; do
  ((total_branches++))

  # Extract branch name (remove origin/)
  branch_name="${branch##*/}"

  # Check pattern: starts with <login>/
  if [[ "$branch_name" =~ ^[a-zA-Z0-9_-]+/ ]]; then
    ((compliant_branches++))
  fi
done

compliance_rate=$(awk "BEGIN {print ($compliant_branches / $total_branches) * 100}")
echo "Branch naming compliance: $compliance_rate%"
echo "Compliant branches: $compliant_branches"
echo "Total branches: $total_branches"
```

---

### Component 5: Compliance Dashboard

**Purpose**: Aggregate all metrics into single report

**Output Format**:

```
=== Rules Compliance Dashboard ===
Generated: 2025-10-15 14:30:00

Script Usage (Commit Messages)
  Rate: 73.5%
  Target: >90%
  Status: ⚠️  BELOW TARGET
  Gap: -16.5 percentage points

TDD Compliance (Spec Changes)
  Rate: 68.2%
  Target: >95%
  Status: ⚠️  BELOW TARGET
  Gap: -26.8 percentage points

Branch Naming
  Rate: 88.0%
  Target: >90%
  Status: ⚠️  NEAR TARGET
  Gap: -2.0 percentage points

Chat Compliance (if available)
  Consent rate: N/A (logs unavailable)
  Query visibility: N/A
  Gate visibility: N/A

Overall Compliance Score: 76.6%
Recommended Actions:
  1. High priority: Improve TDD compliance (26.8 pts below target)
  2. Medium priority: Improve script usage (16.5 pts below)
  3. Low priority: Improve branch naming (2 pts below)
```

---

## Test Plan

### Phase 1: Build Measurement Tools

**Step 1: Implement Core Checkers**

- [ ] Create `check-script-usage.sh`

  - [ ] Parse git log for conventional commits
  - [ ] Calculate usage rate
  - [ ] Output: rate, counts, status

- [ ] Create `check-tdd-compliance.sh`

  - [ ] Parse git diffs for impl + spec pairs
  - [ ] Calculate compliance rate
  - [ ] Output: rate, compliant/total, status

- [ ] Create `check-branch-names.sh`

  - [ ] Parse git branches
  - [ ] Check naming pattern
  - [ ] Calculate compliance rate

- [ ] Create `compliance-dashboard.sh`
  - [ ] Run all checkers
  - [ ] Aggregate results
  - [ ] Format dashboard output

**Step 2: Test Checkers**

- [ ] Run on current repository state
- [ ] Verify calculations are correct
- [ ] Check for edge cases (no commits, empty branches, etc.)
- [ ] Validate output format

---

### Phase 2: Establish Baseline

**Objective**: Measure current compliance before any improvements

**Procedure**:

1. Run all checkers on current state
2. Document baseline metrics
3. Save to baseline report

**Baseline Report Template**:

```yaml
baseline_date: 2025-10-15
measurement_period: last_100_commits
metrics:
  script_usage:
    rate: 73.5
    target: 90.0
    gap: -16.5
  tdd_compliance:
    rate: 68.2
    target: 95.0
    gap: -26.8
  branch_naming:
    rate: 88.0
    target: 90.0
    gap: -2.0
  overall_score: 76.6
```

---

### Phase 3: Post-Improvement Measurement

**Objective**: Measure compliance after each improvement is applied

**Procedure** (after each hypothesis test or experiment):

1. Apply improvement (e.g., make git-usage always-apply)
2. Generate new commits/activity
3. Run checkers again
4. Compare to baseline
5. Calculate improvement

**Comparison Report**:

```yaml
comparison_date: 2025-10-16
baseline_date: 2025-10-15
improvement: "H1: Made assistant-git-usage.mdc always-apply"

results:
  script_usage:
    baseline: 73.5
    current: 91.2
    improvement: +17.7
    status: TARGET_MET

  tdd_compliance:
    baseline: 68.2
    current: 68.5
    improvement: +0.3
    status: NO_CHANGE # This improvement didn't affect TDD

  overall_score:
    baseline: 76.6
    current: 83.2
    improvement: +6.6

success: true # improvement met target
```

---

### Phase 4: Continuous Monitoring

**Objective**: Catch regressions early

**Setup**:

1. Add checkers to CI pipeline
2. Run on every PR
3. Fail PR if compliance drops below threshold

**CI Integration** (pseudo-code):

```yaml
# .github/workflows/compliance-check.yml
name: Rules Compliance Check

on: [pull_request]

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0 # Need history for analysis

      - name: Check Script Usage
        run: bash .cursor/scripts/compliance/check-script-usage.sh

      - name: Check TDD Compliance
        run: bash .cursor/scripts/compliance/check-tdd-compliance.sh

      - name: Check Branch Naming
        run: bash .cursor/scripts/compliance/check-branch-names.sh

      - name: Generate Dashboard
        run: bash .cursor/scripts/compliance/compliance-dashboard.sh

      - name: Fail if Below Threshold
        run: |
          score=$(parse_overall_score)
          if (( $(echo "$score < 85.0" | bc -l) )); then
            echo "Compliance score $score is below threshold 85.0"
            exit 1
          fi
```

---

## Success Criteria

### Tool Implementation

- [ ] All checkers implemented and tested
- [ ] Baseline established with all metrics
- [ ] Dashboard generates correctly
- [ ] Edge cases handled gracefully

### Measurement Accuracy

- [ ] Script usage rate matches manual count (±2%)
- [ ] TDD compliance rate matches manual review (±5%)
- [ ] Branch naming rate matches manual count (±2%)

### Utility

- [ ] Baseline provides clear picture of current state
- [ ] Post-improvement comparisons show measurable changes
- [ ] CI integration catches regressions
- [ ] Dashboard is actionable (prioritizes improvements)

---

## Implementation Checklist

### Core Tools

- [ ] `check-script-usage.sh`

  - [ ] Parse git log
  - [ ] Detect conventional commits
  - [ ] Calculate rate
  - [ ] Output formatted results

- [ ] `check-tdd-compliance.sh`

  - [ ] Parse git diffs
  - [ ] Match impl files to spec files
  - [ ] Calculate rate
  - [ ] Output formatted results

- [ ] `check-branch-names.sh`

  - [ ] List all branches
  - [ ] Check naming pattern
  - [ ] Calculate rate
  - [ ] Output formatted results

- [ ] `compliance-dashboard.sh`
  - [ ] Run all checkers
  - [ ] Parse outputs
  - [ ] Calculate overall score
  - [ ] Format dashboard
  - [ ] Save report

### Baseline

- [ ] Run all checkers on current state
- [ ] Document baseline metrics
- [ ] Save baseline report (YAML or JSON)
- [ ] Commit baseline for reference

### Testing

- [ ] Unit test each checker (if feasible)
- [ ] Integration test dashboard
- [ ] Edge case testing (empty repos, no commits, etc.)
- [ ] Validate against manual counts

### CI Integration (Optional)

- [ ] Create workflow file
- [ ] Test locally with `act` or similar
- [ ] Configure thresholds
- [ ] Test PR with intentional violations
- [ ] Verify failure behavior

---

## Timeline

- **Tool Development**: 1 day (4 scripts + testing)
- **Baseline Establishment**: 1 hour (run + document)
- **CI Integration**: 2-3 hours (workflow + testing) [optional]
- **Total**: 1-2 days

---

## Risk Mitigation

**Risk**: Git log parsing is brittle (edge cases)  
**Mitigation**: Test on multiple repo states; handle empty logs gracefully

**Risk**: False positives/negatives in detection  
**Mitigation**: Manual validation of first 20-30 results; refine patterns

**Risk**: Performance issues on large repos  
**Mitigation**: Limit to recent N commits; add `--limit` flag

**Risk**: CI checks fail spuriously  
**Mitigation**: Set reasonable thresholds; allow manual override; log false positives

---

## Output Examples

### Script Usage Checker Output

```
=== Script Usage Compliance Check ===
Period: Last 100 commits
Date: 2025-10-15 14:30:00

Conventional Commits: 73
Non-Conventional Commits: 27
Total Commits: 100

Script Usage Rate: 73.0%
Target: 90.0%
Gap: -17.0 percentage points

Status: ⚠️  BELOW TARGET

Recommendation:
- Review non-conventional commits for patterns
- Ensure assistant-git-usage.mdc is always-apply
- Add visible query output to send gate
```

### TDD Compliance Checker Output

```
=== TDD Compliance Check ===
Period: Last 100 commits
Date: 2025-10-15 14:30:00

Implementation Commits: 45
Commits with Spec Changes: 31
Commits without Spec Changes: 14

TDD Compliance Rate: 68.9%
Target: 95.0%
Gap: -26.1 percentage points

Status: ⚠️  BELOW TARGET

Non-Compliant Commits:
  abc123 - "feat: add new parser"
  def456 - "fix: handle edge case"
  ...

Recommendation:
- Review TDD pre-edit gate enforcement
- Check if tests were added in separate commits
- Ensure gate is blocking, not advisory
```

### Dashboard Output

```
╔══════════════════════════════════════════════════════════════╗
║            RULES COMPLIANCE DASHBOARD                        ║
║            Generated: 2025-10-15 14:30:00                    ║
╚══════════════════════════════════════════════════════════════╝

📊 Script Usage (Commit Messages)
   Current: 73.0%  |  Target: 90.0%  |  Gap: -17.0 pts
   Status: ⚠️  BELOW TARGET
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░  73%

📊 TDD Compliance (Spec Changes)
   Current: 68.9%  |  Target: 95.0%  |  Gap: -26.1 pts
   Status: ⚠️  BELOW TARGET
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░  69%

📊 Branch Naming
   Current: 88.0%  |  Target: 90.0%  |  Gap: -2.0 pts
   Status: ⚠️  NEAR TARGET
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  88%

───────────────────────────────────────────────────────────────

Overall Compliance Score: 76.6%

🎯 Priority Actions:
   1. 🔴 HIGH: Improve TDD compliance (+26.1 pts needed)
   2. 🟡 MED:  Improve script usage (+17.0 pts needed)
   3. 🟢 LOW:  Improve branch naming (+2.0 pts needed)

For detailed analysis, see individual checker outputs.
```

---

## Automation Opportunities

**Advanced Analytics** (future):

1. Trend analysis: compliance over time
2. Contributor analysis: compliance by author
3. Operation analysis: compliance by git operation type (commit, branch, PR)
4. Regression detection: alert when compliance drops >5 pts

**Integration with Tests** (future):

1. Auto-run before/after each experiment
2. Generate comparison reports automatically
3. Track hypothesis test results over time

---

**Status**: Ready to implement  
**Owner**: rules-enforcement-investigation  
**Dependencies**: None (standalone tools)  
**Estimated effort**: 1-2 days  
**Priority**: HIGH (enables all other tests)
