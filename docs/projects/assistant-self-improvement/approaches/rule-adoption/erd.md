# Engineering Requirements Document: Self-Improvement Rule Adoption

**Status:** Draft  
**Created:** 2025-10-15  
**Owner:** @dfadler1984  
**Project:** `self-improvement-rule-adoption`

---

## Executive Summary

Adopt the [self_improve.mdc rule from claude-task-master](https://raw.githubusercontent.com/eyaltoledano/claude-task-master/refs/heads/main/.cursor/rules/self_improve.mdc) to enable pattern-based rule improvements while respecting consent-first behavior. This project integrates always-on observation with consent-gated actions, replacing the deprecated Assistant Learning Protocol with a lightweight, non-intrusive pattern detection system.

## Objectives

### Primary

1. Enable assistant to observe code patterns continuously without consent overhead
2. Surface rule improvement proposals at natural checkpoints only
3. Integrate pattern-recognition triggers into existing rule maintenance workflow
4. Establish evidence-based thresholds (3+ files) for proposing new rules

### Secondary

1. Create deprecation workflow for outdated patterns
2. Document when to add/modify/remove rules based on observed patterns
3. Provide structured proposal format (Pattern → Evidence → Change → Impact)
4. Enable session-scoped suppression of rejected proposals

## Scope

### In Scope

- Modify `assistant-behavior.mdc` to add "Pattern observation" and "Rule improvement proposals" sections
- Extend `rule-maintenance.mdc` with pattern-driven update triggers
- Extend `rule-creation.mdc` with evidence-based creation criteria
- Extend `rule-quality.mdc` with pattern-based validation checks
- Add `self-improve.mdc` as always-applied rule with repo-specific adaptations
- Create pivot project for tracking alternative approaches if always-on proves problematic

### Out of Scope

- Automated rule updates without consent (remains consent-gated)
- Logging infrastructure or persistent storage of observations (passive only)
- Cross-session pattern memory (observations reset each session)
- Integration with external documentation or web research for rule suggestions

### Constraints

- Must not break consent-first behavior (no actions without approval)
- Must not interrupt mid-task (proposals only at checkpoints)
- Must respect TDD cycle boundaries (no proposals during Red → Green)
- Must integrate with existing rule structure (front matter, globs, health scores)

## Success Criteria

### Must Have

1. **Non-intrusive observation**

   - Pattern detection runs silently during normal work
   - No tool calls, logs, or files created without consent
   - Validation: Complete 3 tasks without any unsolicited pattern interruptions

2. **High-signal proposals**

   - Only patterns appearing 3+ times trigger proposals
   - Proposals surface at task completion, tests passing, or PR ready
   - Validation: Manually introduce duplicate pattern across 4 files; verify proposal appears at checkpoint

3. **Consent-gated action**

   - All rule updates require explicit "Yes"/"Proceed"
   - Rejected proposals do not re-appear same session
   - Validation: Reject a proposal; verify no re-prompt for same pattern

4. **Integration with existing rules**
   - `rule-maintenance.mdc`, `rule-creation.mdc`, `rule-quality.mdc` updated
   - `assistant-behavior.mdc` includes new sections
   - `self-improve.mdc` created with `alwaysApply: true`
   - Validation: Run `.cursor/scripts/rules-validate.sh --fail-on-missing-refs`

### Should Have

1. **Structured proposal format**

   - Pattern (one line), Evidence (file paths), Proposed change, Impact
   - Examples cite real code from observed files
   - Validation: Trigger proposal; verify includes all 4 fields

2. **Deprecation workflow**

   - Outdated patterns marked deprecated in rules
   - Migration paths documented
   - Cross-references updated
   - Validation: Deprecate one pattern; verify references updated

3. **Checkpoint detection**
   - Natural boundaries: after Green, PR created, task complete, "anything else?"
   - Never mid-edit, mid-test, mid-refactor
   - Validation: Introduce pattern during TDD Red phase; verify no proposal until Green

### Could Have

1. Evidence links to commit SHAs or PR numbers when patterns span multiple changes
2. Batch multiple proposals (e.g., 3 patterns observed → present all at once at checkpoint)
3. Proposal summary in PR descriptions ("This PR addresses pattern X observed in N files")

## Technical Design

### Pattern Observation (Always-On, Passive)

**Trigger conditions:**

- New code pattern in 3+ files
- Repeated implementations across 2+ features
- Common error pattern addressed in 3+ fixes
- New library used consistently in 3+ modules
- Recurring feedback in 3+ clarifications or reviews

**Internal state (session-scoped):**

```typescript
interface PatternObservation {
  pattern: string; // e.g., "yargs for CLI arg parsing"
  files: string[]; // e.g., ["cli/summary.js", "cli/validate.js", ...]
  type:
    | "new-pattern"
    | "repeated-impl"
    | "error-pattern"
    | "new-library"
    | "feedback";
  sessionSuppressed: boolean; // true if user rejected this session
}
```

**No persistence:** Observations reset at session boundary; no logs or files created.

### Proposal Surface (Consent-Gated, Checkpointed)

**Natural checkpoints:**

1. After Green in TDD cycle (tests passing)
2. After PR created (via `.cursor/scripts/pr-create.sh`)
3. After task marked complete (via `todo_write` with status: completed)
4. When user asks "anything else?" or similar wrap-up phrase

**Proposal format:**

```markdown
Pattern detected: <one-line description>
Evidence: <file paths or commit refs>
Proposed change: <add/modify/deprecate rule X>
Impact: <who benefits, what improves>

Proceed with rule update?
```

**User responses:**

- "Yes"/"Proceed"/"Go ahead" → create/update rule with evidence
- "No"/"Skip"/"Not now" → suppress for session; do not re-ask
- Silence (no response) → drop; do not re-ask

### Rule Modifications

**`assistant-behavior.mdc`:**

- Add "Pattern observation (always-on)" section after "Status transparency"
- Add "Rule improvement proposals (consent-gated)" section
- Update "Compliance-first send gate" to include pattern observation check

**`rule-maintenance.mdc`:**

- Add "Pattern-driven updates" section with 3+ file threshold
- Document proposal workflow (collect → surface → approve → update)

**`rule-creation.mdc`:**

- Add "Evidence-based rule creation" section
- Require ≥3 instances of pattern for proposals
- Mandate real file citations in examples

**`rule-quality.mdc`:**

- Add checklist items:
  - Examples cite real file paths
  - Pattern-based rules triggered by ≥3 instances
  - Deprecation path documented if replacing old pattern

**New `self-improve.mdc`:**

- Adapted from taskmaster rule
- Add consent-first modifications
- Mark `alwaysApply: true`
- Include repo-specific examples

### Pivot Tracking Project

**Purpose:** Track alternative approaches if always-on observation proves problematic.

**Pivot triggers:**

1. Pattern observation adds measurable latency (>200ms per turn)
2. False positives exceed 50% (proposals user rejects as noise)
3. Observation state bloats context (>10% of token budget)
4. User feedback indicates distraction or annoyance

**Alternative approaches (documented in pivot project):**

1. Manual-invoke only (slash command `/rule-improve`)
2. Checkpoint-gated observation (only scan at boundaries, not continuously)
3. Hybrid: always-on for high-signal only (errors, security), manual for patterns
4. Batch mode: weekly/monthly rule review sessions instead of per-task

## Risks & Mitigations

| Risk                                      | Likelihood | Impact | Mitigation                                                  |
| ----------------------------------------- | ---------- | ------ | ----------------------------------------------------------- |
| Always-on observation adds latency        | Low        | Medium | Session-scoped state only; no I/O during observation        |
| Pattern detection creates false positives | Medium     | Low    | 3+ file threshold; high signal-to-noise ratio               |
| Proposals interrupt critical workflows    | Low        | High   | Checkpoint-only surfacing; never mid-task                   |
| Observations bloat context budget         | Low        | Medium | Drop observations if context >80%; pivot to manual-invoke   |
| Conflicts with consent-first behavior     | Low        | High   | All actions consent-gated; observation is passive read-only |

## Dependencies

- Existing rule infrastructure (`rules-validate.sh`, front matter standards)
- Intent routing (`intent-routing.mdc`) for detecting checkpoints
- Project lifecycle (`project-lifecycle.mdc`) for task completion signals
- TDD cycle detection (`tdd-first.mdc`) for Green checkpoint

## Acceptance Criteria

### Phase 1: Rule Integration (Blocking)

- [ ] `assistant-behavior.mdc` includes "Pattern observation" and "Rule improvement proposals" sections
- [ ] `rule-maintenance.mdc` includes "Pattern-driven updates" section
- [ ] `rule-creation.mdc` includes "Evidence-based rule creation" section
- [ ] `rule-quality.mdc` checklist updated with pattern-based items
- [ ] `self-improve.mdc` created with `alwaysApply: true` and consent modifications
- [ ] All modified rules pass `.cursor/scripts/rules-validate.sh`

### Phase 2: Behavior Validation (Blocking)

- [ ] Complete 3 tasks without unsolicited mid-task pattern interruptions
- [ ] Introduce duplicate pattern in 4 files; verify proposal surfaces at checkpoint
- [ ] Reject a proposal; verify no re-prompt for same pattern in session
- [ ] Trigger proposal during TDD Red phase; verify delayed until Green
- [ ] Verify proposal includes Pattern, Evidence, Proposed change, Impact

### Phase 3: Pivot Project Setup (Blocking)

- [ ] Create `docs/projects/self-improvement-pivot/erd.md` with alternative approaches
- [ ] Document pivot triggers (latency, false positives, context bloat, user feedback)
- [ ] Link pivot project to this ERD for easy reference

### Phase 4: Monitoring & Iteration (Non-Blocking)

- [ ] Track proposal acceptance rate over 10 tasks (target: >50%)
- [ ] Monitor observation overhead (target: <100ms per turn)
- [ ] Collect user feedback on proposal timing and relevance
- [ ] If pivot triggers fire, activate pivot project and adjust approach

## Open Questions

1. **Observation granularity:** Should we detect patterns at file-level, function-level, or line-level?
   - **Proposed:** File-level for simplicity; function-level if false positives are high
2. **Batch proposals:** Present all observed patterns at once, or one at a time?
   - **Proposed:** One at a time to avoid overwhelming; batch if >3 patterns detected
3. **Cross-session persistence:** Should rejected patterns persist across sessions?
   - **Proposed:** No; session-scoped only to avoid stale suppressions
4. **Integration with code reviews:** Should patterns from PR comments trigger proposals?
   - **Proposed:** Out of scope for MVP; revisit in Phase 4

## References

- Taskmaster self_improve.mdc: [https://raw.githubusercontent.com/eyaltoledano/claude-task-master/refs/heads/main/.cursor/rules/self_improve.mdc](https://raw.githubusercontent.com/eyaltoledano/claude-task-master/refs/heads/main/.cursor/rules/self_improve.mdc)
- Deprecated Assistant Learning Protocol: `docs/projects/assistant-self-improvement/legacy/`
- Consent-first behavior: `.cursor/rules/assistant-behavior.mdc`
- Rule maintenance: `.cursor/rules/rule-maintenance.mdc`
- Rule creation: `.cursor/rules/rule-creation.mdc`
- Rule quality: `.cursor/rules/rule-quality.mdc`

## Related Projects

- `assistant-self-improvement` (parent; this replaces deprecated ALP)
- `self-improvement-pivot` (tracking alternative approaches if needed)
- `rules-enforcement-investigation` (understanding why rules aren't followed)
