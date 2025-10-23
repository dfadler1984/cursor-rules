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
  - Severity: Medium (workflow automation contradiction)
  - Root cause: GitHub Action auto-labels without checking changeset presence
  - Category: Composite action handling (routing recognized intent, automation contradicted it)
  - Tasks: 4 for routing-optimization scope

- **Finding #2**: Moved to rules-enforcement-investigation → Gap #17 & #17b
  - **Gap #17**: Reactive documentation (offered fix-first, not document-first)
    - Severity: High (alwaysApply rule violation - self-improve.mdc)
    - AlwaysApply rule loaded, explicit "don't wait" requirement, violated anyway
  - **Gap #17b**: Created ACTIVE-MONITORING.md without enforcement mechanism
    - User: "How will you know to check ACTIVE-MONITORING?"
    - Same pattern repeating immediately (create solution, miss enforcement layer)
  - Category: Execution compliance (rule loaded but ignored)
  - Why moved: Execution issue, not routing issue (belongs in rules-enforcement-investigation)
  - Cross-reference: Discovered during routing-optimization monitoring
  - See: [`rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md`](../rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md)
  - Enforcement recommendation: [`rules-enforcement-investigation/findings/gap-17-enforcement-recommendation.md`](../rules-enforcement-investigation/findings/gap-17-enforcement-recommendation.md)

### Phase 3 Corrective Actions

**Finding #1: Changeset Intent Contradiction**

- [x] **Immediate**: Remove skip-changeset label from PR #159 ✅

  - ✅ Label removed using pr-labels.sh --pr 159 --remove skip-changeset
  - ✅ Verified removed: API shows labels: [], updated_at: 2025-10-23T13:53:35Z
  - ✅ Changeset file verified present: `.changeset/routing-optimization-phase-2.md`
  - ⚠️ Note: Initial attempt used curl (script-first violation) → documented as Gap #18
  - ✅ Corrected: Used pr-labels.sh on second attempt
  - ⚠️ Watch for: Workflow may re-apply on next push (synchronize event)

- [x] **Investigation**: Analyze pr-create.sh and label behavior ✅

  - ✅ pr-create.sh does NOT auto-apply skip-changeset (verified: no default --label)
  - ✅ GitHub Action auto-applies: `.github/workflows/changeset-autolabel-docs.yml`
  - ✅ Root cause: Workflow checks isDocsOnly, doesn't check hasChangeset
  - ✅ Workflow runs on every push (synchronize event) → may re-apply label
  - ✅ Documented in phase3-findings.md
  - ✅ Script-first violation documented as Gap #18 in rules-enforcement-investigation

- [ ] **Workflow**: Update assistant-git-usage.mdc

  - Add: "with changeset" means NO skip-changeset label
  - Add: Explicit label handling guidance for PR creation
  - Add: Composite intent examples (changeset + label state)

- [ ] **Enhancement**: Add composite action handling to intent-routing.mdc
  - Pattern: "action WITH requirement" → ensure requirement + no contradictions
  - Example: "PR with changeset" → has changeset, no skip-changeset label
  - Validation: Check positive (has X) AND negative (no anti-X)

**Finding #2: Moved to rules-enforcement-investigation (Gap #17)**

Finding #2 analysis and tasks moved to rules-enforcement-investigation project where execution compliance is monitored.

**Why moved**: This is an execution failure (alwaysApply rule loaded but ignored), not a routing failure (wrong rules attached).

**Cross-reference value for routing-optimization**:

- Validates: Routing and execution are separate problem categories
- Routing optimizations improved intent recognition ✅
- Execution compliance needs different enforcement (blocking gates, not routing improvements)
- See [`rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md`](../rules-enforcement-investigation/findings/gap-17-reactive-documentation-proactive-failure.md)

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
