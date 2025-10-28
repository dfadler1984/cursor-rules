---
findingId: { { FINDING_ID } }
date: "{{DATE}}"
project: "{{PROJECT_SLUG}}"
severity: "{{SEVERITY}}"
status: "{{STATUS}}"
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: [{ { SOURCE_LOGS } }]
---

# Finding {{FINDING_ID}}: {{PATTERN_NAME}}

**Project**: {{PROJECT_SLUG}}  
**Severity**: {{SEVERITY}}  
**Status**: {{STATUS}}  
**Source Logs**: {{SOURCE_LOGS_DISPLAY}}

---

## Pattern

{{PATTERN_DESCRIPTION}}

<!--
Describe the pattern that was identified across multiple logs.
Examples:
- "TDD pre-edit gate triggers on 'editing' but not 'creating' new files"
- "Intent routing attaches guidance rules when implementation was requested"
- "Pre-send gate bypassed when specific rule combinations are loaded"
- "Changeset policy violations occur during manual PR creation"
-->

---

## Evidence

{{EVIDENCE_DESCRIPTION}}

**Supporting logs**:

- **{{LOG_REFERENCE_1}}**: {{LOG_EVIDENCE_1}}
- **{{LOG_REFERENCE_2}}**: {{LOG_EVIDENCE_2}}
- **{{LOG_REFERENCE_3}}**: {{LOG_EVIDENCE_3}}

**Key facts**:

- {{KEY_FACT_1}}
- {{KEY_FACT_2}}
- {{KEY_FACT_3}}

<!--
Reference specific logs and extract the key facts that support this pattern.
Be specific about what each log contributed to the pattern recognition.
Include quantifiable data where possible (timestamps, file counts, etc.)
-->

---

## Root Cause

{{ROOT_CAUSE_ANALYSIS}}

**Primary cause**: {{PRIMARY_CAUSE}}

**Contributing factors**:

- {{CONTRIBUTING_FACTOR_1}}
- {{CONTRIBUTING_FACTOR_2}}

**Why this happens**:
{{ROOT_CAUSE_EXPLANATION}}

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

**Effect on project**: {{PROJECT_IMPACT}}

**Effect on quality**: {{QUALITY_IMPACT}}

**Effect on compliance**: {{COMPLIANCE_IMPACT}}

**Quantified impact**:

- {{QUANTIFIED_IMPACT_1}}
- {{QUANTIFIED_IMPACT_2}}

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

1. {{IMMEDIATE_ACTION_1}}
2. {{IMMEDIATE_ACTION_2}}
3. {{IMMEDIATE_ACTION_3}}

**Long-term improvements**:

- {{LONG_TERM_IMPROVEMENT_1}}
- {{LONG_TERM_IMPROVEMENT_2}}

**Proposed changes**:

- **{{CHANGE_TARGET_1}}**: {{CHANGE_DESCRIPTION_1}}
- **{{CHANGE_TARGET_2}}**: {{CHANGE_DESCRIPTION_2}}

**Success criteria**:

- {{SUCCESS_CRITERION_1}}
- {{SUCCESS_CRITERION_2}}

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

- {{RELATED_FINDING_1}}: {{RELATIONSHIP_1}}
- {{RELATED_FINDING_2}}: {{RELATIONSHIP_2}}

**Relevant projects**:

- {{RELATED_PROJECT_1}}: {{PROJECT_RELATIONSHIP_1}}
- {{RELATED_PROJECT_2}}: {{PROJECT_RELATIONSHIP_2}}

**Rules affected**:

- {{AFFECTED_RULE_1}}: {{RULE_IMPACT_1}}
- {{AFFECTED_RULE_2}}: {{RULE_IMPACT_2}}

**Scripts affected**:

- {{AFFECTED_SCRIPT_1}}: {{SCRIPT_IMPACT_1}}
- {{AFFECTED_SCRIPT_2}}: {{SCRIPT_IMPACT_2}}

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

- {{STATUS_DATE_1}}: {{STATUS_UPDATE_1}}
- {{STATUS_DATE_2}}: {{STATUS_UPDATE_2}}

**Implementation progress**:

- [ ] {{IMPLEMENTATION_TASK_1}}
- [ ] {{IMPLEMENTATION_TASK_2}}
- [ ] {{IMPLEMENTATION_TASK_3}}

**Validation**:

- [ ] {{VALIDATION_TASK_1}}
- [ ] {{VALIDATION_TASK_2}}

<!--
Track the progress of implementing the recommendations.
Update this section as work progresses.
Mark tasks as completed and add new status updates.
-->

---

**Created**: {{CREATION_TIMESTAMP}}  
**Last updated**: {{LAST_UPDATED}}  
**Template version**: 1.0






