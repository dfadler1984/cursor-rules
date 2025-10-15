# Test Plan: Hypothesis 3 — Query Protocol Needs Visible Execution

**Hypothesis**: The query step stated in `assistant-git-usage.mdc` ("Is there a script in capabilities.mdc for this operation?") is not actually executed, OR it's executed silently without visible output.

**Related Discovery Section**: Part 4 → Hypothesis 3

---

## Background

**Current State**:

- `assistant-git-usage.mdc` line 19 states: **Query**: "Is there a script in capabilities.mdc for this operation?"
- This is step 1 of the Script-First Default protocol
- No visible output requirement in the rule
- **No evidence in ERD** that this query actually happens

**Theory**:

- Query step is stated but not executed
- OR query happens silently (no output)
- Could be optimized away or skipped

---

## Test Design

### Test A: Baseline Query Visibility

**Objective**: Determine if query results are currently visible

**Method**: Issue git operations and search for query-related output

**Procedure**:

1. Issue 20 git operation requests:

   - 5× "commit these changes"
   - 5× "create a new branch"
   - 5× "open a pull request"
   - 5× "update the PR"

2. For each response, search for query evidence:
   - Explicit: "Checked capabilities.mdc"
   - Implicit: mentions of specific script paths
   - Status: "Found git-commit.sh" or "No script found"
   - Any reference to capabilities.mdc

**Measurement**:

```yaml
request_id: 1
request: "commit these changes"
query_output_visible: false # true/false
query_evidence: "none" # or exact quote
script_mentioned: true # .cursor/scripts/git-commit.sh mentioned
script_used: true # script was actually invoked
```

**Success Criteria**:

- If query visible ≥ 80%: Query IS happening and visible (low priority issue)
- If query visible < 20%: Query NOT visible or not happening (proceed to Test B)

---

### Test B: Query Execution Test (Black Box)

**Objective**: Determine if query is executed even if not visible

**Method**: Introduce scenarios where query result MUST inform behavior

**Procedure**:

1. **Scenario: Script exists**

   - Request: "commit these changes"
   - Expectation: Should use `git-commit.sh` (script exists)
   - If script used → query likely executed
   - If raw git used → query likely NOT executed OR ignored

2. **Scenario: Script doesn't exist** (for comparison)

   - Request: "run git status" (no wrapper script for this)
   - Expectation: Should use raw `git status` (no script)
   - If raw git used → correct (no script to find)

3. **Repeat** with 10 operations: 5 with scripts, 5 without

**Analysis**:

- Script usage rate (where script exists): X%
- Raw git rate (where no script exists): Y%
- **If X high (>80%) AND Y high (>80%)**: Query is working (finds scripts when present, allows raw when absent)
- **If X low (<50%)**: Query not working OR results ignored

**Limitation**: This is indirect evidence (behavior-based, not output-based)

---

### Test C: Add Visible Query Output Requirement

**Objective**: Test if requiring visible output improves compliance

**Setup Change 1** — Add to `assistant-git-usage.mdc`:

```markdown
## Script-First Default (must)

Before ANY git operation, explicitly check `capabilities.mdc`:

1. **Query**: "Is there a script in capabilities.mdc for this operation?"
2. **OUTPUT result**: "Checked capabilities.mdc for [operation]: [found <path> | not found]"
3. **Use script if exists**:
   - Commits: use `git-commit.sh`
   - Branch names: use `git-branch-name.sh`
   - PR creation: use `pr-create.sh`
4. **Raw git only if** query shows "not found"
```

**Setup Change 2** — Add to `assistant-behavior.mdc` send gate:

```markdown
- Scripts (MUST SHOW): before git/terminal commands, OUTPUT:
  - Format: "Checked capabilities.mdc for [operation]: [result]"
  - Example: "Checked capabilities.mdc for commit: found .cursor/scripts/git-commit.sh"
```

**Test Procedure**:

1. Apply both changes
2. Restart Cursor to reload rules
3. Run 20 git operations (same as Test A)
4. For each response:
   - Check: Is query output visible?
   - Check: Is query result correct? (matches actual script availability)
   - Check: Is behavior consistent with result? (uses script if found)

**Measurement**:

```yaml
request_id: 1
request: "commit these changes"
query_visible: true # is "Checked capabilities.mdc" output present?
query_result: "found .cursor/scripts/git-commit.sh" # exact output
result_correct: true # does script actually exist?
behavior_consistent: true # was script used?
```

**Success Criteria**:

- Query visibility: 100% (if rule is followed)
- Query accuracy: >95% (correct script detection)
- Behavior consistency: >90% (uses script when found)

---

### Test D: Query Timing Test

**Objective**: Verify query happens BEFORE command execution

**Method**: Add timestamps to query output

**Setup Change** — Modify query output format:

```markdown
2. **OUTPUT result with timestamp**:
   "[HH:MM:SS] Checked capabilities.mdc for [operation]: [result]"
```

**Test Procedure**:

1. Issue git operation
2. Record timestamp of query output
3. Record timestamp of command execution
4. Verify: query timestamp < command timestamp

**Success Criteria**:

- 100% of operations: query before command
- If query after command: Rule is not being followed correctly

---

## Measurement Protocol

### Test A: Query Visibility Baseline

**Data Collection**:

```csv
request_id,operation,query_visible,query_text,script_mentioned,script_used
1,"commit","no","","yes","yes"
2,"branch","no","","no","no"
```

**Analysis**:

- Visibility rate = (query_visible_count / total) \* 100
- Script mention rate = (script_mentioned_count / total) \* 100
- Correlation: Are scripts mentioned even when query not visible?

---

### Test B: Behavioral Evidence

**Data Collection**:

```csv
operation_id,operation,script_exists,script_used,inference
1,"commit","yes","yes","query likely worked"
2,"branch","yes","no","query likely failed OR ignored"
3,"status","no","raw_git","correct (no script)"
```

**Analysis**:

- Accuracy rate = (correct_behavior / total) \* 100
- Where script exists: script_usage_rate
- Where script absent: raw_git_usage_rate
- **Cross-tabulation**:

| Script Exists? | Script Used? | Count | Interpretation               |
| -------------- | ------------ | ----- | ---------------------------- |
| Yes            | Yes          | X     | Query worked                 |
| Yes            | No           | Y     | Query failed or ignored      |
| No             | Yes          | 0     | Error (script doesn't exist) |
| No             | No (raw git) | Z     | Correct behavior             |

---

### Test C: Post-Change Effectiveness

**Comparison Table**:

| Metric                      | Baseline (Test A) | Post-Change (Test C) | Improvement |
| --------------------------- | ----------------- | -------------------- | ----------- |
| Query visibility            | ~0-20%            | Target: 100%         | +80-100 pts |
| Script usage (where exists) | ~60-70%           | Target: >90%         | +20-30 pts  |
| Behavior consistency        | Unknown           | Target: >90%         | N/A         |

**Success Definition**:

- All metrics hit targets
- **AND** user feedback: "I can see the query happening" (transparency)

---

## Expected Outcomes

### Scenario 1: Query Not Happening

**Test A**: No query output (0%)  
**Test B**: Random script usage pattern (no correlation with script existence)

**Conclusion**: Query step is not being executed

**Implication**: Rule text describes desired behavior but doesn't enforce it

**Next Step**: Visible output requirement (Test C) will force execution

---

### Scenario 2: Query Happening Silently

**Test A**: No query output (0%)  
**Test B**: High script usage where scripts exist (>80%)

**Conclusion**: Query is executed but silently

**Implication**: Rule is being followed but lacks transparency

**Next Step**: Visible output requirement (Test C) will add transparency

---

### Scenario 3: Query Sometimes Visible

**Test A**: Query visible 20-50%  
**Test B**: Script usage correlates with visibility

**Conclusion**: Query happens when rule is in context/triggered correctly

**Implication**: Conditional attachment issue (Hypothesis 1)

**Next Step**: Combine always-apply (H1) + visible output (H3)

---

### Scenario 4: Visible Output Works

**Test A**: Baseline ~0-20%  
**Test C**: Post-change 100%

**Conclusion**: Visible output requirement works

**Implication**: Rules need explicit output requirements to ensure execution

**Next Step**: Roll out visible output to other verification steps

---

## Success Criteria Summary

### Primary Success

**Test C Results**:

- Query visibility: 100%
- Query accuracy: >95%
- Behavior consistency: >90%
- **AND**: Improvement over baseline ≥80 percentage points

### Secondary Success

**User Experience**:

- Transparency: Users can verify query happened
- Accountability: Violations are obvious (query shows but behavior doesn't match)
- Trust: Users see rule enforcement in action

### Failure Conditions

**Test C fails if**:

- Query visibility <80%: Rule not being followed
- Query accuracy <80%: Implementation bug (wrong script detection)
- Behavior inconsistency >20%: Query results ignored

---

## Implementation Checklist

### Test A: Baseline

- [ ] Create 20 test requests (git operations)
- [ ] Run each request, capture full response
- [ ] Search for query-related keywords: "capabilities", "checked", "found", script paths
- [ ] Log visibility data to CSV
- [ ] Calculate visibility rate
- [ ] Decision: If < 20%, proceed to Test C

### Test B: Behavioral Evidence (Optional)

- [ ] Identify 10 operations: 5 with scripts, 5 without
- [ ] Run each operation
- [ ] Record: script exists? script used?
- [ ] Cross-tabulate results
- [ ] Calculate correlation between existence and usage
- [ ] Decision: If correlation weak, query likely not working

### Test C: Add Visible Output

- [ ] Backup `assistant-git-usage.mdc` and `assistant-behavior.mdc`
- [ ] Apply Setup Change 1 (git-usage rule)
- [ ] Apply Setup Change 2 (send gate)
- [ ] Restart Cursor
- [ ] Run 20 new test requests
- [ ] For each response:
  - [ ] Check: query output visible?
  - [ ] Check: query result accurate?
  - [ ] Check: behavior consistent?
- [ ] Log all data to CSV
- [ ] Calculate post-change metrics
- [ ] Compare to baseline (Test A)
- [ ] Decision: Keep change if success criteria met

### Test D: Timing Verification (Optional)

- [ ] Add timestamp to query output
- [ ] Run 5 test operations
- [ ] Verify: query timestamp < command timestamp in all cases
- [ ] Document any timing violations

---

## Timeline

- **Test A**: 2-3 hours (20 trials + analysis)
- **Test B**: 1-2 hours (10 trials + cross-tabulation) [optional]
- **Test C**: 3-4 hours (rule changes + 20 trials + comparison)
- **Test D**: 30 minutes (5 trials + timing check) [optional]
- **Total**: 1 day (minimum path: A → C)

---

## Risk Mitigation

**Risk**: Visible output creates noise in responses  
**Mitigation**: Use concise format (one line); survey users for feedback

**Risk**: Query output clutters context in long sessions  
**Mitigation**: Consider collapsible sections or summary format

**Risk**: Query is too slow (latency impact)  
**Mitigation**: Optimize capabilities.mdc lookup; cache results if safe

**Risk**: False positives (query says "found" but script missing)  
**Mitigation**: Verify query implementation; test against actual file system

---

## Follow-Up Actions

### If Visible Output Works (Test C Success)

1. **Rollout to other query steps**:

   - TDD gate: "Checked for owner spec: [found/not found]"
   - Consent gate: "Checked for prior consent: [obtained/pending]"

2. **Standardize query output format**:

   ```
   [Query]: Checked [source] for [target]: [result]
   ```

3. **Add to rule authoring guidelines**:
   - All verification steps must have visible output
   - Use standard query format

### If Visible Output Doesn't Work (Test C Failure)

1. **Investigate rule loading**:

   - Is modified rule actually in context?
   - Check rule precedence/conflicts

2. **Test platform constraints**:

   - Can rules require output format?
   - Is output being stripped/filtered?

3. **Escalate**:
   - Is this a Cursor platform limitation?
   - Need external verification (logs, scripts)

### Integration with Other Hypotheses

**If H1 (always-apply) is confirmed**:

- Combine: Always-apply + Visible output
- Test: Does combination achieve >95% compliance?

**If H2 (send gate) is non-blocking**:

- Visible output won't help if gate doesn't block
- Need platform-level enforcement

---

## Automation Opportunities

**Query output parsing** (semi-automated):

```bash
#!/bin/bash
# Extract query outputs from response logs
grep -E "Checked capabilities.mdc" responses.log | \
  awk -F: '{print $1, $2}' > query_results.csv
```

**Behavior consistency checker** (automated):

```bash
#!/bin/bash
# Check if script was used when found
while IFS=, read -r op query_result script_used; do
  if [[ "$query_result" =~ "found" ]] && [[ "$script_used" == "no" ]]; then
    echo "INCONSISTENT: $op"
  fi
done < test_results.csv
```

---

**Status**: Ready to execute  
**Owner**: rules-enforcement-investigation  
**Dependencies**: Test A depends on H1 results (for baseline context)  
**Estimated effort**: 1 day  
**Priority**: HIGH (core transparency mechanism)
