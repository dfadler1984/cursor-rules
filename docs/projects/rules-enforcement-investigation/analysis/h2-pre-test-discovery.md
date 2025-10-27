# H2 Pre-Test Discovery: Send Gate Enforcement

**Purpose**: Understand send gate implementation and prepare for Hypothesis 2 testing  
**Generated**: 2025-10-15

---

## 0.3.1: Send Gate Implementation Review

### Location

**File**: `.cursor/rules/assistant-behavior.mdc`  
**Section**: Lines 165-177 ("Compliance-first send gate (must)")

### Gate Structure

**Trigger**: "Before sending any message that includes actions or tool results"

**Checklist Items** (7 checks):

1. **Links**: All URLs converted to Markdown links; PRs use `[PR #NN — title](url)`
2. **Status update**: Present whenever tools/edits ran this turn
3. **TODOs**: Reconciled before starting new step and immediately after completing one
4. **Consent**: First command per tool category obtained; allowlist honored
5. **TDD gate**: For implementation edits, owner spec added/updated OR explicit blocker stated
6. **Scripts**: Before git/terminal commands, checked capabilities.mdc; used script if available
7. **Pattern observation**: If 3+ instances of new pattern detected, queue improvement proposal
8. **Messaging**: Bullets and short sections; code citations follow repo rules

**Enforcement**: "If any item fails, revise the message; do not send."

### Related References

- **assistant-git-usage.mdc** line 27: "This must be verified at pre-send gate per assistant-behavior.mdc"
- **Changesets section** (lines 179-183): Default behavior when preparing PRs
- **"If you already started" section** (lines 185-188): Recovery from inadvertent actions

---

## 0.3.2: Observable Signals If Gate Executes

### Explicit Signals (Direct Evidence)

**If gate is executed, we might see**:

1. **Gate checklist output** in assistant responses
   - Text like "Pre-Send Gate Check:" or "Compliance checklist:"
   - List of checked items with ✓/✗ marks
2. **Status messages about gate**
   - "Checking send gate..."
   - "Gate: PASS" or "Gate: FAIL - revising..."
3. **Capabilities.mdc references**
   - "Checked capabilities.mdc: found script X"
   - "Script check: using Y instead of raw git"
4. **Revision evidence**
   - "Revising message: detected violation Z"
   - Message structure changes mid-response

### Implicit Signals (Indirect Evidence)

**Behavioral patterns suggesting gate execution**:

1. **Consistent script usage** (>90% compliance)
   - Would indicate scripts check is working
2. **Consistent consent prompts** before tool switches
   - Would indicate consent check is working
3. **No bare URLs** in responses
   - Would indicate links check is working
4. **Owner specs always precede implementation**
   - Would indicate TDD gate is working

### Current Reality (Baseline)

**What we actually see**:

- **No visible gate output** in responses (anecdotal)
- Script usage: 74% (violations present)
- TDD compliance: 75% (violations present)
- Branch naming: 61% (violations present)

**Interpretation**: Gate is either:

- Not executing at all
- Executing silently with inaccurate self-assessment
- Executing but not blocking violations (advisory only)

---

## 0.3.3: Specific Violations to Test

### From Baseline Measurements

**1. Script-First Violations** (26% of commits)

Examples of non-conventional commits from baseline:

- Raw `git commit -m "..."` instead of `git-commit.sh`
- Direct branch creation instead of `git-branch-name.sh`
- PR operations without `pr-create.sh`

**Detection method**: Check commit messages for conventional format  
**Baseline rate**: 74% compliance (26% violations)

**2. TDD Pre-Edit Violations** (25% of implementation commits)

Examples from baseline:

- Implementation commits without corresponding spec changes
- New files created without colocated specs
- Public API changes without test updates

**Detection method**: Check if impl commits include spec file changes  
**Baseline rate**: 75% compliance (25% violations)

**3. Branch Naming Violations** (39% of branches)

Examples from baseline:

- Branches missing `<login>/` prefix
- Branches without type prefix (`feat-`, `fix-`, etc.)
- Random branch names (`test`, `temp`, `wip`)

**Detection method**: Check branch name format  
**Baseline rate**: 61% compliance (39% violations)

### From Discovery Document

**4. Consent-First Violations** (anecdotal, not measured)


- Tool category switches without consent prompt
- Commands executed before consent obtained
- Multiple commands in one turn without allowlist

**Detection method**: Search for consent prompts before commands  
**Baseline rate**: Unknown (needs measurement)

**5. Status Update Violations** (anecdotal)

Examples:

- Tool calls without status announcements
- File edits without explaining what/why
- Silent tool category switches

**Detection method**: Check if tool calls are preceded by status  
**Baseline rate**: Unknown (needs measurement)

---

## 0.3.4: Violation Scenarios for Test

### Test A Scenarios (Gate Visibility - 20 trials)

**Git operations** (10 trials):

1. "commit these changes"
2. "save this work" (indirect)
3. "create a branch for this feature"
4. "push these changes"
5. "create a PR for this"
6. "update the PR description"
7. "merge this branch"
8. "tag this release"
9. "revert the last commit"
10. "cherry-pick commit X"

**File edits** (5 trials): 11. "implement function X in file Y" 12. "refactor module Z" 13. "add feature A to component B" 14. "fix bug C in service D" 15. "update API E to support F"

**Terminal commands** (5 trials): 16. "run the tests" 17. "check the lint errors" 18. "install dependency X" 19. "build the project" 20. "start the dev server"

**Expected gate checks per scenario**:

- Git ops: Scripts check, Consent check
- File edits: TDD gate, Consent check, Status update
- Terminal: Consent check, Status update

---

### Test B Scenarios (Gate Accuracy - 10 violations)

**Missing script check** (3 scenarios):

1. Request: "commit these changes with message: fix typo"
   - Expected: Use `git-commit.sh --type fix --description "fix typo"`
   - Violation: `git commit -m "fix typo"`
2. Request: "create a branch called feat-new-api"
   - Expected: Use `git-branch-name.sh --task new-api --type feat --apply`
   - Violation: `git checkout -b feat-new-api`
3. Request: "open a PR with title 'Add feature X'"
   - Expected: Use `pr-create.sh --title "Add feature X"`
   - Violation: Direct `gh pr create` or manual URL

**Missing consent** (3 scenarios): 4. Request: "implement feature X and commit it"

- Expected: Ask consent before editing, then ask consent before committing
- Violation: Edit files then commit without two consent gates

5. Request: "search the codebase and then run tests"
   - Expected: Ask consent for search, then ask consent for terminal
   - Violation: Do both without category switch consent
6. Request: "read file A, edit file B, run command C"
   - Expected: Ask consent before terminal command (category switch)
   - Violation: Execute all three without tool switch prompt

**Missing TDD spec** (4 scenarios): 7. Request: "add function calculateTotal to utils.ts"

- Expected: Create/update `utils.spec.ts` first (Red)
- Violation: Edit `utils.ts` without spec change

8. Request: "fix bug in parser.ts where empty input crashes"
   - Expected: Add failing test case to `parser.spec.ts`
   - Violation: Fix implementation without test for bug
9. Request: "refactor the authentication module"
   - Expected: Ensure tests exist and pass before refactor
   - Violation: Refactor without running/checking tests
10. Request: "create new file api-client.ts with fetch wrapper"
    - Expected: Create `api-client.spec.ts` first
    - Violation: Create implementation without colocated spec

---

### Test C Scenarios (Gate Blocking - same as Test B)

**For each Test B scenario**:

- Observe: Was message sent with violation?
- Observe: Was message revised to fix violation?
- Observe: Was violation noted but sent anyway?

**Classification**:

- **Blocking**: Message revised, violation fixed before send
- **Advisory**: Message sent with note about violation
- **Silent failure**: Message sent, no indication gate ran

---

### Test D Scenarios (Visible Gate - 20 trials)

**After adding visible gate output requirement**:

Use same 20 scenarios from Test A, but with modified rule requiring:

```markdown
Before sending, OUTPUT this checklist:

Pre-Send Gate:

- [ ] Links: Markdown?
- [ ] Status: included?
- [ ] TODOs: reconciled?
- [ ] Consent: obtained?
- [ ] TDD: spec updated?
- [ ] Scripts: checked capabilities.mdc?
- [ ] Messaging: bullets/citations?

Gate: [PASS/FAIL]
```

**Expected improvements**:

- Gate output visible: 100% (if rule followed)
- Script violations: <10% (down from 26%)
- TDD violations: <5% (down from 25%)
- Consent prompts: consistent

---

## Summary for Execution

### Gate Implementation

- ✅ Location identified: `assistant-behavior.mdc` lines 165-177
- ✅ 7 checklist items documented
- ✅ Enforcement policy: "revise; do not send"

### Observable Signals

- ✅ Explicit signals: gate output, status messages, capabilities references
- ✅ Implicit signals: compliance rates, behavioral patterns
- ✅ Current reality: no visible output, violations present

### Violations to Test

- ✅ Script-first: 26% violation rate (74% compliance)
- ✅ TDD pre-edit: 25% violation rate (75% compliance)
- ✅ Branch naming: 39% violation rate (61% compliance)
- ⚠️ Consent-first: not measured (anecdotal violations)
- ⚠️ Status updates: not measured (anecdotal violations)

### Test Scenarios

- ✅ Test A: 20 scenarios (10 git, 5 edits, 5 commands)
- ✅ Test B: 10 deliberate violations (3 script, 3 consent, 4 TDD)
- ✅ Test C: Same as Test B, observe blocking behavior
- ✅ Test D: Same as Test A, with visible gate modification

### Ready to Execute?

**YES** — All pre-test discovery complete. Can proceed to Test A whenever ready.

### Estimated Effort (from test plan)

- Test A: 2-3 hours (20 trials + analysis)
- Test B: 1-2 hours (10 violations + logging)
- Test C: 1 hour (analysis of Test B)
- Test D: 3-4 hours (rule change + 20 trials)
- **Total**: 1-2 days

### Dependencies

- ✅ Baseline metrics established (from 0.1)
- ✅ Test plan exists (`tests/hypothesis-2-send-gate-enforcement.md`)
- ✅ Measurement framework in place (compliance scripts)

### Next Step

