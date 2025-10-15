# Test Plan: Experiment — Slash Command Gating for Git Operations

**Hypothesis**: Requiring slash commands for git operations creates a stronger forcing function than intent routing, eliminating keyword ambiguity and routing misses.

**Related Discovery Section**: Part 8 → Experiment 3, Part 5 → External Patterns (Taskmaster/Spec-kit)

---

## Background

**Current State**: Intent routing with keywords

- User: "commit these changes" → routing detects "commit" → attaches git-usage rule → (hopefully) uses script
- **Problems**: Keyword matching can miss ("save this work", "record changes"), routing is conditional

**Proposed State**: Slash command gating

- User: `/commit` → unambiguous invocation → directly routes to git-commit.sh
- **Advantages**: No keyword matching, explicit invocation, user-visible

**Inspiration**:

- Taskmaster: uses slash commands for task operations
- Spec-kit: uses `/spec`, `/plan`, `/analyze` with required arguments
- Discovery hypothesis: "Explicit commands create forcing functions that intent routing lacks"

---

## Test Design

### Phase 1: Baseline (Intent Routing)

**Objective**: Establish current performance of intent routing

**Method**: Same as Hypothesis 1 control group

**Test Scenarios** (10 trials each):

1. Direct with keyword: "commit these changes"
2. Indirect without keyword: "save this work"
3. Non-standard term: "record the current state"
4. Amend operation: "fix the last commit"
5. Push operation: "push this upstream"

**Measurement**:

```yaml
scenario: "commit these changes"
routing_triggered: true # was git-usage rule attached?
script_used: true # was git-commit.sh used?
user_prompted: false # was user asked to clarify?
```

**Expected Baseline**:

- Routing trigger rate: ~60-70%
- Script usage rate: ~60-70%
- Misses on indirect requests (scenarios 2, 3, 4)

---

### Phase 2: Slash Command Implementation

**Step 1: Create Slash Command Rule**

New file: `.cursor/rules/git-slash-commands.mdc`

```markdown
---
description: Mandatory slash commands for Git operations
alwaysApply: true
lastReviewed: 2025-10-15
healthScore:
  content: green
  usability: green
  maintenance: green
---

# Git Slash Commands (Mandatory)

## High-Risk Operations (Mandatory Commands)

Before executing ANY of these git operations, check if user provided slash command:

### Mandatory Commands

- `/commit` → Routes to `.cursor/scripts/git-commit.sh`
  - Prompts for: type, scope (optional), description
  - Generates conventional commit
- `/pr` → Routes to `.cursor/scripts/pr-create.sh`
  - Prompts for: title, body (optional)
  - Creates PR via GitHub API
- `/branch` → Routes to `.cursor/scripts/git-branch-name.sh`

  - Prompts for: task, type (optional), feature (optional)
  - Suggests or creates branch with naming convention

- `/pr-update` → Routes to `.cursor/scripts/pr-update.sh`
  - Prompts for: PR number or branch, changes to make
  - Updates existing PR

### Enforcement Protocol

When user requests a high-risk git operation WITHOUT slash command:

1. **Detect operation**: commit, PR, branch, push --force
2. **Prompt for slash command**:
```

Use `/<command>` for this operation:

- `/commit` for commits
- `/pr` for pull requests
- `/branch` for branch creation

Proceed with slash command, or manual?

```
3. **On "manual"**: Fall back to script-first protocol (query capabilities.mdc)
4. **On slash command**: Execute immediately (no additional routing)

### Medium-Risk Operations (Suggested Commands)

These operations have suggested slash commands but allow fallback:

- `/status` → `git status --porcelain=v1` (safe, read-only)
- `/diff` → `git diff --stat` (safe, read-only)
- `/log` → `git log --oneline -n 10` (safe, read-only)

**Enforcement**: Suggest command, but allow raw git without additional prompt

### Low-Risk Operations (No Slash Command)

Read-only operations can proceed without slash commands:
- `git status`, `git log`, `git diff`, `git show`, etc.

## Rationale

- **Unambiguous**: `/commit` can't be misinterpreted
- **Explicit**: User sees tool invocation happening
- **Discoverable**: Prompts teach users about available commands
- **Forcing function**: Can't be skipped by clever phrasing
```

**Step 2: Update Intent Routing**

Add to `.cursor/rules/intent-routing.mdc`:

```markdown
## Slash commands

- `/commit` → route to `git-slash-commands.mdc` → execute `git-commit.sh`
- `/pr` → route to `git-slash-commands.mdc` → execute `pr-create.sh`
- `/branch` → route to `git-slash-commands.mdc` → execute `git-branch-name.sh`
- `/pr-update` → route to `git-slash-commands.mdc` → execute `pr-update.sh`

### Precedence

Slash commands have HIGHEST priority (before keyword triggers)
```

---

### Phase 3: Slash Command Testing

**Test Scenarios** (10 trials each):

1. **User uses slash command**: `/commit`

   - Expected: Immediate route to git-commit.sh, no routing ambiguity
   - Measure: Script usage rate should be 100%

2. **User doesn't use slash command**: "commit these changes"

   - Expected: Prompt for `/commit` vs manual
   - Measure: Was prompt shown?

3. **User chooses slash command after prompt**: "commit these changes" → shown prompt → chooses `/commit`

   - Expected: Route to git-commit.sh
   - Measure: Script usage rate

4. **User chooses manual after prompt**: "commit these changes" → shown prompt → chooses "manual"

   - Expected: Fall back to capabilities.mdc check
   - Measure: Script usage via fallback

5. **Indirect request without keyword**: "save this work"
   - Expected: Detect commit intent → prompt for `/commit`
   - Measure: Was intent detected? Was prompt shown?

**Measurement Template**:

```yaml
scenario: "/commit"
slash_used: true # did user provide slash command?
prompt_shown: false # was user prompted to use slash command?
slash_after_prompt: N/A # did user choose slash after prompt?
script_used: true # was repo script executed?
routing_ambiguity: false # any confusion about intent?
```

---

### Phase 4: Comparative Analysis

**Comparison Table**:

| Metric                          | Phase 1: Intent Routing | Phase 3: Slash Commands | Improvement |
| ------------------------------- | ----------------------- | ----------------------- | ----------- |
| Script usage (direct request)   | ~70%                    | Target: 100%            | +30 pts     |
| Script usage (indirect request) | ~30%                    | Target: 90%             | +60 pts     |
| Routing misses                  | ~30-40%                 | Target: <5%             | -25-35 pts  |
| User prompts needed             | ~10%                    | ~80% (first time)       | +70 pts     |
| User confusion                  | ~20%                    | Target: <5%             | -15 pts     |

**Key Insights**:

- **Routing misses**: Should drop dramatically (no keyword matching)
- **User prompts**: Will increase (teaching moment)
- **Script usage**: Should approach 100% (forcing function)

---

## Success Criteria

### Primary Metrics

**Routing Accuracy**:

- Baseline: ~60-70% (keyword-dependent)
- Slash commands: Target >95%
- **Success**: Improvement ≥25 percentage points

**Script Usage Rate**:

- Baseline: ~60-70% overall
- Slash commands: Target >90% overall
- **Success**: Improvement ≥20 percentage points

**User Experience**:

- Prompt clarity: >80% of users understand prompt
- Slash command adoption: >60% use slash command after seeing prompt once
- **Success**: High comprehension + voluntary adoption

### Secondary Metrics

**Discoverability**:

- How many users learn about `/commit` after 1 prompt? Target: >70%
- How many use it voluntarily in subsequent requests? Target: >50%

**False Positives**:

- How often is prompt shown for non-git operations? Target: <5%

**Performance**:

- Latency: slash command routing vs intent routing
- Target: slash commands ≤ intent routing latency

---

## Measurement Protocol

### Phase 1: Baseline Collection

```bash
# Run 50 baseline trials (10 per scenario)
for scenario in "${scenarios[@]}"; do
  for trial in {1..10}; do
    # Issue request
    # Capture response
    # Log: routing_triggered, script_used, user_prompted
  done
done

# Calculate baseline rates
baseline_routing=$(calculate_rate routing_triggered)
baseline_script_usage=$(calculate_rate script_used)
```

### Phase 3: Slash Command Testing

```bash
# Run 50 experimental trials (10 per scenario)
for scenario in "${scenarios[@]}"; do
  for trial in {1..10}; do
    # Issue request (with or without slash command per scenario)
    # Capture response
    # Log: slash_used, prompt_shown, slash_after_prompt, script_used
  done
done

# Calculate experimental rates
experimental_script_usage=$(calculate_rate script_used)
experimental_routing_accuracy=$(calculate_accuracy)
```

### Phase 4: Comparison

```bash
# Statistical comparison
improvement=$(( experimental_script_usage - baseline_script_usage ))
significance=$(run_proportion_test baseline experimental)

# Qualitative analysis
analyze_user_prompts
analyze_adoption_patterns
analyze_false_positives
```

---

## Expected Outcomes

### Scenario 1: Slash Commands Work Well

**Results**:

- Script usage >90% (vs ~70% baseline)
- Routing misses <5% (vs ~30% baseline)
- Users adopt slash commands after 1-2 prompts

**Conclusion**: Slash commands ARE a stronger forcing function

**Implications**:

- Roll out slash commands for all high-risk operations
- Keep intent routing as fallback for convenience
- Add more slash commands for other operations

---

### Scenario 2: Slash Commands Work But Hurt UX

**Results**:

- Script usage >90% (success)
- But: User complaints about extra prompts (>40% negative feedback)
- Or: Users always choose "manual" (>60% manual choice rate)

**Conclusion**: Slash commands work technically but not behaviorally

**Implications**:

- Refine prompt wording (less intrusive)
- Make slash commands optional but discoverable
- Or: Auto-use script without prompt, slash command as override

---

### Scenario 3: Slash Commands Don't Improve Much

**Results**:

- Script usage ~75% (only +5 points over baseline)
- Routing accuracy unchanged

**Conclusion**: Slash commands not sufficient alone

**Implications**:

- Combine with other improvements (always-apply, visible queries)
- Investigate: Are slash commands being ignored?
- Check: Is rule actually being followed?

---

### Scenario 4: Slash Commands Create New Problems

**Results**:

- High false positive rate (>20%): prompts on non-git operations
- Or: Routing confusion (slash command syntax errors)
- Or: Performance issues (latency increases)

**Conclusion**: Implementation has bugs or unintended consequences

**Implications**:

- Refine detection logic (reduce false positives)
- Improve slash command parsing
- Optimize routing performance

---

## Implementation Checklist

### Pre-Implementation

- [ ] Document current baseline (Phase 1)
  - [ ] Run 50 baseline trials
  - [ ] Calculate baseline metrics
  - [ ] Identify common routing misses

### Implementation

- [ ] Create `git-slash-commands.mdc` rule
  - [ ] Define mandatory commands (/commit, /pr, /branch)
  - [ ] Write enforcement protocol (prompt → slash or manual)
  - [ ] Set alwaysApply: true
- [ ] Update `intent-routing.mdc`
  - [ ] Add slash command triggers
  - [ ] Set precedence (slash > keywords)
- [ ] Backup original rules
- [ ] Restart Cursor to reload rules

### Testing

- [ ] Phase 3A: Test with slash commands (10 trials)
  - [ ] `/commit` usage
  - [ ] `/pr` usage
  - [ ] `/branch` usage
- [ ] Phase 3B: Test without slash commands (40 trials)
  - [ ] Direct requests (10)
  - [ ] Indirect requests (10)
  - [ ] Non-standard terms (10)
  - [ ] Amend/push operations (10)
- [ ] Log all results with detailed notes

### Analysis

- [ ] Calculate experimental metrics
- [ ] Compare to baseline (Phase 4)
- [ ] Statistical significance testing
- [ ] Qualitative analysis:
  - [ ] Review user prompt responses
  - [ ] Identify adoption patterns
  - [ ] Note false positives
- [ ] User feedback survey (if applicable)

### Decision

- [ ] If success criteria met → Keep changes
- [ ] If partial success → Refine and re-test
- [ ] If failure → Revert and investigate root cause
- [ ] Document findings and recommendations

---

## Timeline

- **Phase 1**: 3 hours (50 baseline trials)
- **Implementation**: 1 hour (create rules, update routing)
- **Phase 3**: 3 hours (50 experimental trials)
- **Phase 4**: 2 hours (analysis + comparison)
- **Total**: 1-2 days

---

## Risk Mitigation

**Risk**: Slash commands frustrate users (too explicit)  
**Mitigation**: Make prompts concise; allow "always manual" preference; survey users

**Risk**: False positives (prompts on non-git operations)  
**Mitigation**: Refine detection logic; whitelist safe operations

**Risk**: Slash commands ignored (rule not followed)  
**Mitigation**: Add to send gate; require visible output

**Risk**: Performance degradation (routing latency)  
**Mitigation**: Optimize slash command parsing; benchmark latency

---

## Follow-Up Actions

### If Successful

1. **Expand to other high-risk operations**:

   - `/delete` for destructive operations
   - `/force-push` for force pushes
   - `/revert` for history rewrites

2. **Add command discovery**:

   - `/help` lists all available commands
   - Tab completion (if Cursor supports)

3. **Integrate with other improvements**:
   - Slash commands + visible queries
   - Slash commands + always-apply rules

### If Unsuccessful

1. **Investigate why**:

   - Are slash commands being ignored?
   - Is prompt shown but not effective?
   - Is routing failing?

2. **Test alternative approaches**:
   - Required arguments (like spec-kit)
   - Command validation (syntax checking)
   - Auto-use with explicit opt-out

---

## External Pattern Comparison

### Taskmaster

**Their approach**:

- Slash commands for all task operations
- Structured prompts force specific workflows
- Explicit state transitions

**Our test**:

- Similar: slash commands for git operations
- Different: Allow fallback to manual/scripts
- Question: Should we enforce ONLY slash commands?

### Spec-kit

**Their approach**:

- Required arguments with slash commands
- Explicit safety gates (`/analyze` before `/implement`)

**Our test**:

- Phase 1: No required arguments (prompts fill them in)
- Future: Test required arguments (`/commit type:feat desc:"..."`)

---

**Status**: Ready to execute (after H1 baseline)  
**Owner**: rules-enforcement-investigation  
**Dependencies**: Hypothesis 1 baseline results  
**Estimated effort**: 1-2 days  
**Priority**: HIGH (strong forcing function candidate)
