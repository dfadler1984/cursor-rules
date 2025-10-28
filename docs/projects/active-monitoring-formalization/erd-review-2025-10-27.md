# ERD Review Session — 2025-10-27

**Purpose**: Gap analysis and ERD updates for active-monitoring-formalization  
**Participants**: User + Assistant  
**Outcome**: ERD updated with enforcement specification, decision tree details, and refined requirements

---

## Session Summary

Conducted comprehensive review of active-monitoring-formalization ERD to identify and address gaps before proceeding to task generation.

### Key Activities

1. **Current State Analysis**:

   - Reviewed ACTIVE-MONITORING.md structure (4 active monitoring projects)
   - Analyzed 35+ documented findings in rules-enforcement-investigation
   - Identified log types and patterns across monitoring projects

2. **Gap Identification**:

   - 6 gaps identified (Critical to Low priority)
   - Evidence gathered from existing monitoring logs
   - Decision tree pattern validated (works without prior art)

3. **ERD Updates**:
   - Added comprehensive Enforcement Specification (Section 8)
   - Expanded Decision Tree Structure (Section 6)
   - Refined Edge Cases and Staleness Criteria (Section 10)
   - Detailed Scripts Integration (Section 9)
   - Added Migration Plan (Section 12)
   - Resolved 7 open questions (Section 14)

---

## Gaps Addressed

### 1. Enforcement Mechanism Definition (Critical) ✅

**Gap**: ERD acknowledged origin from Gap #17/17b but didn't specify enforcement mechanism

**Resolution**:

- Added "Enforcement Specification" subsection to Section 8 (API/Contracts)
- Defined detection points: pre-documentation checkpoint, pre-send gate, post-documentation validation
- Specified violation responses: Missing OUTPUT → FAIL gate, wrong path → warning, missing entry → guide
- Assigned enforcement owners: Assistant (OUTPUT/gate), Scripts (validation), CI (structure)
- Included evidence: 35+ gaps show pattern works, OUTPUT visibility achieves 100% accountability

**Evidence Base**: Analysis of current monitoring revealed violations are execution failures, not detection failures

### 2. Decision Tree Specification (High Priority) ✅

**Gap**: Decision tree mentioned but structure/format not specified

**Resolution**:

- Added "Decision Tree Structure" subsection to Section 6 (Architecture/Design)
- Documented current implementation (ACTIVE-MONITORING.md lines 164-194) as proven pattern
- Included 4-question structure (lines 10-28) for categorization
- Provided edge case routing examples table (6 scenarios)
- Added validation evidence: Current tree achieves correct routing, 35+ findings successfully categorized
- Noted no prior art needed: web search found no Cursor Rules decision tree patterns; current implementation works

**Key Insight**: Simple conditional routing (pattern matching) sufficient; no ML/AI needed

### 3. Multi-Project Monitoring Mechanics (Medium Priority) ✅

**Gap**: Cross-reference mechanism for findings spanning multiple projects unclear

**Resolution**:

- Updated Edge Case #1 in Section 10 to remove "primary" project concept
- Added cross-reference format example (markdown snippet)
- Clarified multi-project threshold: 3+ projects referencing same finding → consider meta-project during review (not automatic)
- Emphasized noting relationships without hierarchy

**User Decision**: Don't designate "primary" project; just note relationships and details

### 4. Staleness Definition (Medium Priority) ✅

**Gap**: Conflicting time thresholds (30 days vs 60 days) and incomplete criteria

**Resolution**:

- Added "Staleness Criteria" subsection to Section 10
- Defined three staleness triggers: time-based (30 days no findings), duration-based (exceeded by 14+ days), status-based (Active but project Complete >30 days)
- Specified grace periods: 60-day for new monitoring, 30-day resets after findings, no checks while Paused
- Documented resolution options: extend, close, or pause

**Reconciliation**: 30-day threshold for findings gap, 60-day grace period for new monitoring

### 5. Template Integration with Scripts (Low Priority) ✅

**Gap**: Script integration mentioned but details missing

**Resolution**:

- Expanded "Scripts Integration" in Section 9 with detailed workflows
- Documented project-create.sh integration: `--enable-monitoring` flag, agent asks during creation
- Specified actions when enabled: create monitoring-protocol.md, add ACTIVE-MONITORING.md entry, create findings/, update README
- Added post-creation option: `monitoring-setup.sh` for existing projects
- Listed Phase 4 validation scripts: monitoring-validate-paths.sh, monitoring-detect-stale.sh, monitoring-validate-structure.sh

**User Decision**: Agent asks during project creation; script available for post-creation setup

### 6. Backward Compatibility (Low Priority) ✅

**Gap**: Migration strategy for existing monitored projects unclear

**Resolution**:

- Updated Phase 3 in Section 12 (Rollout Plan) to "Integration & Migration"
- Documented approach: Migrate to new standard (no backward compatibility)
- Created migration checklist: audit entries, verify fields, standardize patterns
- Assessed current projects: rules-enforcement (compliant), tdd-scope (compliant), consent-gates (acceptable), blocking-tdd (acceptable)
- Noted completed/archived projects require no action

**User Decision**: Migrate old to new; don't maintain backward compatibility

---

## Open Questions Resolved

1. **ACTIVE-MONITORING.md location** → Keep in docs/projects/ (current location)
2. **Concurrent monitoring limit** → 5 maximum (maintain focus)
3. **Finding format** → Flexible: ≤5-10 → single file, >10 → individual files
4. **Monitoring → investigation conversion** → >15 files triggers investigation-structure.mdc; no automatic conversion
5. **monitoring-history.md** → Yes, archive when ACTIVE-MONITORING.md exceeds 300 lines
6. **Archived project monitoring** → Remove monitoring, create new project if needed
7. **Version/changelog tracking** → Not needed (Git history sufficient)

**Remaining**: Template location, findings numbering scheme

---

## Current Monitoring Itemization

### Active Projects (4)

| Project                         | Duration   | Pattern                    | Volume | Finding Types                                            |
| ------------------------------- | ---------- | -------------------------- | ------ | -------------------------------------------------------- |
| blocking-tdd-enforcement        | 1 week     | Inline in README/tasks     | 13     | Violations, false positives, gate accuracy               |
| rules-enforcement-investigation | Continuous | gap-##-<name>.md (files)   | 35+    | Execution failures, structure issues, process violations |
| tdd-scope-boundaries            | 1 week     | issue-##-<name>.md (files) | TBD    | False negatives/positives, ambiguity, edge cases         |
| consent-gates-refinement        | 1-2 weeks  | Single file, ## Finding #N | TBD    | Over/under-prompting, allowlist, state tracking          |

### Completed/Paused (2)

| Project                    | Status   | Results                 |
| -------------------------- | -------- | ----------------------- |
| routing-optimization       | Archived | 100% accuracy achieved  |
| assistant-self-improvement | Paused   | Auto-logging deprecated |

### Log Type Analysis

**Most Common**: Execution failures (AlwaysApply rules ignored, gates bypassed, scripts unused)  
**Structural**: Investigation structure violations, file proliferation  
**Process**: Documentation-before-execution, changeset violations  
**Meta**: Finding documentation issues, self-improvement pattern violations

---

## Evidence-Based Insights

### What Works

- **Decision tree routing**: Current tree (lines 164-194) successfully categorizes all documented findings
- **Finding patterns**: Two patterns emerge naturally (individual files for deep analysis, single file for validation monitoring)
- **Categorization**: 4-question structure (What failed? Which project? Where document? Cross-reference?) effective

### What's Missing

- **Automated OUTPUT verification**: No check that assistant showed ACTIVE-MONITORING.md consultation
- **Path validation**: No detection of findings in wrong project
- **Entry validation**: No check for missing ACTIVE-MONITORING.md entries

### Key Finding

**Violations are execution failures, not detection failures**. The monitoring system correctly categorizes issues; enforcement gap is at documentation time (OUTPUT requirement not mechanically enforced).

---

## Next Steps

1. **Generate tasks from updated ERD** (two-phase flow: parent tasks → sub-tasks)
2. **Create templates** (monitoring-protocol, finding-document, review-checklist)
3. **Implement enforcement** (update self-improve.mdc OUTPUT requirement, assistant-behavior.mdc gate)
4. **Migration** (audit and update existing monitoring entries)

---

## Related

- **ERD**: [erd.md](./erd.md) — Updated requirements
- **ACTIVE-MONITORING.md**: [../ACTIVE-MONITORING.md](../ACTIVE-MONITORING.md) — Current implementation
- **Gap #17/17b**: Origin of this project (ACTIVE-MONITORING.md created without enforcement)






