# Monitoring Review Checklist — {{PROJECT_SLUG}}

**Review Date**: {{REVIEW_DATE}}  
**Reviewer**: {{REVIEWER_NAME}}  
**Review Period**: {{REVIEW_PERIOD_START}} to {{REVIEW_PERIOD_END}}  
**Review Type**: {{REVIEW_TYPE}}

---

## Review Summary

**Logs reviewed**: {{LOGS_COUNT}} logs  
**Findings reviewed**: {{FINDINGS_COUNT}} findings  
**New patterns identified**: {{NEW_PATTERNS_COUNT}}  
**Actions required**: {{ACTIONS_REQUIRED_COUNT}}

---

## Log Review

### Logs Status

- [ ] **All logs reviewed**: {{LOGS_REVIEWED_COUNT}} of {{LOGS_TOTAL_COUNT}}
- [ ] **Unreviewed logs identified**: {{UNREVIEWED_LOGS_LIST}}
- [ ] **Patterns emerging**: {{EMERGING_PATTERNS_COUNT}} patterns across {{PATTERN_LOG_COUNT}} logs

### Log Quality Assessment

- [ ] **Observations factual**: Logs contain objective descriptions without interpretation
- [ ] **System state captured**: Rules loaded, gates triggered, files involved documented
- [ ] **Raw data complete**: Timestamps, commands, error messages, quantifiable data present
- [ ] **Context sufficient**: Work context and related logs referenced appropriately

### Pattern Recognition

**Patterns identified this review**:

1. **{{PATTERN_1_NAME}}**: Observed in logs {{PATTERN_1_LOGS}} ({{PATTERN_1_COUNT}} instances)
2. **{{PATTERN_2_NAME}}**: Observed in logs {{PATTERN_2_LOGS}} ({{PATTERN_2_COUNT}} instances)
3. **{{PATTERN_3_NAME}}**: Observed in logs {{PATTERN_3_LOGS}} ({{PATTERN_3_COUNT}} instances)

**Patterns requiring findings**:

- [ ] {{PATTERN_REQUIRING_FINDING_1}} → Create finding-{{NEXT_FINDING_ID}}
- [ ] {{PATTERN_REQUIRING_FINDING_2}} → Create finding-{{NEXT_FINDING_ID_2}}

---

## Finding Review

### Findings Status

- [ ] **All findings reviewed**: {{FINDINGS_REVIEWED_COUNT}} of {{FINDINGS_TOTAL_COUNT}}
- [ ] **Finding status updated**: Open/In-Progress/Resolved status current
- [ ] **Source logs verified**: All referenced logs exist and support findings

### Finding Quality Assessment

**Per finding checklist**:

**Finding {{FINDING_ID_1}}: {{FINDING_NAME_1}}**

- [ ] Pattern clearly described
- [ ] Evidence references specific logs with facts
- [ ] Root cause analysis complete
- [ ] Impact assessment quantified
- [ ] Recommendations actionable and specific
- [ ] Related items properly linked
- [ ] Status reflects current state

**Finding {{FINDING_ID_2}}: {{FINDING_NAME_2}}**

- [ ] Pattern clearly described
- [ ] Evidence references specific logs with facts
- [ ] Root cause analysis complete
- [ ] Impact assessment quantified
- [ ] Recommendations actionable and specific
- [ ] Related items properly linked
- [ ] Status reflects current state

### Finding Actions Required

**Immediate actions**:

- [ ] {{IMMEDIATE_ACTION_1}}
- [ ] {{IMMEDIATE_ACTION_2}}

**Follow-up actions**:

- [ ] {{FOLLOW_UP_ACTION_1}}
- [ ] {{FOLLOW_UP_ACTION_2}}

---

## Monitoring Health

### Activity Assessment

- [ ] **Logging frequency appropriate**: {{LOGS_PER_WEEK}} logs/week (target: {{TARGET_LOGS_PER_WEEK}})
- [ ] **Finding conversion rate**: {{CONVERSION_RATE}}% logs → findings (target: >80%)
- [ ] **Review compliance**: {{REVIEW_COMPLIANCE}}% items reviewed within 30 days (target: >90%)

### Staleness Check

- [ ] **No stale logs**: All logs reviewed within staleness threshold ({{STALENESS_DAYS}} days)
- [ ] **No stale findings**: All findings reviewed within staleness threshold ({{STALENESS_DAYS}} days)
- [ ] **Monitoring duration check**: {{DAYS_ACTIVE}} days active (planned: {{PLANNED_DURATION}})

### Configuration Validation

- [ ] **YAML entry current**: `active-monitoring.yaml` reflects actual monitoring state
- [ ] **Paths correct**: logsPath and findingsPath match actual directory structure
- [ ] **Scope accurate**: Monitoring scope matches actual observations
- [ ] **Cross-references valid**: Referenced projects exist and are correctly linked

---

## Effectiveness Assessment

### Success Criteria Progress

**Original success criteria**:

1. **{{SUCCESS_CRITERION_1}}**: {{SUCCESS_PROGRESS_1}}
2. **{{SUCCESS_CRITERION_2}}**: {{SUCCESS_PROGRESS_2}}
3. **{{SUCCESS_CRITERION_3}}**: {{SUCCESS_PROGRESS_3}}

### Monitoring Value

- [ ] **Issues detected**: {{ISSUES_DETECTED_COUNT}} issues identified that would have been missed
- [ ] **Patterns recognized**: {{PATTERNS_RECOGNIZED_COUNT}} patterns identified for improvement
- [ ] **Actions taken**: {{ACTIONS_TAKEN_COUNT}} recommendations implemented
- [ ] **System improvements**: {{IMPROVEMENTS_COUNT}} system improvements from findings

### ROI Assessment

**Time invested**: {{TIME_INVESTED}} hours  
**Issues prevented**: {{ISSUES_PREVENTED_COUNT}} estimated issues  
**Quality improvement**: {{QUALITY_IMPROVEMENT_DESCRIPTION}}

---

## Recommendations

### Continue Monitoring

- [ ] **Monitoring still valuable**: New patterns emerging, success criteria not met
- [ ] **Extend duration**: Recommend extending to {{RECOMMENDED_END_DATE}}
- [ ] **Adjust scope**: Recommend scope changes: {{SCOPE_ADJUSTMENTS}}

### Close Monitoring

- [ ] **Success criteria met**: All original objectives achieved
- [ ] **No new patterns**: Pattern recognition plateau reached
- [ ] **Monitoring complete**: Recommend closing on {{RECOMMENDED_CLOSE_DATE}}

### Monitoring Adjustments

**Scope changes**:

- **Add to scope**: {{ADD_TO_SCOPE}}
- **Remove from scope**: {{REMOVE_FROM_SCOPE}}
- **Cross-reference updates**: {{CROSS_REFERENCE_UPDATES}}

**Process improvements**:

- **Logging process**: {{LOGGING_IMPROVEMENTS}}
- **Review frequency**: {{REVIEW_FREQUENCY_CHANGES}}
- **Tool enhancements**: {{TOOL_IMPROVEMENTS}}

---

## Action Items

### Immediate (This Week)

1. **{{IMMEDIATE_ITEM_1}}** - Due: {{IMMEDIATE_DUE_1}} - Owner: {{IMMEDIATE_OWNER_1}}
2. **{{IMMEDIATE_ITEM_2}}** - Due: {{IMMEDIATE_DUE_2}} - Owner: {{IMMEDIATE_OWNER_2}}

### Short-term (Next 2 Weeks)

1. **{{SHORT_TERM_ITEM_1}}** - Due: {{SHORT_TERM_DUE_1}} - Owner: {{SHORT_TERM_OWNER_1}}
2. **{{SHORT_TERM_ITEM_2}}** - Due: {{SHORT_TERM_DUE_2}} - Owner: {{SHORT_TERM_OWNER_2}}

### Long-term (Next Month)

1. **{{LONG_TERM_ITEM_1}}** - Due: {{LONG_TERM_DUE_1}} - Owner: {{LONG_TERM_OWNER_1}}
2. **{{LONG_TERM_ITEM_2}}** - Due: {{LONG_TERM_DUE_2}} - Owner: {{LONG_TERM_OWNER_2}}

---

## Next Review

**Scheduled date**: {{NEXT_REVIEW_DATE}}  
**Focus areas**: {{NEXT_REVIEW_FOCUS}}  
**Expected deliverables**: {{NEXT_REVIEW_DELIVERABLES}}

---

## Review Sign-off

- [ ] **Review complete**: All sections completed
- [ ] **Actions assigned**: All action items have owners and due dates
- [ ] **Status updated**: Monitoring status updated in `active-monitoring.yaml`
- [ ] **Findings marked**: All reviewed logs and findings marked as reviewed

**Reviewer signature**: {{REVIEWER_NAME}}  
**Review completion date**: {{REVIEW_COMPLETION_DATE}}

---

**Template version**: 1.0  
**Created**: {{CREATION_TIMESTAMP}}






