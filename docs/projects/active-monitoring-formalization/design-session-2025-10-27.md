# Design Session — Enhanced Monitoring System

**Date**: 2025-10-27  
**Participants**: User + Assistant  
**Outcome**: ERD updated with YAML-based configuration and logs/findings distinction

---

## Design Evolution

### Initial ERD → Enhanced Design

**From**: ACTIVE-MONITORING.md index + findings in projects  
**To**: `active-monitoring.yaml` config + structured monitoring/ directories

### Key Design Decisions

1. **Configuration Format**: YAML (machine-readable, tooling-friendly, comments allowed)
2. **Log vs Finding Distinction**: Logs = raw observations, Findings = analyzed patterns
3. **Review Tracking**: Front matter in both logs and findings (`reviewed: false/true`)
4. **Naming Convention**: Incremental numbering (`log-###`, `finding-###`) with timestamps in front matter
5. **Migration Strategy**: Single migration, no backward compatibility maintained
6. **Test Requirements**: All scripts MUST have corresponding `.test.sh` files

---

## Final Structure

```
docs/
├── active-monitoring.yaml                    # Central config
└── projects/
    ├── <slug>/
    │   ├── monitoring/
    │   │   ├── logs/
    │   │   │   ├── log-001-<description>.md  # Raw observations
    │   │   │   └── log-002-<description>.md
    │   │   └── findings/
    │   │       ├── finding-001-<pattern>.md   # Analyzed conclusions
    │   │       └── finding-002-<pattern>.md
    │   └── (standard project files)
    └── _archived/
        └── YYYY/
            └── <slug>/
                └── monitoring/ (preserved with review status)
```

---

## Configuration Schema

### `active-monitoring.yaml` Structure

**Core sections**:

- `monitoring:` — Active monitoring entries
- `completed:` — Archived/completed monitoring
- `routing:` — Decision tree for assistant routing
- `staleness:` — Time-based criteria for stale detection
- `constraints:` — System limits (max projects, file size)

**Per-project entry**:

```yaml
project-slug:
  status: active|paused
  started: "YYYY-MM-DD"
  duration: "N weeks|continuous"
  endDate: "YYYY-MM-DD"|null
  logsPath: "docs/projects/<slug>/monitoring/logs"
  findingsPath: "docs/projects/<slug>/monitoring/findings"
  scope: [monitored behaviors]
  outOfScope: [exclusions with cross-references]
  monitors: [specific targets]
  crossReferences: [routing to other projects]
```

---

## Document Templates

### Log Template (Raw Observations)

**Front matter**:

```yaml
---
logId: ###
timestamp: "YYYY-MM-DD HH:MM:SS UTC"
project: "<slug>"
observer: "Assistant|<name>"
reviewed: false
reviewedBy: null
reviewedDate: null
context: "<work-context>"
---
```

**Structure**: Observation → System State → Raw Data → Notes

### Finding Template (Analyzed Conclusions)

**Front matter**:

```yaml
---
findingId: ###
date: "YYYY-MM-DD"
project: "<slug>"
severity: "critical|high|medium|low"
status: "open|in-progress|resolved"
reviewed: false
reviewedBy: null
reviewedDate: null
sourceLogs: ["log-###", "log-###"]
---
```

**Structure**: Pattern → Evidence → Root Cause → Impact → Recommendation → Related

---

## Script Requirements

### Core Scripts (Phase 2)

**Creation**:

- `monitoring-log-create.sh --project <slug> --observation "..."`
- `monitoring-finding-create.sh --project <slug> --title "..."`

**Review**:

- `monitoring-review.sh --project <slug> [--mark-reviewed]`

**Setup**:

- Update `project-create.sh` with `--enable-monitoring` flag
- `monitoring-setup.sh --project <slug>` (post-creation)

### Configuration & Validation (Phase 3)

**Validation**:

- `monitoring-validate-config.sh` (YAML schema validation)
- `monitoring-detect-stale.sh` (staleness criteria checking)

**Dashboard**:

- `monitoring-dashboard.sh` (active monitoring status)

### Migration (Phase 2.5)

**Migration**:

- `monitoring-migrate-legacy.sh` (ACTIVE-MONITORING.md → YAML + structure)

**Test Requirement**: ALL scripts MUST have corresponding `.test.sh` files

---

## Migration Plan

### Phase 2.5 Execution

1. **Create YAML config** from existing ACTIVE-MONITORING.md
2. **Create monitoring/ directories** for active projects
3. **Migrate existing findings**:
   - rules-enforcement-investigation: 35+ gap files → monitoring/findings/
   - blocking-tdd-enforcement: inline → monitoring/logs/
   - Add front matter to all migrated files
4. **7-day compatibility period** with deprecation notice
5. **Remove legacy** after validation

### Validation Checkpoints

- [ ] All projects have monitoring/ structure
- [ ] All findings migrated with front matter
- [ ] YAML validates with schema
- [ ] Assistant routes correctly
- [ ] No broken links

---

## Key Improvements Over Original

### Better Tooling/Automation

- YAML config enables programmatic validation
- Scripts handle numbering, front matter, templates
- Dashboard provides unified view
- Staleness detection automated

### Proper Archival Transition

- monitoring/ directories move with projects
- Review status preserved in archived findings
- Config updated automatically during archival

### Logs vs Findings Distinction

- **Logs**: Factual observations during work (data collection)
- **Findings**: Analyzed patterns and conclusions (insights)
- Clear workflow: Observe → Log → Analyze → Finding

### Review Tracking

- Front matter tracks review status
- Scripts can mark as reviewed with reviewer/date
- Unreviewed items easily identified
- Historical review status preserved

---

## Success Metrics

- **Correct routing**: >95% of logs in correct project
- **Log→Finding conversion**: >80% of patterns identified
- **Review compliance**: >90% reviewed within 30 days
- **Tool adoption**: >90% use scripts vs manual creation
- **Migration success**: 0 broken links after legacy removal

---

## Next Steps

1. **Generate tasks** from updated ERD (two-phase flow)
2. **Create templates** (monitoring-protocol, log, finding)
3. **Implement core scripts** with tests
4. **Execute migration** (Phase 2.5)
5. **Validate system** (Phase 3)

---

## Related Documents

- **ERD**: [erd.md](./erd.md) — Updated requirements with enhanced design
- **Gap Analysis**: [erd-review-2025-10-27.md](./erd-review-2025-10-27.md) — Initial analysis session
- **Current System**: [../ACTIVE-MONITORING.md](../ACTIVE-MONITORING.md) — To be migrated






