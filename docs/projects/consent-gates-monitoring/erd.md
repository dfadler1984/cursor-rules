---
status: active
owner: repo-maintainers
created: 2025-10-28
lastUpdated: 2025-10-28
---

# Engineering Requirements Document — Consent Gates Monitoring

Mode: Lite  
**Type**: Observational monitoring  
**Parent Project**: [consent-gates-refinement](../consent-gates-refinement/)

## 1. Introduction/Overview

Observational monitoring of consent gate mechanisms implemented in [consent-gates-refinement](../consent-gates-refinement/). This project tracks the deferred validation tasks that were marked as low-priority/observational during the parent project's early completion.

**Context**: consent-gates-refinement successfully implemented 5 consent mechanisms and validated slash commands in real sessions. Remaining validation tasks (natural language triggers, grant/revoke workflows, metrics collection) were deferred to organic usage. This project provides a lightweight framework for documenting observations as they occur naturally during normal work.

**Approach**: Passive observation, not active testing. Document consent gate behavior organically over 3-6 months. No dedicated monitoring period or metrics collection infrastructure.

## 2. Goals/Objectives

- Document organic observations of consent gate behavior during normal work
- Validate deferred features opportunistically (natural language triggers, grant/revoke workflows)
- Collect qualitative feedback on consent flow improvements
- Identify any unexpected issues or refinement opportunities
- Provide data for future consent gate iterations (if needed)

## 3. Functional Requirements

### 3.1 Observational Logging

1. Document consent gate observations as they occur naturally
2. Record instances of:
   - Natural language trigger usage ("show active allowlist")
   - Session allowlist grant/revoke workflows
   - Over-prompting or under-prompting incidents
   - Composite consent detection accuracy
   - State tracking confusion or resets
   - Category switch behavior

### 3.2 Opportunistic Validation

1. Test natural language triggers when convenient
2. Use grant/revoke workflows when standing consent needed
3. Note allowlist usage patterns informally
4. Track qualitative UX improvements

### 3.3 Issue Documentation

1. Document any consent gate issues in `monitoring/findings/`
2. Use standard finding template from parent project
3. Link to relevant consent mechanisms (risk tiers, composite consent, etc.)

## 4. Acceptance Criteria

**Lightweight completion criteria** (observational project):

- ✅ Monitoring structure created (`monitoring/findings/`, `monitoring/logs/`)
- ✅ At least one observation documented (even if "no issues observed")
- ✅ 3-6 months elapsed since parent project completion
- ✅ Qualitative assessment: consent flow better/same/worse

**Evidence of completion**:

- Findings documented (if any issues observed)
- Informal metrics noted (over-prompting frequency, allowlist usage)
- Recommendation: keep current implementation OR refine specific mechanisms

**Not required**:

- Formal metrics collection
- Quantitative before/after comparison
- Comprehensive test suite validation
- All deferred tasks completed

## 5. Risks/Edge Cases

### Risks

- **Low observation rate**: Consent gates may not be triggered frequently enough to gather meaningful data
  - Mitigation: Long monitoring period (3-6 months); even sparse data is useful
- **Observation bias**: Issues may go undocumented if not immediately recorded
  - Mitigation: Remind to document in `monitoring/findings/` when noticed
- **Changing behavior**: Implementation may evolve during monitoring period
  - Mitigation: Note version/date when documenting observations

### Edge Cases

- Natural language triggers not tested (if `/allowlist` command always used)
- Grant/revoke never exercised (if session allowlist not needed)
- No issues observed (positive outcome; document as "no concerns")

## 6. Rollout

**Start Date**: 2025-10-28  
**Monitoring Period**: 3-6 months (ends ~2026-01-28 to 2026-04-28)  
**Approach**: Passive observation during normal work

**Milestones**:

- **Month 1 (Nov 2025)**: Initial observations; test natural language triggers if convenient
- **Month 3 (Jan 2026)**: Mid-point check; assess if any patterns emerging
- **Month 6 (Apr 2026)**: Final assessment; decide completion or extension

**Completion Trigger**: 3-6 months elapsed + qualitative assessment complete

**Related Projects**:

- **Parent**: [consent-gates-refinement](../consent-gates-refinement/) — Implementation project (completed 2025-10-28)
- **See Also**: [rules-enforcement-investigation](../rules-enforcement-investigation/) — Ongoing rule execution monitoring

---

Owner: repo-maintainers  
Created: 2025-10-28  
Motivation: Track deferred observational validation from consent-gates-refinement completion
