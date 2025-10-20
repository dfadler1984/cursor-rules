# Decision Points: Where Objective Assessment Cannot Be Made

**Purpose**: Track decisions where the AI assistant cannot objectively determine the outcome and requires user judgment.

**Context**: Per [assistant-self-testing-limits](../assistant-self-testing-limits/), I cannot objectively validate which approaches work best through prospective testing. This document tracks where external validation is needed.

---

## Open Decision Points

### D1: Is 80% Compliance Sufficient?

**Context**: H1 validation shows 80% compliance (target was 90%)

**What I can provide objectively**:

- ✅ Baseline: 74% → Current: 80% (+6 points improvement)
- ✅ AlwaysApply for 5 rules: +10k tokens (~15% context increase)
- ✅ AlwaysApply for 25 rules: +33k tokens (~50% context increase) - NOT scalable

**What I cannot objectively decide**:

- ❌ Is 80% "good enough" or should we pursue 90%?
- ❌ Is the 10-point gap worth additional enforcement patterns?
- ❌ Cost/benefit tradeoff: effort vs compliance improvement

**User decision needed**:

- [ ] Accept 80% and focus on other priorities
- [ ] Pursue 90% with additional enforcement patterns (H2, H3, prompt templates)
- [ ] Partial: Apply alwaysApply to 4 other critical rules, accept current state for the rest

**Impact on investigation**:

- Accept 80%: Move to synthesis with current data
- Pursue 90%: Continue H2/H3 monitoring, potentially explore prompt templates
- Partial: Apply changes, validate with another monitoring period

---

### D2: Which Enforcement Pattern for Each of 25 Conditional Rules?

**Context**: 25 conditional rules need categorization by enforcement pattern

**What I can provide objectively**:

- ✅ Risk categorization (critical/high/medium/low) based on violation evidence
- ✅ Pattern matching (which rules are similar to validated ones)
- ✅ Context cost calculations (tokens per rule)
- ✅ Trigger frequency estimates (how often each rule attaches)

**What I cannot objectively decide**:

- ❌ Which rules are "important enough" for alwaysApply (value judgment)
- ❌ Whether intent routing improvements are "good enough" for medium-risk rules
- ❌ Priority ordering when multiple patterns could apply

**User decision needed** (for each rule or category):

- [ ] Apply alwaysApply (context cost accepted)
- [ ] Improve intent routing (specific triggers)
- [ ] Accept current state (conditional attachment sufficient)
- [ ] Defer (low priority, address later)

**Analysis I can provide**:

- Risk level + violation evidence for each rule
- Grouping by similar patterns
- Recommended pattern based on similarity to validated cases
- Cost/benefit data for each option

---

### D3: Execute H3 Fully or Defer?

**Context**: H3 (query visibility) implemented but not formally validated

**What I can provide objectively**:

- ✅ H3 is implemented (visible query output active)
- ✅ Passive monitoring is accumulating data
- ✅ H1 achieved 80% without H3 contribution measured
- ✅ Formal validation would require ~10-20 git operations with analysis

**What I cannot objectively decide**:

- ❌ Is H3 validation worth the effort given H1 at 80%?
- ❌ Does visible query output "feel" helpful during usage? (subjective)
- ❌ Priority: H3 validation vs moving to synthesis vs other projects

**User decision needed**:

- [ ] Formally validate H3 (accumulate more data, measure impact)
- [ ] Skip formal validation (accept passive observation as sufficient)
- [ ] Defer H3 (move to synthesis now, revisit if 80% proves insufficient)

**Impact**:

- Validate: Continue monitoring, delay synthesis ~1-2 weeks
- Skip: Proceed to synthesis with current data
- Defer: Synthesis now, H3 becomes optional follow-up

---

### D4: Prompt Templates Exploration Priority

**Context**: Slash commands runtime routing doesn't work, but prompt templates approach unexplored

**What I can provide objectively**:

- ✅ Runtime routing confirmed not viable (platform constraint)
- ✅ Prompt templates are a different approach (Cursor's actual design)
- ✅ H1 at 80% reduces urgency for additional patterns
- ✅ Exploration effort estimate: ~4-6 hours (design + test + validate)

**What I cannot objectively decide**:

- ❌ Is 80% → 90% improvement worth exploring prompt templates?
- ❌ Priority vs other investigations/projects
- ❌ Whether templates would actually help (requires real usage testing)

**User decision needed**:

- [ ] Explore prompt templates (create `/commit.md` etc, test with real usage)
- [ ] Defer indefinitely (80% sufficient, focus elsewhere)
- [ ] Carryover (document for future consideration if compliance drops)

**Analysis I can provide**:

- Design proposal for prompt templates approach
- Comparison to alwaysApply effectiveness
- Effort estimate and validation approach

---

### D5: Apply AlwaysApply to 4 Other Critical Rules?

**Context**: Analysis identified 5 critical rules (git-usage + 4 others)

**What I can provide objectively**:

- ✅ 4 rules identified: tdd-first-js, tdd-first-sh, testing, refactoring
- ✅ Current compliance for TDD: 83% (target: 95%)
- ✅ Context cost: ~+8k tokens for 4 additional rules (~12% increase)
- ✅ H1 validation: alwaysApply improved compliance +6-11 points

**What I cannot objectively decide**:

- ❌ Is TDD at 83% "good enough" or pursue 95%?
- ❌ Is 12% context increase acceptable?
- ❌ Which of the 4 rules are highest priority?

**User decision needed**:

- [ ] Apply to all 4 (maximize compliance, accept context cost)
- [ ] Apply to subset (e.g., just TDD rules, not testing/refactoring)
- [ ] Defer (current state acceptable, revisit if issues arise)

**Recommendation I can provide**:

- Data-driven suggestion based on violation frequency
- Prioritization by risk level
- Phased rollout approach (one rule at a time with validation)

---

### D6: When Is Investigation "Complete"?

**Context**: Investigation currently ~60% complete; remaining work is synthesis

**What I can provide objectively**:

- ✅ All discovery tasks complete
- ✅ All review tasks complete
- ✅ All rule improvements complete
- ✅ H1 validated, H2/H3 monitoring active
- ✅ Synthesis pending (~4-6 hours estimated)
- ✅ Final summary pending (~2 hours estimated)

**What I cannot objectively decide**:

- ❌ Is synthesis + summary sufficient for "complete"?
- ❌ Should all H2/H3 checkpoints be reached first?
- ❌ Is 80% compliance a "success" or "partial success"?
- ❌ What constitutes sufficient validation for recommendations?

**User decision needed**:

- [ ] Complete after synthesis + summary (accept current H2/H3 passive data)
- [ ] Complete after H2/H3 formal validation (wait for more checkpoints)
- [ ] Complete requires 90% compliance (not just documentation)

**Completion criteria I can document**:

- What artifacts exist
- What questions are answered
- What validation has occurred
- What follow-up work remains

---

## Decision-Making Pattern

For each decision point:

**What I provide**:

1. Objective data (measurements, costs, evidence)
2. Analysis (patterns, categorizations, comparisons)
3. Options (possible paths forward)
4. Recommendations (data-driven suggestions with rationale)

**What user decides**:

1. Value judgments ("good enough" thresholds)
2. Priority/effort tradeoffs
3. Acceptance of costs (context, time, complexity)
4. Completion criteria

---

## How to Use This Document

1. **During synthesis**: I'll flag new decision points as they arise
2. **User reviews**: Make decisions at natural checkpoints
3. **Document decisions**: Record user choice + rationale
4. **Proceed accordingly**: Continue work based on decisions

---

## Closed Decision Points

### D1: Accept 80% Compliance ✅

**Decision**: YES - Accept 80% and focus on other priorities

**Rationale**: Current improvement (+6-11 points) demonstrates effectiveness. Additional 10-point gap not worth extensive effort given diminishing returns.

**Impact**:

- Move to synthesis with current data
- Document 80% as successful outcome
- Apply findings to similar contexts

**Date**: 2025-10-16

---

### D2: Enforcement Patterns (Partial) ⏸️

**High-risk rules decision**: Explore alternative to alwaysApply

- Use combination of: custom slash commands + globs + intent routing
- Defer alwaysApply for these 4 rules
- **Action required**: Design alternative enforcement approach

**Medium-risk decision**: Improve routing for project-lifecycle, guidance-first

- Both have confirmed violations
- Intent routing improvements needed

**Low-risk decision**: Review case-by-case

- **Action required**: Per-rule assessment needed

**Date**: 2025-10-16

---

### D3: Validate H3 Formally ✅

**Decision**: Option 1 - Formally validate H3

**Rationale**: Want to measure query visibility impact formally

**Impact**:

- Continue monitoring 1-2 weeks for git operations
- Measure query → script compliance correlation
- Delay synthesis completion until validated

**Date**: 2025-10-16

---

### D4: Explore Prompt Templates ✅

**Decision**: Option 1 - Explore now

**Rationale**: Worth investigating as alternative to alwaysApply for high-risk rules

**Impact**:

- Design prompt templates approach (~4-6 hours)
- Test with real usage
- Validate effectiveness
- May provide scalable solution for high-risk rules (D2)

**Date**: 2025-10-16

---

### D5: Apply AlwaysApply to Both TDD Rules ✅

**Decision**: Apply to both TDD rules (tdd-first-js, tdd-first-sh)

**Rationale**:

- tdd-first-js: 17% measured non-compliance (strongest evidence)
- tdd-first-sh: Similar pattern, likely similar violation rate
- Logical pairing (same enforcement pattern)
- Defer testing/refactoring until prompt templates explored

**Impact**:

- Context cost: ~+4k tokens (~6% increase)
- Expected improvement: +6-11 points for TDD compliance (based on H1)
- Target: 83% → 90%+

**Date**: 2025-10-16

---

### D6: Investigation Completion Criteria ✅

**Decision**: Complete when all of the following are done:

1. H3 validated (1-2 weeks monitoring)
2. Prompt templates explored (~4-6 hours)
3. Synthesis written
4. Final summary complete

**Rationale**:

- D1: Accept 80% as sufficient (not pursuing 90% via extensive enforcement)
- D3: Validate H3 to complete the experimental design
- D4: Explore prompt templates as alternative enforcement
- Comprehensive documentation of findings and recommendations

**Date**: 2025-10-16

---

---

## MAJOR DISCOVERY: Cursor Hooks (2025-10-16)

**Platform feature missed during investigation**: `.cursor/hooks.json` - lifecycle-based automated enforcement

**Sources**:

- [Cursor Hooks Documentation](https://cursor.com/docs/agent/hooks)
- [Cursor Commands Documentation](https://cursor.com/docs/agent/chat/commands)
- [GitButler Hooks Deep Dive](https://blog.gitbutler.com/cursor-hooks-deep-dive)

**Capabilities discovered**:

- ✅ `afterFileEdit` hook - Run checks/scripts after any file edit
- ✅ `stop` hook - Run actions when agent stops
- ✅ Command blocking - Prevent sensitive commands
- ✅ Access controls - Restrict file/directory changes
- ✅ Prompt validation - Analyze prompts before processing
- ✅ Auto-documentation - Generate docs on edits
- ✅ Session logging - Record all activities

**Why this matters**:

- **Stronger than alwaysApply**: Automated enforcement vs relying on assistant awareness
- **Solves 80% → 90% gap**: Hooks can achieve near-100% compliance for deterministic checks
- **Scalable**: No context cost (runs scripts, doesn't load rule text)
- **Validates user intuition**: D2 decision to use "slash commands + globs + routing" aligns perfectly with hooks + commands pattern

**Impact on investigation**:

- 🔄 **All decisions need reconsideration** in light of hooks
- 🔄 **Pattern hierarchy revised**: Hooks are now strongest enforcement pattern
- 🔄 **Recommendations will change**: Critical/high-risk rules should use hooks, not alwaysApply

**Next steps**:

1. ✅ Update decision-points.md (this update)
2. ⏸️ Explore hooks capabilities in detail (create test hooks, validate functionality)
3. ⏸️ Revise all decisions D1-D6 based on hooks capabilities
4. ⏸️ Update synthesis with hooks as primary pattern
5. ⏸️ Create new action plan with hooks-first approach

---

**Status**: PAUSED for hooks exploration  
**Discovery date**: 2025-10-16  
**Action**: All decisions on hold pending hooks validation
