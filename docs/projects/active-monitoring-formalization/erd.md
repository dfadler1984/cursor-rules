---
status: planning
mode: full
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-27
---

# Engineering Requirements Document — Active Monitoring Formalization

Mode: Full

## 1. Introduction/Overview

**Problem**: `ACTIVE-MONITORING.md` exists as an ad-hoc coordination mechanism but lacks formal structure, lifecycle management, and clear workflows for how monitored items are created, reviewed, and closed.

**Proposed Solution**: Formalize the active monitoring system with documented structure, templates, review workflows, and integration patterns with investigation projects. Define where findings go, when items close, and how to handle multi-project monitoring.

**Context**: Created from Gap #17/17b (ACTIVE-MONITORING.md created without enforcement mechanism). This project formalizes the mechanism itself.

## 2. Goals/Objectives

### Primary

- Document formal structure for ACTIVE-MONITORING.md (required fields, lifecycle states)
- Define where monitoring findings get documented (individual projects vs ACTIVE-MONITORING.md)
- Create review/closure workflows for monitored items
- Establish templates for monitoring protocols and finding documentation

### Secondary

- Integration guidance with investigation projects (when to use monitoring vs dedicated project)
- Metrics for monitoring effectiveness (average time to closure, findings conversion rate)
- Automation opportunities (auto-detection of scope conflicts, stale monitoring alerts)

## 3. User Stories

- As an **assistant**, I want clear guidance on where to document findings so that I put them in the correct project without user correction
- As a **maintainer**, I want monitored items to have closure criteria so that monitoring doesn't accumulate indefinitely
- As a **future investigator**, I want structured finding documents so that I can understand what was monitored and why
- As an **assistant during investigation**, I want to know when my finding belongs to an active monitoring scope vs a new gap

## 4. Functional Requirements

### Document Structure (ACTIVE-MONITORING.md)

1. **Required fields per monitored project**:

   - Status (🔄 Active, ✅ Complete, ⏸️ Paused)
   - Started date (YYYY-MM-DD)
   - Duration / End criteria
   - Findings path (where to document)
   - Naming pattern (how to name finding files)
   - Scope (what this project monitors)
   - Out of scope (what belongs elsewhere)
   - Cross-reference (where to redirect if wrong scope)

2. **Lifecycle states**:

   - Active: Currently monitoring
   - Paused: Temporarily suspended
   - Complete: Monitoring finished, findings documented
   - Archived: Moved to project's historical section

3. **Decision tree section**: Quick routing guide (symptom → category → project)

### Finding Documentation Workflow

1. **Detection**: When observing issue during work, check ACTIVE-MONITORING.md
2. **Categorization**: Use decision tree to determine project
3. **Documentation**: Follow project's findings path and naming pattern
4. **OUTPUT requirement**: "Observed: [X] | Category: [Y] | Project: [Z] | Document in: [path]"

### Review & Closure

1. **Review checkpoint**: When to review monitored items (time-based or finding-count-based)
2. **Closure criteria**: When monitoring ends (success criteria met, project complete, scope changed)
3. **Post-closure**: Where completed monitoring records go (project findings/ or archive)

## 5. Non-Functional Requirements

- **Usability**: Decision tree resolves scope in <30 seconds
- **Maintainability**: Clear when to add/remove/update monitored projects
- **Discoverability**: Referenced from investigation OUTPUT requirements (self-improve.mdc)
- **Compliance**: Enforced via pre-send gate (assistant-behavior.mdc line 292)

## 6. Architecture/Design

### Core Components

**ACTIVE-MONITORING.md** (Index):

- Table of currently monitored projects
- Decision tree for routing findings
- Quick reference (symptom → project)

**Project-Specific Monitoring**:

- Each project defines its findings location
- Projects own their scope boundaries
- Cross-references point to related projects

**Templates**:

- `monitoring-protocol.template.md` — How to structure monitoring in a project
- `finding-template.md` — Standard finding document structure
- `review-checklist.md` — Periodic review checklist

**Integration Points**:

- `self-improve.mdc` (lines 201-208): Requires ACTIVE-MONITORING.md check before documenting
- `assistant-behavior.mdc` (line 292): Pre-send gate verifies monitoring check
- Investigation projects: Reference ACTIVE-MONITORING.md in coordination.md

### Decision Tree Structure

**Format**: Conditional questions with category routing (proven effective with current ACTIVE-MONITORING.md)

**Current Implementation** (ACTIVE-MONITORING.md lines 164-194):

```
Observed issue during work:
│
├─ Is this about TDD gate BLOCKING (file pairing enforcement)?
│  └─ YES → blocking-tdd-enforcement
│      Pattern: Inline in README/tasks
│
├─ Is this about FOLLOWING attached rules?
│  └─ YES → rules-enforcement-investigation
│      Pattern: findings/gap-##-<name>.md
│
├─ Is this about GitHub Actions/workflows?
│  └─ YES → github-workflows-utility
│
├─ Is this about PR creation scripts?
│  └─ YES → pr-create-decomposition
│
├─ Is this about TDD scope check accuracy (which files trigger TDD gate)?
│  └─ YES → tdd-scope-boundaries
│      Pattern: findings/issue-##-<name>.md
│
├─ Is this about consent gate behavior (prompting frequency, state tracking)?
│  └─ YES → consent-gates-refinement
│      Pattern: Single file, ## Finding #N: <title>
│
└─ Unclear?
   └─ Ask user: "This seems like [X] issue. Should I document in [project]?"
```

**4-Question Structure** (ACTIVE-MONITORING.md lines 10-28):

1. **What failed?**

   - Routing: Wrong rules attached?
   - Execution: Right rules attached but ignored?
   - Workflow: Automation contradiction?
   - Other: Different category?

2. **Which project monitors this?**

   - Check the table below
   - Match failure category to project scope

3. **Where to document?**

   - Use the "Findings Location" from the matching project
   - Follow the naming pattern specified

4. **Cross-reference needed?**
   - Note relationship to other projects if relevant
   - Link related findings without designating "primary"

**Edge Case Routing Examples**:

| Symptom                                | Category  | Project                         | Rationale                                     |
| -------------------------------------- | --------- | ------------------------------- | --------------------------------------------- |
| User says "implement X", guidance rule | Routing   | routing-optimization            | Intent misread, wrong rules attached          |
| User says "implement X", TDD ignored   | Execution | rules-enforcement-investigation | Rule loaded but pre-edit gate skipped         |
| File signal overrides user intent      | Routing   | routing-optimization            | Test file context attached testing rules      |
| AlwaysApply rule present but violated  | Execution | rules-enforcement-investigation | self-improve.mdc loaded, "don't wait" ignored |
| GitHub Action auto-labels incorrectly  | Workflow  | github-workflows-utility        | Auto-applies skip-changeset despite changeset |
| Assistant doesn't use repo script      | Execution | rules-enforcement-investigation | Used manual git command instead of script     |

**Validation Evidence**:

- **Current tree achieves correct routing** (no reported misclassifications)
- **35+ findings successfully categorized** in rules-enforcement-investigation
- **Simple conditional format** requires no ML/AI (pattern matching sufficient)
- **Ambiguity resolution**: Ask one clarifying question if unclear (per existing protocol)

**No Prior Art Needed**:

- Web search found no specific Cursor Rules decision tree patterns
- Current implementation (lines 164-194) is working solution
- Conditional routing is proven pattern across software systems
- Formalization documents existing successful practice

### Lifecycle Flow

```
New Project Needs Monitoring
    ↓
Add to ACTIVE-MONITORING.md (Status: Active)
    ↓
Define: Scope, Findings Path, Duration
    ↓
During Monitoring: Document findings per project pattern
    ↓
Review Checkpoint (periodic or finding-count trigger)
    ↓
Closure Decision (criteria met? scope changed? project complete?)
    ↓
Update Status (Complete or Paused)
    ↓
Archive Monitoring Record (move to project/monitoring-history.md)
```

## 7. Data Model and Storage

### Configuration Schema (`active-monitoring.yaml`)

**Root structure**:

```yaml
version: "1.0"
lastUpdated: "YYYY-MM-DD"

# Active monitoring entries
monitoring:
  <project-slug>:
    status: active|paused
    started: "YYYY-MM-DD"
    duration: "N weeks|continuous"
    endDate: "YYYY-MM-DD"|null
    logsPath: "docs/projects/<slug>/monitoring/logs"
    findingsPath: "docs/projects/<slug>/monitoring/findings"
    scope: [list of monitored behaviors]
    outOfScope: [list with cross-references]
    monitors: [specific observation targets]
    crossReferences:
      - project: "<other-slug>"
        condition: "When to route there"

# Completed/archived monitoring
completed:
  <project-slug>:
    status: "archived|completed"
    started: "YYYY-MM-DD"
    completed: "YYYY-MM-DD"
    archivedTo: "docs/projects/_archived/YYYY/<slug>"
    finalResults: "Summary of outcomes"

# Decision tree for assistant routing
routing:
  categories:
    - name: "routing|execution|workflow|other"
      description: "Category description"
      symptom: "How to recognize this category"
  rules:
    - symptom: "Observable pattern"
      project: "<target-project-slug>"

# System constraints
staleness:
  timeBased: 30        # days without logs before stale
  durationGrace: 14    # days past endDate before stale
  newMonitoringGrace: 60  # days grace for new monitoring
constraints:
  maxActiveProjects: 5
  maxConfigLines: 300  # lines before archival needed
```

### Log Document Template

**Raw observation** (`monitoring/logs/log-###-<description>.md`):

```markdown
---
logId: ###
timestamp: "YYYY-MM-DD HH:MM:SS UTC"
project: "<slug>"
observer: "Assistant|<maintainer-name>"
reviewed: false
reviewedBy: null
reviewedDate: null
context: "<work-context>"
---

# Monitoring Log #### — <Description>

**Project**: <slug>  
**Observer**: <observer>  
**Context**: <what work was being done>

## Observation

<Factual description of what happened>

## System State

- Rule(s) loaded: <which rules were attached>
- Gate status: <triggered/not triggered>
- Pre-send gate: <blocked/passed>
- Files involved: <list>

## Raw Data

- Timestamp: <exact time>
- Duration: <if measurable>
- Error messages: <if any>
- Command executed: <if relevant>

## Notes

<Additional context, but minimal interpretation>
```

### Finding Document Template

**Analyzed conclusion** (`monitoring/findings/finding-###-<pattern-name>.md`):

```markdown
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

# Finding ####: <Pattern Name>

**Project**: <slug>  
**Severity**: <level>  
**Status**: <current-status>  
**Source Logs**: <references to supporting logs>

## Pattern

<What pattern was identified>

## Evidence

<References to specific logs, with key facts>

## Root Cause

<Analysis of why this happens>

## Impact

<Effect on project/quality/compliance>

## Recommendation

<Proposed actions to address>

## Related

<Links to other findings, projects, rules>
```

### Directory Structure

```
docs/
├── active-monitoring.yaml                    # Central config
└── projects/
    ├── <slug>/
    │   ├── monitoring/
    │   │   ├── logs/
    │   │   │   ├── log-001-<description>.md  # Incremental numbering
    │   │   │   ├── log-002-<description>.md
    │   │   │   └── ...
    │   │   └── findings/
    │   │       ├── finding-001-<pattern>.md   # Per-project numbering
    │   │       ├── finding-002-<pattern>.md
    │   │       └── ...
    │   ├── README.md
    │   ├── erd.md
    │   └── tasks.md
    └── _archived/
        └── YYYY/
            └── <slug>/
                └── monitoring/              # Preserved structure
                    ├── logs/ (with review status)
                    └── findings/ (with review status)
```

## 8. API/Contracts

### Assistant Integration Contract

**self-improve.mdc** (investigation section) MUST:

1. Consult `active-monitoring.yaml` before documenting observations
2. OUTPUT: "Observed: [X] | Category: [Y] | Project: [checked active-monitoring.yaml → Z] | Logging to: [path]"
3. Create log in project's `monitoring/logs/` directory
4. Update log counter (incremental numbering per project)

**assistant-behavior.mdc** (pre-send gate) MUST:

1. Check: "Monitoring: checked active-monitoring.yaml? (if documenting observation)"
2. Verify OUTPUT was shown with config consultation
3. FAIL if observation logged to wrong project path

### Project Registration Contract

**To add monitoring to a project**:

1. Add entry to ACTIVE-MONITORING.md with all required fields
2. Create findings directory/file in project
3. Document scope boundaries clearly
4. Define closure criteria

### Enforcement Specification

**Detection Points**:

- **Pre-documentation checkpoint** (assistant execution):

  - Before documenting any finding, OUTPUT requirement triggers
  - Format: `"Observed: [description] | Category: [routing|execution|workflow|other] | Project: [checked ACTIVE-MONITORING.md → project-name] | Document in: [path]"`
  - Mandatory for all investigation findings (not optional)

- **Pre-send gate** (assistant-behavior.mdc line 292):

  - Gate item: "Monitoring: checked ACTIVE-MONITORING.md? (if documenting finding)"
  - Checks: OUTPUT was shown with ACTIVE-MONITORING.md check
  - Validates: Category determination and project routing

- **Post-documentation validation** (future script):
  - Verifies finding file path matches ACTIVE-MONITORING.md entry
  - Detects: Wrong project, missing ACTIVE-MONITORING.md entry
  - Report: Violations for manual correction

**Violation Responses**:

- **Missing OUTPUT** → FAIL pre-send gate

  - Action: Block message send
  - Error: "Cannot document finding without ACTIVE-MONITORING.md check. OUTPUT required."
  - Recovery: Show OUTPUT, then proceed

- **Wrong project path** → Warning + correction suggestion

  - Action: Flag in post-documentation validation
  - Message: "Finding documented in [project-A] but ACTIVE-MONITORING.md routes to [project-B]"
  - Recovery: Move file or update ACTIVE-MONITORING.md if scope changed

- **Missing ACTIVE-MONITORING.md entry** → Registration guide
  - Action: Detect project has findings but no monitoring entry
  - Message: "Project [X] has findings/ but no ACTIVE-MONITORING.md entry"
  - Recovery: Follow project registration contract

**Enforcement Owners**:

- **Assistant** (self-improve.mdc):

  - OUTPUT requirement (pre-documentation)
  - Pre-send gate check (before message send)
  - ACTIVE-MONITORING.md consultation

- **Scripts** (Phase 4 automation):

  - Path validation: `monitoring-validate-paths.sh`
  - Stale detection: `monitoring-detect-stale.sh`
  - Structure validation: `monitoring-validate-structure.sh`

- **CI** (future integration):
  - Validate ACTIVE-MONITORING.md structure on PR
  - Check finding paths match monitoring entries
  - Enforce required fields present

**Why This Works** (Evidence):

- **35+ gaps documented** in rules-enforcement-investigation show pattern works
- **Current routing tree** (ACTIVE-MONITORING.md lines 164-194) achieves correct categorization
- **Platform limitation identified**: Rules cannot mechanically enforce OUTPUT requirements
- **External enforcement required**: Git hooks, CI scripts, manual validation needed for compliance

## 9. Integrations/Dependencies

### Related Projects

- **rules-enforcement-investigation**: Execution monitoring (owns many Gap #N findings)
- **routing-optimization**: Intent routing monitoring (owns Finding #N findings)
- **investigation-docs-structure**: Provides structure guidance for investigation projects

### Rules Integration

- **self-improve.mdc** (lines 201-208): ACTIVE-MONITORING.md check requirement
- **assistant-behavior.mdc** (line 292): Pre-send gate monitoring check
- **investigation-structure.mdc**: References for multi-file findings structure

### Scripts Integration

**project-create.sh Integration**:

- Add optional monitoring setup during project creation
- Workflow:

  ```bash
  # Agent asks during project creation:
  "Would you like to configure monitoring for this project? (yes/no)"

  # If yes:
  project-create.sh --name <slug> --enable-monitoring
  ```

- When `--enable-monitoring` flag present:
  - Create `docs/projects/<slug>/monitoring/` structure (logs/ and findings/ directories)
  - Create `docs/projects/<slug>/monitoring-protocol.md` from template
  - Add entry to `active-monitoring.yaml` (status: active, default fields)
  - Update project README with monitoring section reference

**Core Monitoring Scripts** (Phase 2):

- **`monitoring-log-create.sh --project <slug> --observation "description"`**:

  - Creates timestamped log in `monitoring/logs/log-###-<description>.md`
  - Auto-increments log counter per project
  - Populates front matter (logId, timestamp, project, reviewed: false)
  - **Test required**: `monitoring-log-create.test.sh`

- **`monitoring-finding-create.sh --project <slug> --title "pattern-name"`**:

  - Creates finding in `monitoring/findings/finding-###-<pattern>.md`
  - Auto-increments finding counter per project
  - Populates front matter (findingId, date, project, reviewed: false)
  - **Test required**: `monitoring-finding-create.test.sh`

- **`monitoring-review.sh --project <slug> [--mark-reviewed]`**:
  - Analyzes logs in project's monitoring/logs/ for patterns
  - Lists unreviewed logs and findings
  - With `--mark-reviewed`: updates front matter (reviewed: true, reviewedBy, reviewedDate)
  - Suggests findings based on log patterns
  - **Test required**: `monitoring-review.test.sh`

**Configuration & Validation Scripts** (Phase 3):

- **`monitoring-validate-config.sh`**:

  - Validates `active-monitoring.yaml` schema
  - Checks required fields, valid values, path consistency
  - **Test required**: `monitoring-validate-config.test.sh`

- **`monitoring-detect-stale.sh`**:

  - Reads staleness criteria from `active-monitoring.yaml`
  - Checks time-based, duration-based, status-based staleness
  - Reports stale monitoring entries
  - **Test required**: `monitoring-detect-stale.test.sh`

- **`monitoring-dashboard.sh`**:
  - Pretty-prints active monitoring status from config
  - Shows log counts, finding counts, review status per project
  - **Test required**: `monitoring-dashboard.test.sh`

**Migration & Setup Scripts** (Phase 2.5):

- **`monitoring-migrate-legacy.sh`**:

  - Migrates existing ACTIVE-MONITORING.md to active-monitoring.yaml
  - Moves existing findings to monitoring/ structure
  - Creates migration report
  - **Test required**: `monitoring-migrate-legacy.test.sh`

- **`monitoring-setup.sh --project <slug>`**:
  - Add monitoring to existing project (post-creation)
  - Creates monitoring/ structure, updates config
  - **Test required**: `monitoring-setup.test.sh`

**Integration with Lifecycle**:

- **`project-archive-workflow.sh`** (update existing):

  - Reads `active-monitoring.yaml` for project monitoring status
  - Moves monitoring/ directory with project to \_archived/
  - Updates config: move entry from monitoring: to completed:
  - **Test update required**: Add monitoring transition test cases

- **`project-lifecycle-validate-scoped.sh`** (update existing):
  - Validates monitoring metadata consistency
  - Checks config entries match actual monitoring/ directories
  - **Test update required**: Add monitoring validation test cases

**Test Requirements** (All Scripts):

- **TDD compliance**: All monitoring scripts MUST have corresponding `.test.sh` files
- **Test coverage**: Scripts test happy path, error cases, edge cases (missing files, invalid YAML, etc.)
- **Test runner integration**: Use existing `.cursor/scripts/tests/run.sh -k <script-name> -v`
- **Focused testing**: Individual script tests can be run independently

## 10. Edge Cases and Constraints

### Edge Cases

1. **Finding spans multiple projects**:

   - **Documentation**: Note relationships and cross-references without designating "primary"
   - **Cross-reference format** (in related project's findings or README):

     ```markdown
     ## Related Findings

     - Gap #7 (rules-enforcement-investigation): Documentation-before-execution pattern
       - Also relevant to: routing-optimization (affects route decision timing)
       - See: docs/projects/rules-enforcement-investigation/findings/gap-07-documentation-before-execution.md
     ```

   - **Multi-project threshold**: If 3+ projects reference same finding, consider meta-project during monitoring review (not automatic)

2. **Unclear category**: Use decision tree; if still unclear, ask one clarifying question

3. **Multiple active investigations with overlapping scope**:

   - Note scope boundaries in "Out of Scope" field
   - Use cross-references to clarify which project owns which category
   - Example: TDD violations split between blocking-tdd-enforcement (gate mechanics) and rules-enforcement-investigation (execution compliance)

4. **Project completes but monitoring continues**: Mark project Complete, keep monitoring entry Active with note

5. **Project archived, monitoring needs emerge**: Create new project (do not reopen archived project monitoring)

### Staleness Criteria

**Definition**: Monitoring is considered stale when:

- **Time-based**: No findings documented in 30 consecutive days
- **Duration-based**: Duration/End criteria exceeded by 14+ days without closure decision
- **Status-based**: Status=Active but parent project Status=Complete for >30 days

**Grace Periods**:

- **New monitoring**: 60-day grace period from Started date (allows slow-burn investigations)
- **Post-finding**: 30-day countdown resets after each finding documented
- **Paused status**: No staleness checks while Status=Paused

**Review Trigger**: Stale monitoring triggers mandatory review checkpoint (see Section 4: Review & Closure)

**Resolution**:

- Extend monitoring (update Duration, document rationale)
- Close monitoring (mark Complete, archive record)
- Pause monitoring (mark Paused, document resume criteria)

### Constraints

- ACTIVE-MONITORING.md should remain scannable (≤300 lines; move completed monitoring to project-specific monitoring-history.md)
- Decision tree must resolve 90%+ cases without clarification (validated with current 35+ findings)
- No more than 5 concurrent active monitoring projects (maintain focus; pause or close before adding 6th)
- Findings must link back to ACTIVE-MONITORING.md entry for traceability
- Archived projects have monitoring removed (no reopen; create new project if needed)

## 11. Testing & Acceptance

The solution is complete when:

- ACTIVE-MONITORING.md structure is documented with required fields and lifecycle states defined
- Review workflow exists (when to review, closure criteria, post-closure handling)
- Templates created for monitoring protocols and finding documents
- Integration documented (how projects register, how assistant uses it, enforcement via gates)
- Decision tree validated (tested on 10+ real findings, >90% correct routing)
- Assistant can correctly categorize findings and document in correct project without user correction
- Monitored items have clear closure criteria and don't accumulate indefinitely
- Stale monitoring detection mechanism exists (duration exceeded, no findings in N days)

## 12. Rollout Plan

### Phase 1: Documentation (Week 1)

- Document formal structure requirements (section templates, required fields)
- Create decision tree expansion (more categories, clearer symptoms)
- Write review workflow guide (when/how to review, closure decision tree)

### Phase 2: Core Implementation (Week 1)

**Templates**:

- Create `monitoring-protocol.template.md` (for project setup)
- Create log document template (with front matter schema)
- Create finding document template (with front matter schema)
- Create review checklist template (periodic validation)

**Core Scripts** (with tests):

- `monitoring-log-create.sh` + `monitoring-log-create.test.sh`
- `monitoring-finding-create.sh` + `monitoring-finding-create.test.sh`
- `monitoring-review.sh` + `monitoring-review.test.sh`
- Update `project-create.sh` for `--enable-monitoring` flag

### Phase 2.5: Migration (Week 1.5)

**Migration Strategy**: Single migration, no backward compatibility

**Migration Scripts**:

- `monitoring-migrate-legacy.sh` + `monitoring-migrate-legacy.test.sh`
- `monitoring-setup.sh` + `monitoring-setup.test.sh`

**Migration Execution**:

1. **Create `active-monitoring.yaml`** from current `ACTIVE-MONITORING.md`:

   - Extract project entries, convert to YAML schema
   - Add routing decision tree from current lines 164-194
   - Set staleness criteria, constraints

2. **Create monitoring/ structure** for active projects:

   ```bash
   mkdir -p docs/projects/{blocking-tdd-enforcement,rules-enforcement-investigation,tdd-scope-boundaries,consent-gates-refinement}/monitoring/{logs,findings}
   ```

3. **Migrate existing findings**:

   - **rules-enforcement-investigation**: Move 35+ `findings/gap-##-*.md` → `monitoring/findings/finding-##-*.md`
   - **Update front matter**: Add `findingId`, `reviewed: false`, `sourceLogs: []`
   - **blocking-tdd-enforcement**: Extract inline observations → `monitoring/logs/log-###-*.md`
   - **consent-gates-refinement**: Keep single file format, add front matter

4. **Backward compatibility period** (7 days):

   - Keep `ACTIVE-MONITORING.md` with deprecation notice
   - Update assistant rules to use `active-monitoring.yaml` primarily
   - Monitor for any routing issues or confusion

5. **Remove legacy** (after validation):
   - Delete `docs/projects/ACTIVE-MONITORING.md`
   - Commit migration complete

**Validation Checkpoints**:

- [ ] All active projects have monitoring/ structure
- [ ] All existing findings migrated with front matter
- [ ] `active-monitoring.yaml` validates with schema
- [ ] Assistant routes correctly to new log locations
- [ ] No broken links or missing references

### Phase 3: Integration & Validation (Week 2)

**Configuration & Dashboard Scripts**:

- `monitoring-validate-config.sh` + test
- `monitoring-detect-stale.sh` + test
- `monitoring-dashboard.sh` + test

**Lifecycle Integration**:

- Update `project-archive-workflow.sh` for monitoring state transitions
- Update `project-lifecycle-validate-scoped.sh` for monitoring validation
- Add test cases for monitoring integration

**System Validation**:

- Run `monitoring-dashboard.sh` → verify all active monitoring visible
- Test archival workflow with monitoring project
- Validate staleness detection with test data
- Confirm review workflow (mark logs/findings as reviewed)

### Phase 4: Automation (Future)

- Script to detect stale monitoring (no findings in 30 days, duration exceeded)
- Script to validate ACTIVE-MONITORING.md structure
- Auto-detection of scope conflicts (finding documented in wrong project)

## 13. Success Metrics

- **Correct routing**: >95% of logs documented in correct project without user correction
- **Log→Finding conversion**: >80% of patterns identified from logs converted to findings
- **Review compliance**: >90% of logs and findings reviewed within 30 days of creation
- **Template adoption**: 100% of new monitoring uses templates (no ad-hoc structures)
- **Archival integration**: 100% of archived projects have monitoring state properly transitioned
- **Tool adoption**: >90% of monitoring operations use scripts (vs manual file creation)
- **Config validation**: 100% of `active-monitoring.yaml` updates pass schema validation
- **Migration success**: 0 broken links or missing references after legacy removal

## 14. Session Documentation

**Planning Session Documents**:

- `erd-review-2025-10-27.md` — Gap analysis session with evidence gathering and systematic ERD updates
- `design-session-2025-10-27.md` — Enhanced design decisions, YAML schema, templates, and implementation guidance

**Purpose**: These documents capture the design evolution process and provide implementation context. They should be archived to `docs/projects/_archived/2025/active-monitoring-formalization/` once the system is implemented and validated.

**Cleanup Task**: After Phase 3 completion and system validation, move session documents to archived location and update any references.

---

## 15. Open Questions

**Resolved During Planning**:

1. ~~Should ACTIVE-MONITORING.md live in `docs/projects/` or `.cursor/docs/`?~~
   - **Decision**: Keep in `docs/projects/` (current location, alongside projects)
2. ~~How many concurrent monitoring projects is too many?~~

   - **Decision**: 5 maximum (maintain focus, added to Constraints)

3. ~~Should findings always be individual files or allow single-file with sections?~~

   - **Decision**: Flexible by project need
     - ≤5-10 findings → single file with sections acceptable
     - > 10 findings → individual files directory recommended
     - Follows investigation-structure.mdc pattern

4. ~~When does monitoring become a dedicated investigation project?~~

   - **Decision**: Investigation structure applies at >15 files (per investigation-structure.mdc)
     - Monitoring can continue alongside investigation project
     - No automatic conversion; maintainer decides based on complexity

5. ~~Should there be a "monitoring-history.md" in each project for closed monitoring periods?~~

   - **Decision**: Yes, archive completed monitoring records there when ACTIVE-MONITORING.md exceeds 300 lines

6. ~~How to handle monitoring for completed/archived projects?~~

   - **Decision**: Remove monitoring when project archived
     - If new related issues emerge, create new project (don't reopen)

7. ~~Should ACTIVE-MONITORING.md have version/changelog tracking?~~
   - **Decision**: Not needed
     - Git history provides version tracking
     - monitoring-history.md in projects provides archival
     - Adds complexity without clear benefit

**Remaining Open Questions**:

1. **Template location**: Should monitoring templates live in `templates/monitoring/` or `.cursor/docs/templates/`?

   - Consideration: Consistency with other template locations in repo

2. **Findings numbering**: Should there be a repo-wide finding counter or per-project counters?
   - Current: Per-project (gap-##, issue-##, Finding #N)
   - Trade-off: Repo-wide provides uniqueness but loses project context
