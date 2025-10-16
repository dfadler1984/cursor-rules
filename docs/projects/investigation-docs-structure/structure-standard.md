# Investigation Documentation Structure Standard

**Purpose**: Define organizational structure for complex investigation projects

**When to use**: Investigations with multiple hypotheses, tests, and substantial documentation (typically >15 files)

**When NOT to use**: Simple projects with <10 files; use basic README/erd/tasks structure

---

## Root Files (Baseline)

**Always present**:
- `README.md` - Entry point, navigation
- `erd.md` - Requirements and scope
- `tasks.md` - Execution tracking

**Optional root files** (case-by-case):
- `coordination.md` - For umbrella projects with sub-projects
- `MONITORING-PROTOCOL.md` - High-level operational protocol
- `findings/README.md` OR `findings.md` - Findings summary/index

---

## Folder Structure

### findings/

**Purpose**: Individual finding documents

**Contents**:
- `README.md` - Index/summary of all findings
- `gap-01-<short-name>.md` - One file per finding/gap
- `gap-02-<short-name>.md`
- etc.

**When to use**: 
- Create individual files when findings are substantial (>50 lines each)
- Use README as index when many findings (5+)
- For simple projects with 1-3 findings, single `findings.md` in root is fine

**Naming pattern**: `gap-##-<kebab-case-short-name>.md`

**Example**: `gap-07-documentation-before-execution.md`

### analysis/

**Purpose**: Deep analysis of investigation topics

**Contents**:
- Analysis documents (flat when small)
- Subfolders for large topics (3+ files)

**Structure**:
```
analysis/
├── discovery.md              # Overall discovery (flat)
├── conditional-rules/        # Large topic (subfolder)
│   ├── analysis.md
│   ├── patterns.md
│   └── _archived/
├── scalability/              # Large topic (subfolder)
│   └── analysis.md
└── _archived/                # Archived analysis docs
```

**When to create subfolder**:
- Topic has 3+ related files
- Topic needs organized breakdown
- Topic has own archived docs

**Naming**: 
- Flat files: `<topic>-analysis.md`
- Subfolders: `<topic>/` with descriptive file names inside

### decisions/

**Purpose**: Decision documents (choices made with rationale)

**Contents**:
- `<topic>-decision.md` - One file per major decision
- Includes: options considered, criteria, choice, rationale

**Example**: `slash-commands-decision.md`

**Format**:
- Background/context
- Options evaluated
- Decision criteria
- Choice made and why
- Implications
- Status updates as decision evolves

### guides/

**Purpose**: Reference guides for using/integrating project outputs

**Contents**:
- `ci-integration.md` - How to integrate into CI
- `measurement-guide.md` - How to use measurement tools
- `<topic>-guide.md` - Other reference guides

**Distinguish from protocols**: 
- Guides = how to USE outputs (integrating compliance tools into CI)
- Protocols = how to RUN tests/validation (execute hypothesis test)

### protocols/

**Purpose**: Test and validation protocols (how to execute tests)

**Contents**:
- `<hypothesis>-protocol.md` - How to run a specific test
- `monitoring-protocol.md` - How to monitor ongoing validation
- `validation-protocol.md` - How to validate results

**Example**: `h1-validation-protocol.md` - Steps to validate H1 fix

**Distinguish from test plans**:
- Test plans (`tests/`) = templates defining methodology
- Protocols = operational procedures for execution

### sessions/

**Purpose**: Session summaries (chronological work logs)

**Contents**:
- `YYYY-MM-DD.md` - One file per session
- Adhoc summaries when needed for important milestones

**Naming**: `YYYY-MM-DD.md` or `YYYY-MM-DD-<topic>.md` if multiple sessions same day

**Format**:
- Date and duration
- What was accomplished
- Decisions made
- Findings discovered
- Next steps

### test-results/

**Purpose**: Data from executing tests (observations, measurements)

**Contents**:
Organized by hypothesis/test:
```
test-results/
├── h1/
│   └── validation-data.md
├── h2/
│   ├── test-a-data.md
│   └── test-d-checkpoint-1.md
├── h3/
│   ├── test-a-results.md
│   └── test-c-results.md
```

**What belongs here**:
- Raw data and measurements
- Test execution logs
- Checkpoints during testing
- Observed behaviors

**What doesn't**:
- Protocols (go in protocols/)
- Pre-test discovery (those become sub-projects)
- Conclusions (go in findings/)
- Test plans (go in tests/)

### tests/

**Purpose**: Test plan templates (reusable methodologies)

**Contents**:
- `README.md` - Index of test plans
- `hypothesis-#-<name>.md` - Test plans
- `experiment-<name>.md` - Experimental designs
- `measurement-framework.md` - Tool design

**Keep as-is**: This folder structure works well

### _archived/

**Purpose**: Archived documents from root level

**Location**: Can exist at any level
- Root: `_archived/` for archived root docs
- analysis/topic/: `_archived/` for archived analysis of that topic

**Naming**: Leading underscore for easy visual distinction

---

## Sub-Projects Pattern

### When to Create Sub-Project

**Create separate project** when:
- Substantial scope (would have own ERD with 5+ requirements)
- Independent execution (can work on it standalone)
- Distinct deliverables (produces artifacts used elsewhere)
- Could be understood without parent context

**For rules-enforcement-investigation**: All hypothesis investigations become sub-projects

### Sub-Project Coordination

**Parent project** (`rules-enforcement-investigation/`):
- `coordination.md` in root - tracks all sub-projects
- High-level erd.md and tasks.md
- Aggregate findings/README.md
- Links to sub-projects

**Sub-projects** (siblings in `docs/projects/`):
- `h1-conditional-attachment/`
- `h2-send-gate-investigation/`
- `h3-query-visibility/`
- `slash-commands-experiment/` (runtime routing attempt)
- `prompt-templates-experiment/` (if pursued)

**Each sub-project**:
- Full structure (README, erd, tasks, findings)
- README has: `**Parent**: [rules-enforcement-investigation](../rules-enforcement-investigation/)`
- When complete: outcome captured in parent's coordination.md

### coordination.md Structure

```markdown
# Sub-Projects Coordination

## Overview

Investigation broken into focused sub-projects for parallel execution and clear scope.

## Sub-Projects

### H1: Conditional Attachment
- **Status**: COMPLETE
- **Location**: [h1-conditional-attachment](../h1-conditional-attachment/)
- **Objective**: Test if alwaysApply improves compliance
- **Resolution**: ✅ Confirmed - 74% → 96% script usage
- **Contribution**: Primary fix for git operations

### H2: Send Gate Investigation  
- **Status**: MONITORING
- **Location**: [h2-send-gate-investigation](../h2-send-gate-investigation/)
- **Objective**: Validate send gate executes and blocks violations
- **Current**: Visible gate implemented; 0% → 100% visibility
- **Contribution**: Transparency and accountability mechanism

[... etc for all sub-projects ...]

## Integration

How sub-project findings feed into parent investigation synthesis.
```

---

## Decision Framework

### New File vs Update Existing?

**Create new file when**:
- New topic/finding (not updating existing)
- File would be >200 lines if added to existing
- Different audience or purpose

**Update existing when**:
- Continuing same topic
- Small addition (<50 lines)
- Refinement of existing content

### Create Subfolder vs Flat File?

**Create subfolder when**:
- Topic has 3+ related files
- Topic needs organized breakdown
- Topic will grow over time

**Keep flat when**:
- Single file sufficient
- Simple topic
- Unlikely to expand

### Create Sub-Project vs Analysis Doc?

**Create sub-project when**:
- Has own scope and requirements (ERD-worthy)
- Can be executed independently
- Produces distinct deliverables
- >200 lines of documentation

**Keep as analysis when**:
- Supporting analysis for parent
- Single document sufficient
- Tightly coupled to parent scope

---

## Naming Patterns

| Category | Pattern | Example |
|----------|---------|---------|
| Findings | `gap-##-<short-name>.md` | `gap-07-documentation-before-execution.md` |
| Analysis (flat) | `<topic>-analysis.md` | `scalability-analysis.md` |
| Analysis (folder) | `<topic>/analysis.md` | `conditional-rules/analysis.md` |
| Decisions | `<topic>-decision.md` | `slash-commands-decision.md` |
| Guides | `<topic>-guide.md` | `ci-integration-guide.md` |
| Protocols | `<topic>-protocol.md` | `h1-validation-protocol.md` |
| Sessions | `YYYY-MM-DD.md` | `2025-10-16.md` |
| Test results | `test-<id>-<desc>.md` | `test-a-data.md` |

---

## Application to rules-enforcement-investigation

### Current → Proposed Mapping

**Root** (7 → 4-5 files):
- ✅ Keep: README.md, erd.md, tasks.md, MONITORING-PROTOCOL.md
- 📝 Keep: coordination.md (create new)
- ➡️ Move: ci-integration-guide.md → guides/
- ➡️ Move: slash-commands-decision.md → decisions/
- ➡️ Move: findings.md → findings/README.md

**analysis/** (6 files → reorganize):
- ✅ Keep flat: discovery.md, test-plans-review.md
- 📁 Create folders: conditional-rules/, scalability/, premature-completion/, prompt-templates/

**archived-summaries/** → **_archived/**:
- Rename folder
- Move all 6 files

**test-execution/** (14 files → split):
- Protocols → protocols/
- Results → test-results/
- Sessions → sessions/
- Decisions → decisions/ (or remove duplicate)
- Pre-test discovery → become sub-projects

**tests/** (7 files):
- ✅ Keep as-is (structure works)

### Sub-Projects to Create

1. `h1-conditional-attachment/` - H1 test and validation
2. `h2-send-gate-investigation/` - H2 tests A-D
3. `h3-query-visibility/` - H3 tests A-C
4. `slash-commands-runtime-routing/` - Failed runtime routing attempt
5. `prompt-templates-experiment/` - Future: proper slash command usage

---

## When This Structure Applies

**Use this structure for**:
- Multi-hypothesis investigations (3+ hypotheses)
- Projects with substantial testing (5+ test plans)
- Long-running research (months, 30+ files)
- Projects with sub-components

**Don't use for**:
- Simple projects (<10 files)
- Single-focus work
- Short duration (<2 weeks)

**Guideline**: If you're creating more than 3 folders, you probably need this structure

---

## Related

- [rules-enforcement-investigation](../rules-enforcement-investigation/) - Example of unstructured growth
- [project-lifecycle.mdc](/.cursor/rules/project-lifecycle.mdc) - Will be updated with this guidance
- Gap #11 - Documentation structure not defined

