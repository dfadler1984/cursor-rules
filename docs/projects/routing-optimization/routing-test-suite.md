# Routing Optimization — Test Suite

**Date**: 2025-10-23  
**Purpose**: Validate intent routing accuracy with ≥20 test cases  
**Target**: ≥90% routing accuracy (≥18/20 pass)

---

## Test Framework

### Test Case Format

```markdown
**Test ID**: RT-###
**Intent Type**: <Implementation|Guidance|Planning|etc.>
**User Message**: "<exact message>"
**Expected Rules**: <list of rules that should attach>
**Expected Action**: <what assistant should do>
**Success Criteria**: <how to verify correct routing>
```

### Validation Method

**Manual Validation** (Phase 2):

1. Send each test message to assistant in clean context
2. Observe which rules attached (check status update or behavior)
3. Verify expected rules attached
4. Mark PASS if all expected rules attached; FAIL if wrong/missing rules

**Automated Validation** (Phase 3, future):

- Create `routing-validate.sh` script
- Parse message → predict expected rules → compare actual
- Report: pass/fail count, false positive rate

---

## Test Suite

### Group 1: Implementation Intents (High Frequency, 75% baseline)

**RT-001: Clear Implementation Request**

- **Intent Type**: Implementation
- **User Message**: "Implement login functionality"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Attach implementation rules, ask for TDD confirmation
- **Success Criteria**: TDD pre-edit gate shown before starting implementation

**RT-002: Implementation with Target**

- **Intent Type**: Implementation
- **User Message**: "Add error handling to parse.ts"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Attach implementation rules, confirm target file
- **Success Criteria**: Implementation rules attached, file confirmed

**RT-003: Fix Bug Intent**

- **Intent Type**: Implementation
- **User Message**: "Fix bug in user authentication"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Attach implementation rules, ask for bug details
- **Success Criteria**: Implementation rules attached, clarification asked if needed

**RT-004: Build Component Intent**

- **Intent Type**: Implementation
- **User Message**: "Build a navbar component"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Attach implementation rules, ask for requirements
- **Success Criteria**: Implementation rules attached (build = implement synonym)

---

### Group 2: Guidance Requests (High Frequency, 90%+ baseline)

**RT-005: How Question**

- **Intent Type**: Guidance
- **User Message**: "How should I structure the API client?"
- **Expected Rules**: `guidance-first.mdc`
- **Expected Action**: Ask clarifying questions before proposing implementation
- **Success Criteria**: Guidance-first attached, NOT implementation rules

**RT-006: What Question**

- **Intent Type**: Guidance
- **User Message**: "What's the best way to handle errors?"
- **Expected Rules**: `guidance-first.mdc`
- **Expected Action**: Provide options and trade-offs, ask for context
- **Success Criteria**: Guidance-first attached, options presented

**RT-007: Should We Question**

- **Intent Type**: Guidance
- **User Message**: "Should we use Redux for state management?"
- **Expected Rules**: `guidance-first.mdc`
- **Expected Action**: Explain options, ask about constraints
- **Success Criteria**: Guidance-first attached, NOT implementation rules

---

### Group 3: Intent Override (File Signal Conflicts)

**RT-008: Guidance in Test File**

- **Intent Type**: Guidance (overrides file signal)
- **User Message**: "How should I structure this test?" (in `login.test.ts`)
- **Context**: File signal present (`*.test.ts`)
- **Expected Rules**: `guidance-first.mdc` (NOT testing.mdc)
- **Expected Action**: Provide guidance on test structure
- **Success Criteria**: Guidance-first attached despite test file context

**RT-009: Implementation Confirming File Signal**

- **Intent Type**: Implementation (confirms file signal)
- **User Message**: "Implement login test" (in `login.test.ts`)
- **Context**: File signal present (`*.test.ts`)
- **Expected Rules**: `testing.mdc`, `tdd-first.mdc`, `test-quality-js.mdc`
- **Expected Action**: Attach testing rules, proceed with implementation
- **Success Criteria**: Testing rules attached (intent confirms file signal)

**RT-010: Guidance in Code File**

- **Intent Type**: Guidance (overrides file signal)
- **User Message**: "What patterns should I use for this API?" (in `api.ts`)
- **Context**: File signal present (`*.ts`)
- **Expected Rules**: `guidance-first.mdc` (NOT tdd-first/code-style)
- **Expected Action**: Provide guidance on API patterns
- **Success Criteria**: Guidance-first attached despite TS file context

---

### Group 4: Multi-Intent Requests

**RT-011: Plan Then Implement**

- **Intent Type**: Multi-intent (planning + implementation)
- **User Message**: "Plan and implement the checkout flow"
- **Expected Rules**: `spec-driven.mdc`, `guidance-first.mdc` (first phase)
- **Expected Action**: Ask confirmation: "Start with plan, then implement?"
- **Success Criteria**: Planning rules attached, confirmation asked

**RT-012: Explicit Order (Implement First)**

- **Intent Type**: Multi-intent (implementation first, then docs)
- **User Message**: "Implement the feature first, then document it"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Honor user order, proceed to implementation
- **Success Criteria**: Implementation rules attached without confirmation (user explicit)

**RT-013: Skip Planning**

- **Intent Type**: Implementation (explicit skip planning)
- **User Message**: "Skip planning, just build the login form"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Proceed to implementation
- **Success Criteria**: Implementation rules attached, no plan-first prompt

---

### Group 5: Confidence-Based Disambiguation

**RT-014: Medium Confidence (Soft Phrasing)**

- **Intent Type**: Ambiguous (medium confidence)
- **User Message**: "We probably need better caching"
- **Expected Rules**: None initially
- **Expected Action**: Ask: "Are you looking for guidance on caching strategies, or would you like me to implement caching?"
- **Success Criteria**: Confirmation prompt shown, no rules attached until answered

**RT-015: Low Confidence (Vague)**

- **Intent Type**: Ambiguous (low confidence)
- **User Message**: "We need to fix the errors"
- **Expected Rules**: None initially
- **Expected Action**: Ask: "Which errors? What files/components are affected?"
- **Success Criteria**: Clarifying question asked, no rules attached

**RT-016: High Confidence (Exact Phrase)**

- **Intent Type**: Implementation (high confidence)
- **User Message**: "Implement user profile page"
- **Expected Rules**: `tdd-first.mdc`, `code-style.mdc`, `testing.mdc`
- **Expected Action**: Attach implementation rules immediately
- **Success Criteria**: Implementation rules attached without confirmation

---

### Group 6: Analysis/Investigation Intent

**RT-017: Analyze Pattern**

- **Intent Type**: Analysis
- **User Message**: "Analyze the performance bottleneck in the API"
- **Expected Rules**: `guidance-first.mdc`
- **Expected Action**: Ask questions before starting analysis
- **Success Criteria**: Guidance-first attached, NOT immediate implementation

**RT-018: Investigate Issue**

- **Intent Type**: Analysis
- **User Message**: "Investigate why tests are failing"
- **Expected Rules**: `guidance-first.mdc`, possibly `testing.mdc`
- **Expected Action**: Ask for context, propose investigation approach
- **Success Criteria**: Guidance-first attached, investigation approach proposed

---

### Group 7: Testing Intent

**RT-019: Create Tests**

- **Intent Type**: Testing
- **User Message**: "Create tests for the authentication module"
- **Expected Rules**: `testing.mdc`, `tdd-first.mdc`, `test-quality-js.mdc`
- **Expected Action**: Attach testing rules, ask for module details if needed
- **Success Criteria**: Testing rules attached

**RT-020: Improve Coverage**

- **Intent Type**: Testing
- **User Message**: "Improve test coverage for parse.ts"
- **Expected Rules**: `testing.mdc`, `tdd-first.mdc`, `test-quality-js.mdc`
- **Expected Action**: Attach testing rules, analyze current coverage
- **Success Criteria**: Testing rules attached (improve = verb synonym)

---

### Group 8: Refactoring Intent

**RT-021: Refactor Request**

- **Intent Type**: Refactoring
- **User Message**: "Refactor the authentication logic to be more modular"
- **Expected Rules**: `refactoring.mdc`, `testing.mdc`
- **Expected Action**: Attach refactoring rules, confirm tests exist
- **Success Criteria**: Refactoring rules attached, pre-action gate shown

**RT-022: Extract Function**

- **Intent Type**: Refactoring
- **User Message**: "Extract parseUser function from utils.ts"
- **Expected Rules**: `refactoring.mdc`, `testing.mdc`
- **Expected Action**: Attach refactoring rules, proceed
- **Success Criteria**: Refactoring rules attached (extract = refactor verb)

---

### Group 9: Git Operations (Already at 100%)

**RT-023: Commit Request**

- **Intent Type**: Git operation
- **User Message**: "Create a commit for these changes"
- **Expected Rules**: `assistant-git-usage.mdc` (always applied)
- **Expected Action**: Use `git-commit.sh` script
- **Success Criteria**: Script-first rule followed (100% with alwaysApply)

**RT-024: Create PR**

- **Intent Type**: Git operation
- **User Message**: "Open a PR for this branch"
- **Expected Rules**: `assistant-git-usage.mdc` (always applied)
- **Expected Action**: Use `pr-create.sh` script
- **Success Criteria**: Script-first rule followed

---

### Group 10: Project Lifecycle

**RT-025: Archive Project**

- **Intent Type**: Project lifecycle
- **User Message**: "Archive the rules-validation project"
- **Expected Rules**: `project-lifecycle.mdc`
- **Expected Action**: Suggest dry-run first (`--dry-run` flag)
- **Success Criteria**: Project-lifecycle attached, helper script suggested

---

## Validation Results Template

### Test Run: [Date]

| Test ID | Pass/Fail | Expected Rules              | Actual Rules         | Notes |
| ------- | --------- | --------------------------- | -------------------- | ----- |
| RT-001  |           | tdd-first, code-style, test | (fill after running) |       |
| RT-002  |           | tdd-first, code-style, test | (fill after running) |
| ...     |           |                             |                      |       |

**Summary**:

- Total Tests: 25
- Passed: **_/25 (_**%)
- Failed: **_/25 (_**%)
- False Positives: \_\_\_ (unnecessary rules attached)
- Target: ≥90% (≥23/25 pass), <5% false positives

**Analysis**:

- Which patterns failed most frequently?
- Root causes for failures?
- Recommended fixes?

---

## Success Criteria

**Phase 2 Target (Interim)**:

- ≥18/20 tests pass (90% accuracy)
- ≤2/20 false positives (10%)

**Phase 3 Target (Final)**:

- ≥23/25 tests pass (92% accuracy)
- ≤1/25 false positives (4%)

**Deployment Decision**:

- If Phase 2 target met → proceed to Phase 3 validation
- If Phase 2 target missed → revise optimizations, re-test

---

## Future Enhancements

### Automated Test Script (`routing-validate.sh`)

**Proposed Implementation**:

```bash
#!/usr/bin/env bash
# routing-validate.sh — Automated routing test validation

# Input: test-cases.json with { message, expected_rules[] }
# Output: pass/fail report, false positive rate

# Pseudo-code:
# for each test_case in test_cases:
#   send message to assistant (via API or mock)
#   parse attached rules from response
#   compare expected vs actual
#   if match: PASS
#   else: FAIL (log expected vs actual)
# report summary
```

**Challenges**:

- Requires ability to parse which rules attached (status update or behavior)
- May need assistant cooperation (visible rule attachment output)
- Alternative: Manual validation with standardized checklist

---

**Status**: Test suite created (25 cases)  
**Next**: Run manual validation on sample cases  
**Target**: ≥90% pass rate before deploying optimizations
