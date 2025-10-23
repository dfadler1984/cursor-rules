# Tasks — Routing Optimization

## Phase 1: Analysis ✅ COMPLETE

- [x] Review last 20 conversations for routing decisions (correct/incorrect/delayed)
- [x] Identify top 10 most-used intent patterns and their outcomes
- [x] Document common failure modes (ambiguous signals, conflicting triggers)
- [x] Measure baseline: false-positive rate, context overhead, time-to-route

**Deliverable**: [analysis.md](./analysis.md) — Comprehensive baseline analysis with:

- Current routing performance: 68% baseline (script usage 74%, TDD 75%, branch naming 61%)
- Top 10 intent patterns with accuracy rates
- 8 documented failure modes (4 Type 1: rules violated, 2 Type 2: rules missing, 2 Type 3: ambiguous)
- Measurement framework and success criteria

## Phase 2: Optimization ✅ COMPLETE

- [x] Refine trigger patterns for top 10 intents based on analysis
- [x] Implement confidence-based disambiguation for medium matches
- [x] Add routing test suite with ≥20 test cases covering edge cases
- [x] Reduce redundant rule content via cross-references

**Deliverables**:

- [optimization-proposal.md](./optimization-proposal.md) — Comprehensive Phase 2 proposal with 4 optimizations
- [routing-test-suite.md](./routing-test-suite.md) — 25 test cases across 10 groups
- Updated `.cursor/rules/intent-routing.mdc` with:
  - Explicit intent override tier (file signals downgraded)
  - Refined triggers for top 10 intents (Implementation, Testing, Analysis, Refactoring)
  - Expanded confidence tiers (High/Medium/Low with thresholds)
  - Multi-intent handling (plan-first default)
  - Confirmation prompt templates

## Phase 3: Validation 🔄 IN PROGRESS

### Phase 2 Checkpoint ✅ COMPLETE

- [x] Run Phase 2 checkpoint (10 sample test cases)
- [x] Validate logic for critical optimizations
- [x] Decision: PROCEED to Phase 3

**Results**: 10/10 PASS (100%) — Exceeds 80% checkpoint target  
**Deliverable**: [validation-session.md](./validation-session.md) — Detailed test case analysis

**Validated Optimizations**:

- ✅ Intent override tier (RT-008, RT-009) — 100% pass
- ✅ Multi-intent handling (RT-011) — 100% pass
- ✅ Confidence-based disambiguation (RT-014) — 100% pass
- ✅ Refined triggers (RT-001, RT-004, RT-017, RT-019, RT-021) — 100% pass

### Phase 3 Full Validation 🔄 IN PROGRESS

- [x] Monitor optimizations during normal work (started 2025-10-23)
- [ ] Collect ≥50 real messages across diverse intents
- [ ] Run full 25-case test suite (manual validation)
- [ ] Measure post-deployment metrics vs baseline
- [ ] Document findings and update `intent-routing.mdc` as needed

**Phase 3 Findings** (see [phase3-findings.md](./phase3-findings.md)):

- **Finding #1**: Changeset intent partially honored (2025-10-23)
  - User: "create a pr with changeset"
  - Actual: Changeset created ✅, but skip-changeset label applied ❌
  - Severity: Medium (intent contradiction)
  - Tasks created below

### Phase 3 Corrective Actions

**Finding #1: Changeset Intent Contradiction**

- [ ] **Immediate**: Remove skip-changeset label from PR #159
  - Verify changeset file properly included
  - Ensure PR processed correctly by CI

- [ ] **Investigation**: Analyze pr-create.sh behavior
  - Does script auto-apply skip-changeset as default?
  - Should script check for changeset files before applying label?
  - Document findings in phase3-findings.md

- [ ] **Workflow**: Update assistant-git-usage.mdc
  - Add: "with changeset" means NO skip-changeset label
  - Add: Explicit label handling guidance for PR creation
  - Add: Composite intent examples (changeset + label state)

- [ ] **Enhancement**: Add composite action handling to intent-routing.mdc
  - Pattern: "action WITH requirement" → ensure requirement + no contradictions
  - Example: "PR with changeset" → has changeset, no skip-changeset label
  - Validation: Check positive (has X) AND negative (no anti-X)

## Phase 4: Optional Enhancements (Future)

**Minor Gap from Phase 2 Validation**:

- [ ] Add explicit Guidance trigger section to `intent-routing.mdc`
  - **Issue**: Guidance patterns in decision policy tier 2, but no dedicated trigger section
  - **Current**: Works correctly (guidance-first.mdc attached via intent classification)
  - **Recommendation**: Add trigger section for consistency:
    ```markdown
    - Guidance Requests
      - Triggers: <guidance-verb> + <question>
        - Verbs: how|what|which|should we|can you explain
        - Question patterns: how to|what's the best|should we consider
      - Attach: guidance-first.mdc
      - Note: Overrides file signals (tier 2 decision policy)
    ```
  - **Impact**: Low (documentation clarity only)
  - **Priority**: Optional, post-Phase 3

**Other Future Work**:

- [ ] Create automated routing validation script (`routing-validate.sh`)
  - Parse test cases → predict expected rules → compare actual
  - Report pass/fail count, false positive rate
  - Add to CI workflow (optional)

- [ ] Explore prompt templates for git operations
  - Create `.cursor/commands/*.md` templates
  - May improve discoverability (not needed for compliance)
  - Lower priority (H1 already at 100% via AlwaysApply)

## Related Files

- `.cursor/rules/intent-routing.mdc` (archived)
- `.cursor/rules/user-intent.mdc`
- `.cursor/rules/guidance-first.mdc`
