# Action Plan: Post-Decision Execution

**Based on**: [decision-points.md](decision-points.md) (all 6 decisions resolved 2025-10-16)  
**Status**: READY TO EXECUTE  
**Estimated total effort**: ~10-14 hours over 1-2 weeks

---

## Summary of Decisions

- **D1**: ✅ Accept 80% compliance as sufficient
- **D2**: ⏸️ Explore alternatives to alwaysApply for high-risk rules (slash commands + globs + routing)
- **D3**: ✅ Formally validate H3 (query visibility)
- **D4**: ✅ Explore prompt templates now
- **D5**: ✅ Apply alwaysApply to both TDD rules (tdd-first-js, tdd-first-sh)
- **D6**: ✅ Complete after: H3 + templates + synthesis + summary

---

## Phase 1: Immediate Actions (Can Start Now)

### 1.1: Apply AlwaysApply to TDD Rules (~30 minutes)

**Files to edit**:

- `.cursor/rules/tdd-first-js.mdc`
- `.cursor/rules/tdd-first-sh.mdc`

**Changes**:

```yaml
# Change from:
alwaysApply: false

# To:
alwaysApply: true
lastReviewed: 2025-10-16
```

**Validation**:

```bash
bash .cursor/scripts/rules-validate.sh
```

**Expected outcome**: Both rules now load in every context

---

### 1.2: Design Prompt Templates Approach (~2-3 hours)

**Objective**: Create alternative to alwaysApply for high-risk rules

**Files to create** (in `.cursor/commands/`):

1. `commit.md` — Guides user to use git-commit.sh script
2. `pr.md` — Guides user to use pr-create.sh script
3. `branch.md` — Guides user to use git-branch-name.sh script
4. `test.md` — Reminds user of TDD pre-edit gate

**Template structure** (example for `/commit`):

```markdown
# Commit Changes

Use the repository's conventional commit helper:

\`\`\`bash
bash .cursor/scripts/git-commit.sh --type <feat|fix|...> --description "..."
\`\`\`

Available types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

For multi-line body: use `--body "line"` multiple times

See: assistant-git-usage.mdc for full documentation
```

**Validation approach**:

- User types `/commit` in chat
- Cursor loads template content
- Template reminds user of script-first policy
- Measure: Do prompts improve script usage?

**Success metric**: Template usage → script usage correlation

---

### 1.3: Improve Intent Routing for Medium-Risk Rules (~1-2 hours)

**Rules to improve**:

- `project-lifecycle.mdc` — Confirmed violation (premature completion)
- `guidance-first.mdc` — Confirmed violation (over-implementation)

**Changes needed**:

**project-lifecycle.mdc**:

- Add explicit phrases to trigger attachment
- Current trigger: `docs/projects/**` (path-based)
- Add: "complete project", "archive project", "mark complete", "project done"
- Strengthen completion checklist visibility

**guidance-first.mdc**:

- Current trigger: "how can we", "what's best"
- Add: "should we", "would you recommend", "what do you think about"
- Add explicit "this is guidance-only" detection

**Validation**:

- Review recent violations
- Test trigger phrases
- Measure: Do violations decrease?

---

## Phase 2: Monitoring & Validation (1-2 Weeks Passive)

### 2.1: H3 Formal Validation

**Objective**: Measure query visibility impact on compliance

**What to accumulate**:

- 10-20 git operations that trigger capabilities.mdc check
- Look for: "Checked capabilities.mdc for [operation]: [result]" in responses

**Data to collect**:

```
Operation | Query Visible? | Script Used? | Notes
--------- | -------------- | ------------ | -----
commit    | yes/no         | yes/no       | ...
PR        | yes/no         | yes/no       | ...
branch    | yes/no         | yes/no       | ...
```

**Analysis**:

- Query visibility rate: X/Y operations
- Script usage when query visible: X%
- Script usage when query not visible: Y%
- Correlation: Does visibility improve compliance?

**Success criteria**:

- Query visible in >80% of operations
- Script usage >85% when query visible
- OR: No correlation → visible queries don't help (valid finding)

---

### 2.2: Prompt Templates Real Usage Testing

**Objective**: Test whether templates improve compliance

**Approach**:

1. Create templates (Phase 1.2)
2. Use naturally during work (no artificial testing)
3. Accumulate 10-20 template uses
4. Measure: template use → script compliance correlation

**Data to collect**:

```
Attempt | Template Used? | Script Used? | Notes
------- | -------------- | ------------ | -----
1       | /commit        | yes          | Template reminded
2       | typed request  | no           | Forgot script
...
```

**Analysis**:

- Template → script correlation
- Compare: template use rate vs script use rate
- User feedback: Are templates helpful?

**Success criteria**:

- Template usage >70% when appropriate
- Script compliance >90% when template used
- OR: Templates don't help (valid finding to document)

---

### 2.3: TDD Rules AlwaysApply Validation

**Objective**: Measure improvement from D5 decision

**Baseline**: 83% TDD compliance (17% non-compliance)

**What to accumulate**:

- 20-30 implementation commits
- Track: spec file changes per implementation change

**Measurement** (after accumulation):

```bash
bash .cursor/scripts/check-tdd-compliance.sh --limit 30
```

**Expected outcome**: 83% → 90%+ improvement

**Analysis**:

- Compare pre/post alwaysApply metrics
- Document improvement magnitude
- If <90%: investigate remaining gaps

---

## Phase 3: Synthesis & Documentation (~4-6 Hours)

### 3.1: Complete Synthesis Document

**File**: `synthesis.md` (already drafted, needs completion)

**Sections to complete**:

1. ✅ H1/H2/H3 results analysis (done)
2. ✅ Scalability analysis (done)
3. ✅ Enforcement pattern catalog (done)
4. ✅ Conditional rules categorization (done)
5. ⏸️ **Final recommendations** (pending H3/templates validation)
6. ⏸️ **Decision tree guidance** (based on validated patterns)

**What to add after validation**:

- H3 validation results and recommendations
- Prompt templates effectiveness and recommendations
- TDD alwaysApply validation results
- Updated enforcement pattern catalog with all validated approaches
- Final decision tree for all 25 conditional rules

---

### 3.2: Final Summary Document (~2 Hours)

**File**: `FINAL-SUMMARY.md` (to create)

**Required sections**:

1. **Executive Summary** (1 page)

   - Problem statement
   - Key findings
   - Recommendations
   - Impact

2. **What Worked**

   - AlwaysApply effectiveness (validated)
   - Visible gates (if effective)
   - Query visibility (if effective)
   - Prompt templates (if effective)

3. **What Didn't Work**

   - Runtime routing slash commands (platform constraint)
   - Any approaches that tested negative

4. **Recommendations by Rule Type**

   - Critical rules: [pattern + rationale]
   - High-risk rules: [pattern + rationale]
   - Medium-risk rules: [pattern + rationale]
   - Low-risk rules: [pattern + rationale]

5. **Reusable Patterns**

   - For other Cursor rules repositories
   - For similar AI assistant constraint problems
   - Meta-lessons from investigation itself

6. **Future Work** (optional)
   - Remaining unexplored approaches
   - Long-term monitoring recommendations
   - Areas for deeper investigation

---

## Phase 4: Completion Checklist (Per D6)

Investigation complete when ALL of the following are done:

- [ ] **H3 validated** (10-20 git operations accumulated, analysis complete)
- [ ] **Prompt templates explored** (designed, tested, effectiveness measured)
- [ ] **TDD rules validation** (alwaysApply applied, 20-30 commits measured)
- [ ] **Synthesis written** (recommendations finalized based on validation)
- [ ] **Final summary complete** (executive summary + reusable patterns documented)
- [ ] **All artifacts validated** (rules-validate.sh passing, no broken links)

---

## Timeline Estimates

**Immediate (can start now)**:

- Phase 1.1: Apply alwaysApply → 30 minutes
- Phase 1.2: Design prompt templates → 2-3 hours
- Phase 1.3: Improve routing → 1-2 hours
- **Subtotal**: ~4-6 hours

**Passive accumulation (1-2 weeks)**:

- Phase 2.1: H3 validation → passive during normal work
- Phase 2.2: Templates testing → passive during normal work
- Phase 2.3: TDD validation → passive during normal work
- **Subtotal**: 0 active hours, wait for 20-30 operations

**Analysis & documentation (after validation)**:

- Phase 3.1: Complete synthesis → 4-6 hours
- Phase 3.2: Final summary → 2 hours
- **Subtotal**: ~6-8 hours

**Total effort**: ~10-14 hours over 1-2 weeks

---

## Next Immediate Steps

1. ✅ Update decision-points.md (DONE)
2. ✅ Create this action plan (DONE)
3. ⏸️ Execute Phase 1.1 (apply alwaysApply to TDD rules)
4. ⏸️ Execute Phase 1.2 (design prompt templates)
5. ⏸️ Execute Phase 1.3 (improve routing)
6. ⏸️ Begin Phase 2 passive monitoring

---

**Status**: Action plan complete  
**Ready to execute**: Phase 1 (immediate actions)  
**Awaiting**: User approval to proceed with Phase 1




