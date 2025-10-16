# ERD: Assistant Self-Testing Limits

**Status**: DISCOVERY  
**Created**: 2025-10-16  
**Parent Investigation**: rules-enforcement-investigation

---

## 1. Problem Statement

While executing the slash commands experiment, we discovered a fundamental limitation: **an AI assistant cannot objectively test its own behavioral compliance without observer bias**.

### The Testing Paradox

**Goal**: Measure whether slash command enforcement improves routing accuracy vs intent routing

**Traditional test approach**:

1. Issue test request: "commit these changes"
2. Observe: Did assistant show slash command prompt?
3. Record: Which script was used?
4. Repeat 50 times across scenarios
5. Compare to baseline

**The problem**: The assistant IS the system under test. Any attempt to "test myself" means:

- I'm consciously aware of being tested
- I'm reading the test protocol
- I'll follow the rules more carefully than in natural usage
- Results don't reflect realistic compliance

**Analogy**: Like asking "Can you test whether you'll check your blind spot?" - the act of testing changes the behavior.

---

## 2. Context

### Discovery Origin

- **Project**: rules-enforcement-investigation
- **Phase**: Slash commands experiment (Phase 6C)
- **Trigger**: User asked "is there any way you can automate the testing?"
- **Realization**: Objective self-testing is fundamentally impossible

### What We CAN Measure

✅ **Historical compliance** (retrospective):

- Git log analysis: script usage in past commits
- Compliance dashboard: `bash .cursor/scripts/compliance-dashboard.sh`
- Baseline: 74% script usage before H1 fix
- Current: 96% script usage after H1 fix (8 commits)

✅ **Natural usage monitoring** (passive):

- Continue working normally
- Accumulate commits/operations over time
- Measure compliance rates after 20-30 data points
- No conscious test bias

### What We CANNOT Measure Objectively

❌ **Prospective behavior testing**:

- Cannot issue test requests and objectively observe responses
- Cannot run 50 trials without test awareness
- Cannot separate "following rules because testing" from "natural compliance"

❌ **A/B comparison of routing strategies**:

- Would require two independent instances
- Would need blind testing (assistant unaware of which mode)
- Not possible within single assistant session

---

## 3. Scope

### In Scope

1. **Document the testing paradox**

   - Why self-testing creates observer bias
   - What measurements are valid vs invalid
   - How to work within these constraints

2. **Define valid measurement strategies**

   - Historical analysis (retrospective)
   - Natural usage monitoring (passive)
   - User-observed spot checks (qualitative)
   - External validation (CI/automated checks)

3. **Update test methodology**

   - Rules-enforcement-investigation test plans
   - Future experiment designs
   - Measurement framework limitations

4. **Decision framework**
   - When to defer tests due to measurement limitations
   - When retrospective data is sufficient
   - When external validation is needed

### Out of Scope

- Solving the fundamental observer problem (philosophical limitation)
- Creating external test infrastructure (different project)
- Multi-agent testing frameworks (future consideration)

---

## 4. Requirements

### Functional

1. **Documentation**

   - Clear explanation of testing paradox
   - Examples of valid vs invalid tests
   - Guidelines for experiment design

2. **Decision Framework**

   - Criteria for when self-testing is sufficient
   - Criteria for when external validation needed
   - Fallback strategies when ideal testing impossible

3. **Measurement Guidelines**
   - What can be measured objectively
   - What requires user observation
   - How to minimize observer bias

### Non-Functional

- Keep documentation concise (<500 lines total)
- Practical focus (actionable guidance)
- Link to rules-enforcement-investigation findings

---

## 5. Acceptance Criteria

1. ✅ Document explains testing paradox clearly
2. ✅ Valid vs invalid measurements clearly distinguished
3. ✅ Decision framework provided for future experiments
4. ✅ Rules-enforcement-investigation updated with this insight
5. ✅ Test plans note measurement limitations where applicable

---

## 6. Approach

### Phase 1: Document the Paradox

Create `testing-paradox.md`:

- Explain observer bias problem
- Examples from slash commands experiment
- Why retrospective > prospective for self-testing

### Phase 2: Define Valid Measurement Strategies

Create `measurement-strategies.md`:

- Historical analysis (git log, compliance dashboard)
- Natural usage monitoring (passive accumulation)
- User-observed validation (spot checks)
- External validation (CI, linters, pre-commit hooks)

### Phase 3: Update Investigation

Update rules-enforcement-investigation:

- Document slash commands deferral rationale
- Note testing paradox as meta-finding
- Update test plans with measurement limitations
- Recommend retrospective analysis for similar tests

### Phase 4: Create Decision Framework

Create `experiment-design-guide.md`:

- When is self-testing valid?
- When is external validation needed?
- How to work within constraints?

---

## 7. Success Metrics

- Future experiments explicitly state measurement approach
- Test plans note observer bias risks
- Retrospective analysis used where appropriate
- No time wasted on impossible self-tests

---

## 8. Dependencies

- rules-enforcement-investigation findings
- Existing compliance measurement tools
- Test plan template

---

## 9. Risks

**Risk**: Over-complicated philosophical discussion  
**Mitigation**: Keep practical, cite concrete examples

**Risk**: Dismiss valid measurements as "impossible"  
**Mitigation**: Clearly distinguish what IS measurable

**Risk**: Create analysis paralysis  
**Mitigation**: Provide clear decision tree

---

## 10. Timeline

- **Phase 1**: 30 minutes (document paradox)
- **Phase 2**: 30 minutes (measurement strategies)
- **Phase 3**: 20 minutes (update investigation)
- **Phase 4**: 30 minutes (decision framework)
- **Total**: ~2 hours

---

## 11. Related

- [rules-enforcement-investigation](../rules-enforcement-investigation/)
- [Slash commands experiment](../rules-enforcement-investigation/tests/experiment-slash-commands.md)
- [Testing paradox origin](../rules-enforcement-investigation/test-execution/slash-commands-phase3-protocol.md)
