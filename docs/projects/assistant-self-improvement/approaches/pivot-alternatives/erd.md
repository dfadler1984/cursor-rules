# Engineering Requirements Document: Self-Improvement Pivot

**Status:** Deferred  
**Created:** 2025-10-15  
**Owner:** @dfadler1984  
**Project:** `self-improvement-pivot`  
**Parent Project:** [`self-improvement-rule-adoption`](../self-improvement-rule-adoption/erd.md)

---

## Executive Summary

This project tracks alternative approaches to pattern-based rule improvement if the always-on observation model proves problematic. It serves as a contingency plan with pre-designed pivots, activated only if specific triggers fire during Phase 4 monitoring of the parent project.

## Objectives

### Primary

1. Document alternative self-improvement approaches with different trade-offs
2. Define clear pivot triggers (latency, false positives, context bloat, user feedback)
3. Provide ready-to-implement designs for each alternative
4. Enable rapid pivot without design delays

### Secondary

1. Compare trade-offs across approaches (consent overhead vs noise vs context cost)
2. Validate pivot triggers are measurable and actionable
3. Document rollback path if pivot fails

## Scope

### In Scope

- Four alternative approaches: manual-invoke, checkpoint-gated, hybrid, batch
- Pivot trigger definitions with measurable thresholds
- Implementation designs for each alternative
- Comparison matrix (consent overhead, latency, false positives, context cost)

### Out of Scope

- Implementation of alternatives (deferred until pivot trigger fires)
- User testing of alternatives (only implemented after pivot)
- Cross-session pattern persistence (remains out of scope for all approaches)

### Constraints

- All alternatives must respect consent-first behavior
- All alternatives must integrate with existing rule infrastructure
- Pivot must be reversible (can return to always-on if alternative fails)

## Success Criteria

### Must Have

1. **Clear pivot triggers**

   - Measurable thresholds defined
   - Automated detection where possible
   - Validation: Review triggers with stakeholder; confirm actionable

2. **Ready-to-implement designs**

   - Each alternative has technical design section
   - Rule modifications documented
   - Acceptance criteria defined
   - Validation: Pick one alternative; estimate implementation time <2 hours

3. **Trade-off comparison**
   - Matrix comparing consent overhead, latency, false positives, context cost
   - Recommendations for which alternative to try first based on trigger type
   - Validation: Stakeholder confirms comparison is clear and useful

### Should Have

1. Rollback plan if pivot fails (revert to always-on)
2. Hybrid combinations (e.g., manual-invoke + checkpoint-gated for different pattern types)
3. Metrics to track whether pivot succeeded (compared to original)

### Could Have

1. A/B testing framework to compare approaches
2. User preference settings (choose your own observation mode)
3. Gradual rollout (checkpoint-gated for new patterns, always-on for established)

## Pivot Triggers

### 1. Latency Overhead

**Trigger:** Pattern observation adds >200ms to assistant response time (measured over 10 turns).

**Measurement:**

- Baseline: average response time without observation over 10 turns
- With observation: average response time with always-on observation over 10 turns
- If delta >200ms, activate pivot

**Recommended alternative:** Checkpoint-gated observation (only scan at boundaries, not continuously)

**Rationale:** Checkpoint-gated reduces per-turn overhead by limiting scanning to discrete moments.

### 2. False Positive Rate

**Trigger:** >50% of proposals rejected as noise (measured over 10 proposals).

**Measurement:**

- Track proposals surfaced over 10 tasks
- Count rejections (user says "No"/"Skip" or ignores)
- If rejection rate >50%, activate pivot

**Recommended alternative:** Manual-invoke only (slash command `/rule-improve`)

**Rationale:** Manual-invoke eliminates false positives by only scanning when user explicitly requests pattern analysis.

### 3. Context Bloat

**Trigger:** Observation state consumes >10% of token budget (measured per turn).

**Measurement:**

- Track token count of pattern observation state
- Compare to total context token count
- If observation / total >10%, activate pivot

**Recommended alternative:** Hybrid (always-on for high-signal only, manual for rest)

**Rationale:** Hybrid limits always-on to critical patterns (errors, security) and defers low-priority patterns to manual scans.

### 4. User Distraction

**Trigger:** User reports proposals are distracting or interrupt workflow.

**Measurement:**

- Qualitative feedback during Phase 4 monitoring
- User explicitly states proposals are problematic

**Recommended alternative:** Batch mode (weekly/monthly rule review sessions)

**Rationale:** Batch mode consolidates proposals into dedicated review sessions, avoiding mid-workflow interruptions.

## Alternative Approaches

### Alternative 1: Manual-Invoke Only

**Design:**

- User triggers pattern analysis via slash command: `/rule-improve`
- Assistant scans entire codebase (or specified paths) for patterns
- Surfaces all detected patterns (no 3+ file threshold, show all)
- User selects which patterns to convert to rule updates

**Pros:**

- Zero false positives (user explicitly requests)
- No latency overhead during normal work
- No context bloat (state only exists during scan)

**Cons:**

- Requires user to remember to trigger
- May miss patterns if user doesn't invoke
- Higher consent overhead (must invoke manually)

**Rule modifications:**

- `assistant-behavior.mdc`: Remove "Pattern observation (always-on)"; keep "Rule improvement proposals (consent-gated)"
- `self-improve.mdc`: Change trigger from always-on to slash command
- Add `/rule-improve` to `intent-routing.mdc` slash commands

**Acceptance criteria:**

- [ ] `/rule-improve` scans codebase and surfaces all patterns (no threshold)
- [ ] User can specify paths: `/rule-improve src/cli`
- [ ] Proposals include file paths and pattern examples
- [ ] User can approve/reject each proposal individually

---

### Alternative 2: Checkpoint-Gated Observation

**Design:**

- No continuous observation during work
- At natural checkpoints (Green, PR created, task complete), assistant scans changed files for patterns
- Surface proposals immediately if patterns detected
- Session-scoped suppression for rejected patterns

**Pros:**

- Lower latency overhead (scan once per checkpoint, not per turn)
- Reduces false positives (only scans relevant changed files)
- Still automatic (no manual invoke needed)

**Cons:**

- May miss patterns spanning unchanged files
- Slightly delayed detection (only at checkpoints)
- Context bloat if many files changed

**Rule modifications:**

- `assistant-behavior.mdc`: Change "Pattern observation (always-on)" to "Pattern observation (checkpoint-gated)"
- `self-improve.mdc`: Add checkpoint detection logic (detect Green, PR created, task complete)
- No changes to proposal format or consent flow

**Acceptance criteria:**

- [ ] No scanning during normal work (only at checkpoints)
- [ ] Scan detects patterns in files changed since last checkpoint
- [ ] Proposals surface immediately after checkpoint if patterns detected
- [ ] Latency overhead <100ms per checkpoint scan

---

### Alternative 3: Hybrid (High-Signal Always-On, Manual for Rest)

**Design:**

- Always-on observation for high-signal patterns only:
  - Error patterns (same bug fixed 3+ times)
  - Security patterns (auth/crypto used inconsistently)
  - Performance patterns (same perf fix applied 3+ times)
- Manual-invoke for low-priority patterns:
  - Code style
  - Library choices
  - Naming conventions

**Pros:**

- Balances automatic detection (critical patterns) with manual control (nice-to-haves)
- Lower context cost (only track high-signal patterns)
- Reduces false positives (low-priority patterns require manual scan)

**Cons:**

- More complex implementation (two detection paths)
- Requires defining "high-signal" pattern taxonomy
- User must remember to invoke for low-priority patterns

**Rule modifications:**

- `assistant-behavior.mdc`: Add "High-signal pattern observation (always-on)" and "Low-priority pattern analysis (manual-invoke)"
- `self-improve.mdc`: Define high-signal pattern taxonomy (errors, security, performance)
- Add `/rule-improve --low-priority` for manual scans

**Acceptance criteria:**

- [ ] Always-on detects error/security/performance patterns only
- [ ] Manual `/rule-improve --low-priority` scans for style/library/naming patterns
- [ ] Context cost <5% of token budget (high-signal patterns only)
- [ ] High-signal proposals surface at checkpoints; low-priority on manual invoke

---

### Alternative 4: Batch Mode (Weekly/Monthly Review Sessions)

**Design:**

- No observation during normal work (pattern tracking disabled)
- User schedules dedicated rule review sessions (e.g., weekly, monthly)
- During session, assistant scans entire codebase for all patterns
- User approves batch of rule updates in one sitting

**Pros:**

- Zero workflow interruption (proposals only in dedicated sessions)
- Zero latency overhead during normal work
- Zero context bloat outside sessions
- Comprehensive scan (not limited to changed files or thresholds)

**Cons:**

- Patterns not detected until next review session (delayed)
- Higher consent overhead (dedicated session time)
- May detect too many patterns in one session (overwhelming)

**Rule modifications:**

- `assistant-behavior.mdc`: Remove "Pattern observation (always-on)"; add "Rule review sessions (scheduled)"
- `self-improve.mdc`: Add batch scan mode
- Add `/rule-review-session` slash command to initiate session

**Acceptance criteria:**

- [ ] No pattern detection during normal work
- [ ] `/rule-review-session` scans entire codebase for all patterns
- [ ] Session surfaces all patterns (no threshold) with priority ranking
- [ ] User can approve/reject/defer each pattern
- [ ] Session summarizes approved updates at end

---

## Comparison Matrix

| Approach                | Consent Overhead                               | Latency                 | False Positives         | Context Cost            | Best For                                |
| ----------------------- | ---------------------------------------------- | ----------------------- | ----------------------- | ----------------------- | --------------------------------------- |
| **Always-On (Current)** | Low (checkpoints only)                         | Medium (per turn)       | Medium (3+ threshold)   | Medium (session state)  | Balanced; good default                  |
| **Manual-Invoke**       | High (explicit trigger)                        | None (during work)      | None (user requests)    | None (outside scan)     | Low tolerance for interruptions         |
| **Checkpoint-Gated**    | Low (checkpoints only)                         | Low (checkpoint only)   | Low (changed files)     | Low (scan state only)   | Latency-sensitive; frequent checkpoints |
| **Hybrid**              | Medium (high-signal auto, low-priority manual) | Low (high-signal only)  | Low (taxonomy filters)  | Low (high-signal only)  | Critical patterns auto, rest manual     |
| **Batch Mode**          | High (dedicated sessions)                      | None (outside sessions) | None (user reviews all) | None (outside sessions) | Infrequent, comprehensive reviews       |

## Rollback Plan

If any pivot alternative fails to improve upon the original always-on approach:

1. **Measure same metrics** (latency, false positive rate, context cost, user feedback)
2. **Compare to baseline** (original always-on approach from parent project Phase 4)
3. **If alternative is worse:**
   - Revert `assistant-behavior.mdc`, `self-improve.mdc`, and related rules to always-on versions
   - Document why alternative failed in this ERD
   - Try next recommended alternative based on trigger type
4. **If all alternatives fail:**
   - Revert to always-on with refined thresholds (e.g., 4+ files instead of 3+)
   - Document lessons learned
   - Consider out-of-scope options (cross-session persistence, A/B testing)

## Open Questions

1. **Trigger sensitivity:** Are 200ms latency and 50% false positive thresholds appropriate?
   - **Proposed:** Start with these; adjust based on Phase 4 data
2. **Multi-trigger scenarios:** What if latency and false positives both exceed thresholds?
   - **Proposed:** Try hybrid first (addresses both); if fails, try batch mode
3. **Gradual rollout:** Should we A/B test alternatives before full pivot?
   - **Proposed:** Out of scope for MVP; single-track pivot for simplicity
4. **User choice:** Should users pick their preferred observation mode?
   - **Proposed:** Out of scope for MVP; single canonical mode per pivot

## References

- Parent project: [`docs/projects/self-improvement-rule-adoption/erd.md`](../self-improvement-rule-adoption/erd.md)
- Consent-first behavior: `.cursor/rules/assistant-behavior.mdc`
- Intent routing (slash commands): `.cursor/rules/intent-routing.mdc`
- Deprecated Assistant Learning Protocol: `docs/projects/assistant-self-improvement/legacy/`

## Related Projects

- `self-improvement-rule-adoption` (parent; this is the contingency plan)
- `assistant-self-improvement` (grandparent; historical context)
