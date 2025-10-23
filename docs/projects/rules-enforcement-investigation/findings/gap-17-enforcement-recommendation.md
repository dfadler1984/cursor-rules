# Gap #17/17b Enforcement Recommendation

**Date**: 2025-10-23  
**For**: ACTIVE-MONITORING.md usage enforcement  
**Based on**: H2 validated findings (explicit OUTPUT → 100% visibility)

---

## Recommended Approach: Three-Tier Enforcement

### Tier 1: Explicit OUTPUT Requirement (PRIMARY)

**Add to**: `self-improve.mdc` (investigation section, lines 181-254)

**Pattern**: Proven effective in H2 (visible gates achieved 100% visibility)

**Implementation**:

```markdown
**When observing issue during investigation work, OUTPUT:**

```
Observed: [brief description]
Category: [routing|execution|workflow|other]
Project: [checked ACTIVE-MONITORING.md → project-name]
Document in: [findings file path]
```

Then proceed to document in correct location.
```

**Rationale**:
- H2 validated: Explicit OUTPUT requirements → 100% visibility
- Creates accountability through transparency
- Forces the ACTIVE-MONITORING.md check before documentation

---

### Tier 2: Pre-Send Gate Item (SECONDARY)

**Add to**: `assistant-behavior.mdc` (pre-send gate checklist)

**Implementation**:

```markdown
Pre-Send Gate:
- [ ] Links: Markdown format?
- [ ] Status: included?
- [ ] Monitoring: Checked ACTIVE-MONITORING.md? (if documenting finding)
- [ ] TODOs: reconciled?
- [ ] Consent: obtained?
...
```

**Rationale**:
- Catches project scope confusion before sending
- Validates OUTPUT requirement was followed
- Adds validation layer to enforcement

---

### Tier 3: Documentation Reference (TERTIARY)

**Add to**: `self-improve.mdc` (investigation section)

**Implementation**:

```markdown
**Before documenting findings during active investigations**:

1. Check project scope: Consult `docs/projects/ACTIVE-MONITORING.md`
2. Match observed issue to project category (routing|execution|workflow)
3. Document in correct project's findings location
4. Cross-reference from discovery context if relevant
```

**Rationale**:
- Provides context and guidance
- Explains why to check ACTIVE-MONITORING.md
- Supports enforcement even if OUTPUT/gate missed

---

## Why This Combination

### Evidence-Based

**From H2 (visible gates)**:
- Explicit OUTPUT → 100% visibility (0% → 100%)
- Pattern: "OUTPUT this checklist" works better than "verify"
- Validated in 1 checkpoint with 100% success

**From Gap #15 (changeset violations)**:
- Visible gates create transparency but don't prevent violations
- Need blocking enforcement for critical requirements
- Combination of visible + blocking most effective

**From Gap #17/17b**:
- AlwaysApply insufficient for complex multi-step behaviors
- Need explicit action requirements (OUTPUT)
- Need validation layers (pre-send gate)

### Why Not Other Options

**Option 3 (context-based auto-attachment)**: 
- Only triggers when already in findings files (too late)
- Doesn't help with "where should this go" decision
- Better to have explicit check before documenting

**AlwaysApply alone**:
- Gap #17 proves alwaysApply can be violated
- Even with explicit guidance ("don't wait")
- Need enforcement beyond just loading rules

---

## Expected Impact

### Tier 1 (OUTPUT Requirement)

**Expected**: 90-100% compliance (based on H2 findings)

**Measurement**:
- Count: Investigation findings documented
- Check: How many have OUTPUT preceding them?
- Target: ≥90% with correct project category check

### Tier 2 (Pre-Send Gate)

**Expected**: Catch remaining 10% that miss OUTPUT

**Measurement**:
- Pre-send gate should show "Monitoring: ✅ Checked ACTIVE-MONITORING.md"
- Target: 100% of findings-related messages show gate check

### Tier 3 (Documentation)

**Expected**: Support understanding, not primary enforcement

**Value**:
- Explains why to check ACTIVE-MONITORING.md
- Provides decision tree reference
- Helps when OUTPUT/gate not triggered

---

## Implementation Priority

**Phase 6G Task 31.0**:

1. **31.1** (PRIMARY): Add OUTPUT requirement to self-improve.mdc
   - Expected impact: 90-100% compliance
   - Effort: 15-30 minutes
   - Risk: Low (proven pattern from H2)

2. **31.2** (SECONDARY): Add gate item to assistant-behavior.mdc
   - Expected impact: Catch remaining 10%
   - Effort: 5-10 minutes
   - Risk: Low (gate already exists, just adding item)

3. **31.3** (TERTIARY): Add documentation to self-improve.mdc
   - Expected impact: Context and guidance
   - Effort: 10-15 minutes
   - Risk: None (documentation only)

4. **31.4**: Add solution creation checklist
   - Expected impact: Prevent future "solution without enforcement" gaps
   - Effort: 15-20 minutes
   - Risk: Low

5. **31.5**: Document complexity hypothesis
   - Expected impact: Understand why simple vs complex rules differ
   - Effort: 1-2 hours (analysis work)
   - Risk: None (analysis only)

**Total Effort**: 2-3 hours for full task 31.0

---

## Success Metrics

**Enforcement successful when**:

1. **Future findings**: All have OUTPUT showing ACTIVE-MONITORING.md check
2. **Project accuracy**: 100% of findings documented in correct project
3. **Pre-send gate**: Shows monitoring check for all finding documentation
4. **User corrections**: Zero "this belongs in different project" corrections

**Validation Method**:
- Monitor next 10 findings documented
- Expect: 10/10 in correct project with OUTPUT shown
- Target: 100% accuracy (0 user corrections needed)

---

**Status**: Recommendation complete  
**Evidence**: Based on H2 validated findings (OUTPUT → 100%)  
**Implementation**: Task 31.0 in Phase 6G (5 subtasks, 2-3 hours)

