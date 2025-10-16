# Slash Commands Phase 3 Testing Protocol

**Date Started**: 2025-10-16  
**Status**: READY TO EXECUTE  
**Test Plan Reference**: `tests/experiment-slash-commands.md`

---

## Test Environment

**Branch**: `dfadler1984/feat-slash-commands-experiment`  
**Rules Applied**:
- ✅ `git-slash-commands.mdc` (alwaysApply: true)
- ✅ `intent-routing.mdc` updated with slash command routing

**Prerequisites**:
- Restart Cursor to load new rules
- Confirm rules loaded: rules should be visible in context

---

## Phase 1: Baseline (Reuse H1 Data)

**Baseline Metrics** (from H1 validation):
- Script usage: 74% (intent routing)
- Data source: Last 100 commits before H1 fix
- Routing pattern: Keyword-based intent detection

**No additional Phase 1 trials needed** - existing data is sufficient baseline.

---

## Phase 3: Test Scenarios (50 Trials Total)

### Scenario A: Direct Slash Command Use (10 trials)

**Input format**: User provides slash command directly

**Test inputs**:
1. `/commit`
2. `/commit` (variant: after making changes)
3. `/pr`
4. `/pr` (variant: with explicit title in mind)
5. `/branch`
6. `/branch` (variant: with task name ready)
7. `/pr-update`
8. `/commit` (variant: amend scenario)
9. `/pr` (variant: draft PR)
10. `/branch` (variant: switching context)

**Expected behavior**:
- Immediate route to appropriate script
- No prompt needed
- Script executes with interactive prompts for arguments
- 100% script usage expected

**Data to record**:
```yaml
trial_id: A1
input: "/commit"
slash_used: true
prompt_shown: false
script_executed: true
script_name: "git-commit.sh"
routing_confusion: false
notes: ""
```

---

### Scenario B: Request Without Slash Command (10 trials)

**Input format**: Natural language request (should trigger prompt)

**Test inputs**:
1. "commit these changes"
2. "create a pull request"
3. "make a new branch"
4. "update the PR"
5. "commit this work"
6. "open a PR for this"
7. "create a branch for this feature"
8. "update pull request #123"
9. "commit the staged files"
10. "make a PR with these changes"

**Expected behavior**:
- Detect git operation intent
- Show prompt offering slash command or manual
- Wait for user choice
- If slash chosen → execute script
- If manual chosen → fall back to capabilities.mdc check

**Data to record**:
```yaml
trial_id: B1
input: "commit these changes"
slash_used: false
prompt_shown: true
prompt_format_correct: true  # Contains /commit, /pr, etc options
user_choice: "slash|manual|unclear"
script_executed: true|false
script_name: "git-commit.sh|none"
routing_confusion: false
notes: ""
```

---

### Scenario C: Indirect/Ambiguous Requests (10 trials)

**Input format**: Requests that don't use git keywords

**Test inputs**:
1. "save this work"
2. "record these changes"
3. "push this upstream"
4. "update my changes remotely"
5. "make a new working area"
6. "checkpoint current state"
7. "share this with the team"
8. "fix the last checkpoint"
9. "create a workspace for feature X"
10. "publish these changes"

**Expected behavior**:
- Intent detection should still work
- Show prompt if operation detected
- May have some misses (lower detection rate acceptable)

**Data to record**:
```yaml
trial_id: C1
input: "save this work"
intent_detected: true|false
prompt_shown: true|false
user_choice: "slash|manual|N/A"
script_executed: true|false
notes: "what operation was inferred, if any"
```

---

### Scenario D: Prompt Response Testing (10 trials)

**Input format**: Request → prompt shown → test both choices

**Test inputs**:
1. "commit changes" → choose slash
2. "commit changes" → choose manual
3. "create PR" → choose slash
4. "create PR" → choose manual
5. "new branch" → choose slash
6. "new branch" → choose manual
7. "update PR" → choose slash
8. "update PR" → choose manual
9. "commit work" → choose slash
10. "make PR" → choose manual

**Expected behavior**:
- Slash choice → immediate script execution
- Manual choice → fallback to capabilities.mdc query → script usage

**Data to record**:
```yaml
trial_id: D1
input: "commit changes"
prompt_shown: true
user_choice: "slash"
script_executed: true
fallback_path: "N/A|capabilities.mdc"
notes: ""
```

---

### Scenario E: Edge Cases (10 trials)

**Input format**: Unusual patterns, typos, mixed commands

**Test inputs**:
1. "commit" (single word)
2. "/comit" (typo in slash command)
3. "commit and push"
4. "/commit /pr" (multiple slash commands)
5. "git commit -m 'message'" (raw git command)
6. "/commit --type feat" (slash with args)
7. "I want to commit"
8. "/commit please"
9. "can you commit this?"
10. "commit?" (question form)

**Expected behavior**:
- Test robustness of detection and routing
- Document unexpected behaviors

**Data to record**:
```yaml
trial_id: E1
input: "commit"
behavior: "describe what happened"
expected: "describe what should happen"
actual: "describe actual outcome"
notes: ""
```

---

## Data Collection Template

Create file: `slash-commands-phase3-results.csv`

```csv
trial_id,scenario,input,slash_used,prompt_shown,user_choice,script_executed,script_name,routing_confusion,notes
A1,direct,"/commit",true,false,N/A,true,git-commit.sh,false,""
A2,direct,"/commit",true,false,N/A,true,git-commit.sh,false,""
...
```

Or use YAML format: `slash-commands-phase3-results.yaml`

```yaml
trials:
  - id: A1
    scenario: direct
    input: "/commit"
    slash_used: true
    prompt_shown: false
    user_choice: N/A
    script_executed: true
    script_name: "git-commit.sh"
    routing_confusion: false
    notes: ""
```

---

## Analysis Protocol (Phase 4)

After completing 50 trials:

### Calculate Metrics

```bash
# Script usage rate
script_usage_rate=$(grep "script_executed: true" results.yaml | wc -l)
total_trials=50
echo "Script usage: $(( script_usage_rate * 100 / total_trials ))%"

# Routing accuracy (prompt shown when expected)
routing_accuracy=$(grep "prompt_shown: true" results.yaml | wc -l)
expected_prompts=40  # Scenarios B, C, D, E
echo "Routing accuracy: $(( routing_accuracy * 100 / expected_prompts ))%"

# Slash adoption after prompt
slash_chosen=$(grep "user_choice: slash" results.yaml | wc -l)
total_prompts=$(grep "prompt_shown: true" results.yaml | wc -l)
echo "Slash adoption: $(( slash_chosen * 100 / total_prompts ))%"
```

### Comparison Table

| Metric | Baseline (H1) | Slash Commands | Improvement |
|--------|---------------|----------------|-------------|
| Script usage | 74% | [CALCULATE] | [DELTA] |
| Routing accuracy | ~70% | [CALCULATE] | [DELTA] |
| Prompt clarity | N/A | [MEASURE] | N/A |
| User adoption | N/A | [MEASURE] | N/A |

### Success Criteria

- ✅ Script usage >90% (+16 points over baseline)
- ✅ Routing accuracy >95% (+25 points)
- ✅ Prompt clarity >80% (user understands options)
- ✅ Slash adoption >60% (users choose slash after seeing prompt)

### Qualitative Analysis

Document:
1. **Routing misses**: Which inputs failed to detect git operations?
2. **Prompt issues**: Was prompt clear? Any confusion?
3. **User experience**: Did slash commands feel natural or intrusive?
4. **False positives**: Were non-git operations misdetected?
5. **Edge cases**: Unexpected behaviors worth noting

---

## Execution Modes

### Mode 1: Interactive Testing (Manual)

1. Restart Cursor
2. For each scenario, issue the test input
3. Record assistant response
4. Note whether script executed
5. Log data in results file

**Pros**: Direct observation, full context  
**Cons**: Time-intensive (3-4 hours)

### Mode 2: PR-Based Testing (Semi-Automated)

1. Push branch and create PR
2. Work normally, noting when git operations occur
3. Track which path was taken (slash vs prompt vs fallback)
4. Accumulate 50 data points over several days

**Pros**: Natural usage, realistic data  
**Cons**: Longer timeline, may not hit all scenarios evenly

### Mode 3: Hybrid Approach

1. Push branch and restart Cursor
2. Execute structured scenarios A-E in rapid succession
3. Take notes during execution
4. Fill in results file immediately after each trial

**Pros**: Structured + efficient  
**Cons**: Requires focus and note-taking discipline

---

## Decision Point

After Phase 3 completion, analyze results and decide:

**If script usage >90% AND routing accuracy >95%**:
- ✅ Slash commands confirmed as stronger forcing function
- Recommend: Keep for high-risk operations
- Document: Add to capabilities, update git-usage guidance

**If script usage 80-90% OR routing accuracy 85-95%**:
- ⚠️ Partial success
- Investigate: What caused misses?
- Refine: Adjust detection or prompt wording
- Re-test: 20 additional trials focusing on problem areas

**If script usage <80% OR routing accuracy <85%**:
- ❌ Not significantly better than baseline
- Investigate: Why didn't slash commands help?
- Consider: Is prompt being followed? Is detection working?
- Alternative: May need different approach

---

## Next Steps After Testing

1. Document findings in `slash-commands-phase3-results.md`
2. Update `slash-commands-decision.md` with empirical data
3. Create comparison report (Phase 4)
4. Update `tasks.md` Phase 6C with results
5. Synthesize into decision tree (task 13.2)
6. Determine rollout plan or revert decision

---

**Status**: Ready to execute  
**Estimated time**: 3-4 hours (interactive) or 3-5 days (PR-based)  
**Output**: 50 data points + qualitative analysis

