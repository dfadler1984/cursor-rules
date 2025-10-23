# Active Project Monitoring

**Purpose**: Track which projects are actively monitoring for issues and where to document findings  
**Last Updated**: 2025-10-23

---

## How to Use This File

**Before documenting a finding**, ask:

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
   - Cross-reference from other projects if relevant

---

## Currently Active Monitoring

### routing-optimization

| **Field**           | **Value**                                                                                                                                                                                    |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Status**          | 🔄 Active (Phase 3 validation)                                                                                                                                                               |
| **Started**         | 2025-10-23                                                                                                                                                                                   |
| **Duration**        | 1 week (ends ~2025-10-30)                                                                                                                                                                    |
| **Findings Path**   | `docs/projects/routing-optimization/phase3-findings.md`                                                                                                                                      |
| **Pattern**         | `## Finding #N: <title>` sections in single file                                                                                                                                             |
| **Scope**           | Intent routing accuracy (which rules attach to user requests)                                                                                                                                |
| **Monitors**        | • Intent recognition failures (wrong rules attached)<br>• Trigger pattern mismatches<br>• File signal vs intent conflicts<br>• Multi-intent handling issues<br>• Confidence scoring accuracy |
| **Out of Scope**    | • Execution compliance (following attached rules)<br>• Rule content quality<br>• Workflow automation issues                                                                                  |
| **Cross-Reference** | If execution failure observed → See rules-enforcement-investigation                                                                                                                          |

---

### rules-enforcement-investigation

| **Field**           | **Value**                                                                                                                                                                                                                   |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Status**          | ✅ Complete (Active) — Ongoing execution monitoring                                                                                                                                                                         |
| **Started**         | 2025-10-15                                                                                                                                                                                                                  |
| **Duration**        | Continuous (no end date)                                                                                                                                                                                                    |
| **Findings Path**   | `docs/projects/rules-enforcement-investigation/findings/`                                                                                                                                                                   |
| **Pattern**         | `gap-##-<short-name>.md` (individual files, numbered)                                                                                                                                                                       |
| **Scope**           | Rule execution and compliance (following attached rules)                                                                                                                                                                    |
| **Monitors**        | • AlwaysApply rule violations<br>• Execution failures (rule loaded but ignored)<br>• Investigation methodology gaps<br>• Self-improve pattern violations<br>• Changeset policy violations<br>• TDD pre-edit gate violations |
| **Out of Scope**    | • Intent routing accuracy (which rules attach)<br>• Rule trigger patterns                                                                                                                                                   |
| **Cross-Reference** | If routing failure observed → See routing-optimization                                                                                                                                                                      |

---

## Project Scope Quick Reference

### Routing vs Execution

| **Symptom**                                | **Category** | **Project**                     | **Example**                                               |
| ------------------------------------------ | ------------ | ------------------------------- | --------------------------------------------------------- |
| User says "implement X", guidance attached | Routing      | routing-optimization            | Intent misread, wrong rules attached                      |
| User says "implement X", TDD rule ignored  | Execution    | rules-enforcement-investigation | Rule loaded but pre-edit gate skipped                     |
| File signal overrides user intent          | Routing      | routing-optimization            | Editing test file + ask guidance → testing rules attached |
| AlwaysApply rule present but violated      | Execution    | rules-enforcement-investigation | self-improve.mdc loaded, "don't wait" ignored             |

### Workflow vs Behavior

| **Symptom**                              | **Category** | **Project**                     | **Example**                                           |
| ---------------------------------------- | ------------ | ------------------------------- | ----------------------------------------------------- |
| GitHub Action auto-labels incorrectly    | Workflow     | github-workflows-utility        | Auto-applies skip-changeset despite changeset present |
| PR script doesn't handle flags correctly | Workflow     | pr-create-decomposition         | Script missing --with-changeset flag                  |
| Assistant doesn't use repo script        | Execution    | rules-enforcement-investigation | Used manual git command instead of git-commit.sh      |

---

## Paused/Completed Monitoring

### assistant-self-improvement

| **Field**  | **Value**                                                 |
| ---------- | --------------------------------------------------------- |
| **Status** | ⏸️ Paused (deprecated auto-logging)                       |
| **Note**   | Pattern observation still active; auto-logging deprecated |
| **See**    | `docs/projects/assistant-self-improvement/legacy/`        |

---

## Adding New Monitoring Projects

When starting new investigation/monitoring project:

1. **Update this file**:

   - Add project to "Currently Active Monitoring" section
   - Specify scope, findings location, pattern
   - Define "Out of Scope" explicitly

2. **Update project README/tasks**:

   - Add "Monitoring Status" section
   - Link to this file for disambiguation

3. **Cross-reference**:
   - Link related monitoring projects
   - Clarify boundaries between them

---

## Quick Decision Tree

```
Observed issue during work:
│
├─ Is this about WHICH rules attach to user requests?
│  └─ YES → routing-optimization
│      Location: docs/projects/routing-optimization/phase3-findings.md
│      Pattern: ## Finding #N: <title>
│
├─ Is this about FOLLOWING attached rules?
│  └─ YES → rules-enforcement-investigation
│      Location: docs/projects/rules-enforcement-investigation/findings/gap-##-<name>.md
│      Pattern: Individual file per gap, numbered sequentially
│
├─ Is this about GitHub Actions/workflows?
│  └─ YES → github-workflows-utility
│      Location: docs/projects/github-workflows-utility/tasks.md (Real-World Issues section)
│
├─ Is this about PR creation scripts?
│  └─ YES → pr-create-decomposition
│      Location: docs/projects/pr-create-decomposition/tasks.md (Real-World Issues section)
│
└─ Unclear?
   └─ Ask user: "This seems like [X] issue. Should I document in [project]?"
```

---

## Related

- See individual project ERDs for full scope definitions
- See `docs/projects/README.md` for project index
- See `.cursor/rules/investigation-structure.mdc` for investigation organization

---

**Purpose**: Prevent cross-project confusion and ensure findings documented in correct location  
**Audience**: Assistant (primary), maintainers (secondary)  
**Updates**: Add projects when new monitoring starts; mark complete when monitoring ends
