# CI Integration Guide — Compliance Dashboard

**Project**: rules-enforcement-investigation  
**Purpose**: Integrate compliance monitoring into CI/CD pipeline

---

## Overview

The compliance dashboard can be integrated into CI to automatically monitor rule adherence and catch regressions before merge.

**Benefits**:
- Automated compliance checks on every PR
- Trend tracking over time
- Early detection of rule violations
- Objective metrics for rule effectiveness

---

## Quick Start

### GitHub Actions Example

Create `.github/workflows/compliance-check.yml`:

```yaml
name: Compliance Check

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * 0' # Weekly on Sunday

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 100 # Need history for analysis

      - name: Run Compliance Dashboard
        run: |
          bash .cursor/scripts/compliance-dashboard.sh --limit 25 > compliance-report.txt
          cat compliance-report.txt

      - name: Parse Compliance Score
        id: parse
        run: |
          SCORE=$(grep "Overall Score:" compliance-report.txt | grep -oE '[0-9]+%' | head -1 | tr -d '%')
          echo "score=$SCORE" >> $GITHUB_OUTPUT
          
      - name: Check Threshold
        run: |
          SCORE=${{ steps.parse.outputs.score }}
          if [ "$SCORE" -lt 75 ]; then
            echo "❌ Compliance score $SCORE% is below threshold (75%)"
            exit 1
          else
            echo "✅ Compliance score $SCORE% meets threshold"
          fi

      - name: Upload Report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: compliance-report
          path: compliance-report.txt
```

---

## Configuration

### Recommended Thresholds

Start conservative and tighten over time:

**Phase 1 (Baseline)**: Warning only, no failures
- Overall: >60% (warn)
- Track trend, no blocks

**Phase 2 (Enforcement)**: Block PRs below baseline
- Overall: >68% (fail)
- Script usage: >70% (fail)
- TDD compliance: >70% (fail)
- Branch naming: >60% (fail)

**Phase 3 (Target)**: Approach target compliance
- Overall: >85% (fail)
- Script usage: >90% (fail)
- TDD compliance: >90% (fail)
- Branch naming: >85% (fail)

**Phase 4 (Excellence)**: Meet all targets
- Overall: >90% (fail)
- Script usage: >95% (fail)
- TDD compliance: >95% (fail)
- Branch naming: >90% (fail)

### Sample Size Considerations

- **Minimum commits**: 25 for statistical relevance
- **Branch check**: Use all branches (no limit)
- **TDD check**: May have low sample size; consider separate threshold

---

## Integration Patterns

### Pattern 1: PR Blocking (Strict)

**Use Case**: Enforce compliance immediately

```yaml
- name: Compliance Gate
  run: |
    bash .cursor/scripts/compliance-dashboard.sh --limit 25
    # Script exits 1 if below threshold
```

**Pros**: Immediate enforcement  
**Cons**: May block legitimate PRs during transition

---

### Pattern 2: Warning Only (Advisory)

**Use Case**: Track metrics without blocking

```yaml
- name: Compliance Report
  continue-on-error: true
  run: |
    bash .cursor/scripts/compliance-dashboard.sh --limit 25
```

**Pros**: Non-disruptive  
**Cons**: Easy to ignore

---

### Pattern 3: Trend Analysis (Adaptive)

**Use Case**: Fail only if compliance decreases

```yaml
- name: Compare to Baseline
  run: |
    # Store previous score in artifact or DB
    # Compare current to previous
    # Fail if regression > 5 points
```

**Pros**: Prevents backsliding without blocking improvements  
**Cons**: More complex to implement

---

## Interpreting Results

### Exit Codes

All compliance scripts use consistent exit codes:

- `0`: Success (meets threshold or no failures)
- `1`: Failure (below threshold or errors)
- `2`: Usage error (invalid arguments)

### Output Format

Dashboard outputs structured text:

```
=== Compliance Dashboard ===

Script Usage:    71% (target: >90%)  ⚠️  BELOW TARGET
TDD Compliance:  72% (target: >95%)  ⚠️  BELOW TARGET  
Branch Naming:   62% (target: >90%)  ⚠️  BELOW TARGET
─────────────────────────────────────────────────────
Overall Score:   68% (target: >90%)  ⚠️  BELOW TARGET
```

### Parsing Metrics

Extract individual scores:

```bash
# Script usage
SCRIPT_USAGE=$(grep "Script Usage:" report.txt | grep -oE '[0-9]+%' | tr -d '%')

# TDD compliance  
TDD_COMPLIANCE=$(grep "TDD Compliance:" report.txt | grep -oE '[0-9]+%' | tr -d '%')

# Branch naming
BRANCH_NAMING=$(grep "Branch Naming:" report.txt | grep -oE '[0-9]+%' | tr -d '%')

# Overall
OVERALL=$(grep "Overall Score:" report.txt | grep -oE '[0-9]+%' | tr -d '%')
```

---

## Troubleshooting

### Issue: Low Sample Size

**Symptom**: TDD compliance shows "0 of 0" or "1 of 1"

**Cause**: Not enough implementation commits in sample

**Solution**:
- Increase `--limit` to 50 or 100
- Consider separate threshold for TDD (lower bar when sample is small)
- Track trend over time instead of single PR

### Issue: Old Branches Skew Metrics

**Symptom**: Branch naming compliance consistently low despite following convention

**Cause**: Many old branches from before naming convention

**Solution**:
- Clean up stale branches: `git branch -r | grep -v main | xargs git push origin --delete`
- Or exclude old branches: modify `check-branch-names.sh` to filter by date

### Issue: CI Fails on First Run

**Symptom**: Compliance check fails immediately after integration

**Cause**: Baseline may be below initial threshold

**Solution**:
- Start with warning-only mode (Phase 1)
- Set threshold at or below current baseline (68%)
- Ratchet threshold up over time

---

## Monitoring & Alerts

### Store Historical Data

Track compliance over time:

```yaml
- name: Store Compliance History
  run: |
    DATE=$(date +%Y-%m-%d)
    bash .cursor/scripts/compliance-dashboard.sh --limit 100 > "compliance-$DATE.txt"
    # Upload to storage or commit to repo
```

### Slack/Discord Notifications

Alert on compliance changes:

```yaml
- name: Notify on Regression
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Compliance check failed on PR #${{ github.event.pull_request.number }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Dashboard Visualization

Options:
- GitHub Pages: publish compliance reports as static site
- Grafana: store metrics in time-series DB
- Custom: parse reports and generate charts

---

## Maintenance

### Updating Thresholds

As compliance improves, update thresholds in workflow:

```yaml
env:
  MIN_OVERALL: 75  # Increase from 68
  MIN_SCRIPT: 80   # Increase from 71
  MIN_TDD: 80      # Increase from 72
  MIN_BRANCH: 70   # Increase from 62
```

### Validating Changes

Before updating thresholds:
1. Run dashboard locally: `bash .cursor/scripts/compliance-dashboard.sh --limit 100`
2. Check current scores
3. Set thresholds 2-5 points above current (stretch goal)
4. Monitor for 2-3 weeks
5. Adjust if too strict or too lenient

### Script Updates

When compliance scripts change:
- Test locally first
- Run in CI with `continue-on-error: true` initially
- Validate output format unchanged
- Update threshold logic if needed

---

## Examples from This Project

### Current Baseline (2025-10-15)

```
Script Usage:    71%
TDD Compliance:  72%
Branch Naming:   62%
Overall Score:   68%
```

### Post-Fix Target (3 months)

```
Script Usage:    >95% (git-usage fix applied)
TDD Compliance:  >90% (need to investigate gap)
Branch Naming:   >85% (need pre-push hook)
Overall Score:   >90%
```

---

## Related

- [BASELINE-REPORT.md](./BASELINE-REPORT.md) — Initial measurements
- [tasks.md](./tasks.md) — Monitoring plan (item 12.0)
- [compliance-dashboard.sh](../../../.cursor/scripts/compliance-dashboard.sh) — Main script
- [check-script-usage.sh](../../../.cursor/scripts/check-script-usage.sh) — Individual checker
- [check-tdd-compliance.sh](../../../.cursor/scripts/check-tdd-compliance.sh) — Individual checker
- [check-branch-names.sh](../../../.cursor/scripts/check-branch-names.sh) — Individual checker

---

**Status**: Ready for integration  
**Recommended Approach**: Start with Phase 1 (warning only), progress to Phase 2 (enforcement) after 2-4 weeks  
**Support**: See test files (`.test.sh`) for script behavior and edge cases

