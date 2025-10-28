---
findingId: 24
date: "2025-10-28"
project: "rules-enforcement-investigation"
severity: "high"
status: "open"
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: ["003"]
---

# Finding 24: cursor-hooks-global-only-limitation

**Project**: rules-enforcement-investigation  
**Severity**: high  
**Status**: open  
**Source Logs**: 003

---

## Pattern

[Describe the pattern that was identified across multiple logs]

<!-- 
Examples:
- "TDD pre-edit gate triggers on 'editing' but not 'creating' new files"
- "Intent routing attaches guidance rules when implementation was requested"
- "Pre-send gate bypassed when specific rule combinations are loaded"
- "Changeset policy violations occur during manual PR creation"
-->

---

## Evidence

[References to specific logs, with key facts]

**Supporting logs**:
- **log-003**: [Key fact from this log]

**Key facts**:
- [Key fact 1]
- [Key fact 2]
- [Key fact 3]

<!-- 
Reference specific logs and extract the key facts that support this pattern.
Be specific about what each log contributed to the pattern recognition.
Include quantifiable data where possible (timestamps, file counts, etc.)
-->

---

## Root Cause

[Analysis of why this pattern occurs]

**Primary cause**: [Main underlying reason]

**Contributing factors**:
- [Contributing factor 1]
- [Contributing factor 2]

**Why this happens**:
[Detailed explanation of the underlying mechanism]

<!-- 
Analysis of why this pattern occurs. Dig into the underlying reasons.
Examples:
- Rule text ambiguity ("editing" vs "creating")
- Missing enforcement mechanism (OUTPUT requirement not enforced)
- Timing issues (rule loaded after gate should trigger)
- Configuration conflicts (multiple rules with overlapping scope)
- Process gaps (manual steps bypassing automation)
-->

---

## Impact

**Effect on project**: [Impact on this specific project]

**Effect on quality**: [Impact on overall system quality]

**Effect on compliance**: [Impact on rule compliance]

**Quantified impact**:
- [Quantified impact 1]
- [Quantified impact 2]

<!-- 
Assess the impact of this pattern on the project and broader system.
Examples:
- "13 TDD violations documented despite gate deployment"
- "95% of findings documented in wrong project before routing fix"
- "Average time to identify pattern: 5 days vs 1 day with better logging"
- "User correction required in 15% of routing decisions"
-->

---

## Recommendation

**Immediate actions**:
1. [Immediate action 1]
2. [Immediate action 2]
3. [Immediate action 3]

**Long-term improvements**:
- [Long-term improvement 1]
- [Long-term improvement 2]

**Proposed changes**:
- **[Change target 1]**: [Change description 1]
- **[Change target 2]**: [Change description 2]

**Success criteria**:
- [Success criterion 1]
- [Success criterion 2]

<!-- 
Specific, actionable recommendations to address the root cause.
Include both immediate fixes and longer-term improvements.
Examples:
- "Update assistant-behavior.mdc line 290: change 'editing' to 'creating or editing'"
- "Add file pairing validation to TDD pre-edit gate"
- "Implement OUTPUT requirement enforcement in pre-send gate"
- "Create monitoring-validate-paths.sh to detect wrong-project findings"
-->

---

## Related

**Other findings**:
- [Related finding 1]: [Relationship description]
- [Related finding 2]: [Relationship description]

**Relevant projects**:
- [Related project 1]: [Project relationship]
- [Related project 2]: [Project relationship]

**Rules affected**:
- [Affected rule 1]: [Rule impact]
- [Affected rule 2]: [Rule impact]

**Scripts affected**:
- [Affected script 1]: [Script impact]
- [Affected script 2]: [Script impact]

<!-- 
Link to related findings, projects, rules, and scripts.
Show how this finding connects to the broader system.
Examples:
- "Related to Finding #3: Both involve TDD gate scope issues"
- "Affects rules-enforcement-investigation: This pattern is what they monitor"
- "Impacts assistant-behavior.mdc: Core enforcement mechanism"
- "Requires update to git-commit.sh: Must handle new changeset policy"
-->

---

## Resolution Tracking

**Status updates**:
- 2025-10-28: Finding created

**Implementation progress**:
- [ ] [Implementation task 1]
- [ ] [Implementation task 2]
- [ ] [Implementation task 3]

**Validation**:
- [ ] [Validation task 1]
- [ ] [Validation task 2]

<!-- 
Track the progress of implementing the recommendations.
Update this section as work progresses.
Mark tasks as completed and add new status updates.
-->

---

**Created**: 2025-10-28 04:22:11 UTC  
**Last updated**: 2025-10-28 04:22:11 UTC  
**Template version**: 1.0
