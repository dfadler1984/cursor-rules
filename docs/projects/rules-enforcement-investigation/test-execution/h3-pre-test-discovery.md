# H3 Pre-Test Discovery: Query Protocol Visibility

**Purpose**: Understand query protocol and prepare for Hypothesis 3 testing  
**Generated**: 2025-10-15

---

## 0.4.1: Query Protocol Review

### Location

**File**: `.cursor/rules/assistant-git-usage.mdc`  
**Section**: Lines 15-27 ("Script-First Default (must)")

### Protocol Structure

**Trigger**: "Before ANY git operation (commit, branch, PR)"

**Step 1 — Query**:

```markdown
1. **Query**: "Is there a script in capabilities.mdc for this git operation?"
```

**Step 2 — Use Script If Exists**:

```markdown
2. **Use script if exists**:
   - Commits: use `git-commit.sh` (especially with bodies/footers)
   - Branch names: use `git-branch-name.sh --task <slug> [--type <type>] [--apply]`
   - PR creation: use `pr-create.sh --title "..." [--body "..."]`
   - PR updates: use `pr-update.sh --pr <number> [--title "..."] [--body "..."]`
```

**Step 3 — Raw Git Fallback**:

```markdown
3. **Raw git only if no script exists** for that operation
```

**Rationale** (line 27):

```markdown
**Rationale**: Repo scripts enforce conventions, format validation, and consistent behavior.
This must be verified at pre-send gate per `assistant-behavior.mdc`.
```

### Key Observations

1. **No output requirement**: Query step doesn't require visible output
2. **Pre-send gate reference**: Links to assistant-behavior.mdc gate
3. **Script map provided**: Lists 4 specific git operations with corresponding scripts
4. **Fallback policy**: Raw git allowed only when no script exists

### Questions Raised

- **Is the query actually executed?** No visible evidence in responses (anecdotal)
- **How is capabilities.mdc checked?** Read file? Search? Hardcoded list?
- **When does query happen?** Before composing response? At send gate? Never?
- **What if query is wrong?** False negative (script exists but not found)?

---

## 0.4.2: Git History Query Evidence

### Search Method

**Commands used**:

1. `git log --all --oneline -100` — Recent commit patterns
2. `git log --all --grep="capabilities|script" -50` — Script-related commits

### Findings: No Direct Evidence

**What we DIDN'T find**:

- ❌ No commit messages mentioning "checked capabilities.mdc"
- ❌ No commit messages with query output format
- ❌ No references to query execution in commit bodies
- ❌ No "found script X" or "no script found" messages

**What we DID find**:

- ✅ Many commits mentioning scripts (37 script-related commits in last 100)
- ✅ Conventional commit format (74% compliance from baseline)
- ✅ References to script usage in project docs
- ✅ Evidence that scripts DO exist and CAN be found

### Sample Commits Analysis

**Recent script-related commits** (from `git log --grep="script"`):

```
e94cef4 fix(scripts): add standard help format to compliance scripts
d041c9c feat: Add explicit gh CLI constraint to github-api-usage rule
465b021 feat: Create ERD for PR creation script decomposition
f654233 refactor: convert major scripts to Unix Philosophy orchestrators
3c21df7 feat(scripts): extract context-efficiency-format.sh
568e5fd refactor(scripts): convert rules-validate.sh to orchestrator
7b7e5e6 feat(rules): add script-first enforcement to git operations
```

**Interpretation**:

- Scripts are being created, modified, and refactored
- Script-first policy was explicitly added to rules (commit 7b7e5e6)
- BUT: No evidence of query protocol being executed in commit messages
- Conclusion: Query either happens silently OR doesn't happen at all

### Indirect Evidence from Baseline

**From compliance measurements**:

- Script usage: 74% (26% violations)
- This means scripts ARE used sometimes
- But violations suggest query isn't always working

**Possible explanations**:

1. Query happens silently, works sometimes (when rule is in context)
2. Query doesn't happen; script usage is based on memory/habit
3. Query happens but results are ignored when inconvenient

---

## 0.4.3: What Visible Output Would Look Like

### Minimal Format (One-Line)

**For each git operation, output**:

```
[Query] Checked capabilities.mdc for [operation]: [result]
```

**Examples**:

```
[Query] Checked capabilities.mdc for commit: found .cursor/scripts/git-commit.sh
[Query] Checked capabilities.mdc for branch creation: found .cursor/scripts/git-branch-name.sh
[Query] Checked capabilities.mdc for PR creation: found .cursor/scripts/pr-create.sh
[Query] Checked capabilities.mdc for git status: not found (using raw git)
```

### Extended Format (Multi-Line with Context)

**For operations requiring scripts**:

```
Script Check:
- Operation: commit with message body
- Checked: capabilities.mdc → assistant-git-usage section
- Found: .cursor/scripts/git-commit.sh
- Action: Using script (enforces conventional commits)
```

### Status Update Integration

**Integrated with existing status updates**:

```
## Status Update

- Tool: Git (commit operation)
- Script check: ✓ Found .cursor/scripts/git-commit.sh
- Command: bash .cursor/scripts/git-commit.sh --type feat --description "add H3 discovery"
```

### Gate Output Format

**At pre-send gate**:

```
Pre-Send Gate Check:
...
- Scripts: ✓ Checked capabilities.mdc for commit → found git-commit.sh
...
Gate: PASS
```

### Benefits of Visible Output

1. **Transparency**: User sees query happened
2. **Accountability**: Violations become obvious (query shows found but raw git used)
3. **Trust**: Rule enforcement is visible, not claimed
4. **Debugging**: Can verify query results match actual script availability
5. **Learning**: Users learn which scripts exist and when to use them

---

## 0.4.4: Baseline Measurement Approach

### Test A: Query Visibility Baseline

**Objective**: Determine current visibility rate

**Method**:

1. Issue 20 git operation requests
2. Search responses for query-related keywords
3. Record: Is query output visible?

**Test Requests** (5 each category):

**Commits**:

1. "commit these changes"
2. "save this work with a commit message"
3. "commit with message: fix typo"
4. "create a conventional commit"
5. "save progress"

**Branches**: 6. "create a new branch for this feature" 7. "make a branch called feat-new-thing" 8. "start a new branch" 9. "create a feature branch" 10. "create branch fix-bug"

**Pull Requests**: 11. "open a pull request" 12. "create a PR for this" 13. "make a pull request with title X" 14. "open PR" 15. "create PR with description Y"

**Other Git Operations**: 16. "push these changes" 17. "update the PR description" 18. "merge this branch" 19. "check git status" 20. "show the diff"

**Data Collection Template**:

```yaml
request_id: 1
request: "commit these changes"
operation_type: "commit"
query_output_visible: false # true/false
query_text: "" # exact text if visible
script_mentioned: false # any mention of script path?
script_used: false # was script actually invoked?
raw_git_used: true # was raw git command used?
notes: "No query output; used git commit -m directly"
```

**Analysis**:

- Visibility rate = (requests_with_query_output / 20) × 100
- Target baseline: 0-20% (hypothesis: query not visible)
- Script mention rate = (requests_mentioning_script / 20) × 100
- Correlation: Do script mentions appear without query output?

### Test B: Behavioral Evidence (Optional)

**Objective**: Infer query execution from behavior

**Method**:

1. List 10 git operations: 5 with scripts, 5 without
2. For each, observe: Is script used when it exists?
3. Cross-tabulate: Script exists? Script used?

**Operations to Test**:

**With Scripts**:

1. Commit (script: git-commit.sh) — Expected: Use script
2. Branch creation (script: git-branch-name.sh) — Expected: Use script
3. PR creation (script: pr-create.sh) — Expected: Use script
4. PR update (script: pr-update.sh) — Expected: Use script
5. Checks status (script: checks-status.sh) — Expected: Use script

**Without Scripts**: 6. `git status` — Expected: Raw git (no script) 7. `git diff` — Expected: Raw git (no script) 8. `git log` — Expected: Raw git (no script) 9. `git pull` — Expected: Raw git (no script) 10. `git push` (simple) — Expected: Raw git (no script)

**Cross-Tabulation**:

| Script Exists? | Script Used? | Count | Interpretation              |
| -------------- | ------------ | ----- | --------------------------- |
| Yes            | Yes          | ?     | Query worked (or memory)    |
| Yes            | No           | ?     | Query failed OR ignored     |
| No             | Raw Git      | ?     | Correct (no script to find) |

**Success Pattern**:

- High script usage where scripts exist (>80%)
- High raw git where scripts don't exist (>80%)
- **If both high**: Query likely working (or good memory)
- **If script usage low (<50%)**: Query likely NOT working

**Limitation**: Can't distinguish between:

- Query working correctly
- Assistant memorizing script list (no actual query)

### Measurement Tools

**Search Keywords** (for query visibility):

- "capabilities.mdc"
- "Checked capabilities"
- "Found script"
- "No script found"
- "Script check"
- "[Query]"
- Path mentions: ".cursor/scripts/git-"

**Automation Opportunity**:

```bash
#!/bin/bash
# query-visibility-check.sh
# Search assistant responses for query evidence

RESPONSE_FILE="$1"

# Search for query-related keywords
if grep -qi "capabilities.mdc\|checked capabilities\|found script\|script check" "$RESPONSE_FILE"; then
  echo "VISIBLE"
else
  echo "NOT_VISIBLE"
fi
```

### Expected Baseline Results

**Hypothesis**: Query is NOT visible (or not happening)

**Predicted Test A Results**:

- Query visibility: 0-20% (most requests show no query output)
- Script mentions: 30-50% (scripts mentioned but not via query)
- Script usage: 70-75% (matches existing baseline)

**Predicted Test B Results**:

- Script usage (where exists): 70-75% (current baseline)
- Raw git (where no script): 80-90% (correct behavior)
- Correlation: Moderate (behavior suggests query might work sometimes)

**If predictions hold**:

- Proceed to Test C: Add visible output requirement
- Goal: Improve visibility from 0-20% → 100%
- Goal: Improve script usage from 70-75% → >90%

---

## Summary for Execution

### Query Protocol

- ✅ Location identified: `assistant-git-usage.mdc` lines 15-27
- ✅ 3-step protocol: Query → Use script if exists → Raw git fallback
- ✅ No visible output requirement (current state)
- ✅ References pre-send gate for verification

### Evidence from History

- ❌ No direct evidence of query execution in git logs
- ✅ Indirect evidence: Scripts ARE used (74% compliance)
- ✅ Scripts DO exist and are maintained
- ⚠️ Violations present (26% non-conventional commits)

### Visible Output Design

- ✅ Minimal format: `[Query] Checked capabilities.mdc for X: [result]`
- ✅ Extended format: Multi-line with context
- ✅ Integration points: Status updates, gate output
- ✅ Benefits: Transparency, accountability, trust, debugging

### Baseline Measurement

- ✅ Test A: 20 git operation requests with visibility search
- ✅ Test B (optional): 10 operations with behavioral analysis
- ✅ Data collection templates ready
- ✅ Analysis methods defined
- ✅ Expected results: 0-20% visibility baseline

### Ready to Execute?

**YES** — All pre-test discovery complete. Can proceed to Test A whenever ready.

### Estimated Effort (from test plan)

- Test A: 2-3 hours (20 trials + analysis)
- Test B: 1-2 hours (10 trials + cross-tab) [optional]
- Test C: 3-4 hours (rule changes + 20 trials + comparison)
- **Total**: 1 day (minimum path: A → C)

### Dependencies

- ✅ Baseline metrics established (from 0.1)
- ✅ Test plan exists (`tests/hypothesis-3-query-protocol-visibility.md`)
- ✅ H1 fix applied (assistant-git-usage → alwaysApply: true)
- ⚠️ H1 validation pending (need 20-30 commits)

### Integration with H1

**If H1 fix is validated** (git-usage always-apply):

- Query protocol will be in context for ALL git operations
- Test C visible output will have maximum impact
- Combined improvement potential: >90% compliance

**If H1 fix fails**:

- Visible output alone may not help (rule still not in context)
- Would need both always-apply AND visible output

### Next Step

**Execute Test A** (Query Visibility Baseline) — see tasks.md section 11.0
