# Monitoring Protocol — {{PROJECT_NAME}}

**Project**: {{PROJECT_SLUG}}  
**Started**: {{START_DATE}}  
**Duration**: {{DURATION}}  
**Status**: 🔄 Active

---

## Monitoring Overview

**Purpose**: {{PURPOSE_DESCRIPTION}}

**What We're Monitoring**:

- {{MONITORING_TARGET_1}}
- {{MONITORING_TARGET_2}}
- {{MONITORING_TARGET_3}}

**Success Criteria**:

- {{SUCCESS_CRITERION_1}}
- {{SUCCESS_CRITERION_2}}

---

## Scope Definition

### In Scope

**This monitoring covers**:

- {{IN_SCOPE_ITEM_1}}
- {{IN_SCOPE_ITEM_2}}
- {{IN_SCOPE_ITEM_3}}

**Categories we monitor**:

- {{CATEGORY_1}}: {{CATEGORY_1_DESCRIPTION}}
- {{CATEGORY_2}}: {{CATEGORY_2_DESCRIPTION}}

### Out of Scope

**Not covered by this monitoring** (route elsewhere):

- {{OUT_OF_SCOPE_ITEM_1}} → See {{CROSS_REFERENCE_PROJECT_1}}
- {{OUT_OF_SCOPE_ITEM_2}} → See {{CROSS_REFERENCE_PROJECT_2}}

---

## Logging Workflow

### When to Create a Log

Create a monitoring log when you observe:

- {{LOG_TRIGGER_1}}
- {{LOG_TRIGGER_2}}
- {{LOG_TRIGGER_3}}

### Log Creation Process

1. **Observe** the behavior/issue during work
2. **Check** `active-monitoring.yaml` to confirm this project monitors it
3. **OUTPUT**: `"Observed: [description] | Category: [category] | Project: [checked active-monitoring.yaml → {{PROJECT_SLUG}}] | Logging to: docs/projects/{{PROJECT_SLUG}}/monitoring/logs/"`
4. **Create log** using: `monitoring-log-create.sh --project {{PROJECT_SLUG}} --observation "description"`

### Log Structure

**Front matter** (auto-populated by script):

```yaml
---
logId: ###
timestamp: "YYYY-MM-DD HH:MM:SS UTC"
project: "{{PROJECT_SLUG}}"
observer: "Assistant|<name>"
reviewed: false
reviewedBy: null
reviewedDate: null
context: "<work-context>"
---
```

**Content sections**:

- **Observation**: Factual description of what happened
- **System State**: Rules loaded, gates triggered, files involved
- **Raw Data**: Timestamps, durations, error messages, commands
- **Notes**: Additional context (minimal interpretation)

---

## Finding Development

### When to Create a Finding

Create a finding when you identify:

- **Pattern** across multiple logs (2+ similar observations)
- **Root cause** analysis completed
- **Actionable recommendation** available

### Finding Creation Process

1. **Analyze** logs in `monitoring/logs/` for patterns
2. **Create finding** using: `monitoring-finding-create.sh --project {{PROJECT_SLUG}} --title "pattern-name"`
3. **Reference source logs** in front matter and evidence section
4. **Include** pattern, root cause, impact, recommendations

### Finding Structure

**Front matter** (auto-populated by script):

```yaml
---
findingId: ###
date: "YYYY-MM-DD"
project: "{{PROJECT_SLUG}}"
severity: "critical|high|medium|low"
status: "open|in-progress|resolved"
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: ["log-###", "log-###"]
---
```

**Content sections**:

- **Pattern**: What pattern was identified
- **Evidence**: References to specific logs with key facts
- **Root Cause**: Analysis of why this happens
- **Impact**: Effect on project/quality/compliance
- **Recommendation**: Proposed actions to address
- **Related**: Links to other findings, projects, rules

---

## Review Process

### Review Schedule

- **Logs**: Review weekly, mark as reviewed after analysis
- **Findings**: Review within 30 days of creation
- **Monitoring health**: Check monthly for staleness

### Review Workflow

1. **Run review**: `monitoring-review.sh --project {{PROJECT_SLUG}}`
2. **Analyze patterns**: Look for recurring issues, trends
3. **Mark reviewed**: `monitoring-review.sh --project {{PROJECT_SLUG}} --mark-reviewed`
4. **Update findings**: Create new findings from patterns
5. **Update status**: Mark findings as in-progress or resolved

### Review Criteria

**Logs ready for review when**:

- Pattern emerges (2+ similar observations)
- Root cause identified
- Action needed

**Findings ready for review when**:

- Evidence is complete
- Recommendations are actionable
- Impact assessment is accurate

---

## Monitoring Configuration

### Active Monitoring Entry

**Location**: `docs/active-monitoring.yaml`

**Entry structure**:

```yaml
{ { PROJECT_SLUG } }:
  status: active
  started: "{{START_DATE}}"
  duration: "{{DURATION}}"
  endDate: { { END_DATE } }
  logsPath: "docs/projects/{{PROJECT_SLUG}}/monitoring/logs"
  findingsPath: "docs/projects/{{PROJECT_SLUG}}/monitoring/findings"
  scope:
    - "{{IN_SCOPE_ITEM_1}}"
    - "{{IN_SCOPE_ITEM_2}}"
  outOfScope:
    - "{{OUT_OF_SCOPE_ITEM_1}} → {{CROSS_REFERENCE_PROJECT_1}}"
    - "{{OUT_OF_SCOPE_ITEM_2}} → {{CROSS_REFERENCE_PROJECT_2}}"
  monitors:
    - "{{MONITORING_TARGET_1}}"
    - "{{MONITORING_TARGET_2}}"
  crossReferences:
    - project: "{{CROSS_REFERENCE_PROJECT_1}}"
      condition: "{{CROSS_REFERENCE_CONDITION_1}}"
```

### Directory Structure

```
docs/projects/{{PROJECT_SLUG}}/
├── monitoring/
│   ├── logs/
│   │   ├── log-001-<description>.md
│   │   └── log-002-<description>.md
│   └── findings/
│       ├── finding-001-<pattern>.md
│       └── finding-002-<pattern>.md
├── README.md
├── erd.md
└── tasks.md
```

---

## Closure Criteria

### When to Close Monitoring

**Success criteria met**:

- {{SUCCESS_CRITERION_1}} achieved
- {{SUCCESS_CRITERION_2}} achieved
- No new issues in {{STALENESS_THRESHOLD}} days

**Duration completed**:

- End date reached: {{END_DATE}}
- Monitoring objectives fulfilled

**Project lifecycle**:

- Project archived → monitoring closes automatically
- Project completed → monitoring may continue if valuable

### Closure Process

1. **Review final state**: Run `monitoring-dashboard.sh` to verify status
2. **Update config**: Move entry from `monitoring:` to `completed:` in `active-monitoring.yaml`
3. **Archive findings**: Ensure all findings reviewed and resolved/documented
4. **Update project**: Add monitoring summary to project README

---

## Tools & Scripts

### Core Scripts

- **Create log**: `monitoring-log-create.sh --project {{PROJECT_SLUG}} --observation "..."`
- **Create finding**: `monitoring-finding-create.sh --project {{PROJECT_SLUG}} --title "..."`
- **Review status**: `monitoring-review.sh --project {{PROJECT_SLUG}}`
- **Mark reviewed**: `monitoring-review.sh --project {{PROJECT_SLUG}} --mark-reviewed`

### Dashboard & Validation

- **View status**: `monitoring-dashboard.sh`
- **Validate config**: `monitoring-validate-config.sh`
- **Check staleness**: `monitoring-detect-stale.sh`

### Setup & Migration

- **Add to existing project**: `monitoring-setup.sh --project {{PROJECT_SLUG}}`
- **Migrate legacy**: `monitoring-migrate-legacy.sh` (for system migration)

---

## Related

- **Configuration**: `docs/active-monitoring.yaml` — Central monitoring config
- **ERD**: `docs/projects/active-monitoring-formalization/erd.md` — System requirements
- **Cross-references**: {{CROSS_REFERENCE_PROJECT_1}}, {{CROSS_REFERENCE_PROJECT_2}}

---

**Created**: {{CREATION_DATE}}  
**Template version**: 1.0  
**Next review**: {{NEXT_REVIEW_DATE}}






