# Active Project Monitoring

**Purpose**: Track which projects are actively monitoring for issues and where to document findings  
**Last Updated**: 2025-10-24

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

### blocking-tdd-enforcement

| **Field**           | **Value**                                                                                                                                                                                                                                              |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Status**          | 🔄 Active (Phase 2-3: user testing + monitoring)                                                                                                                                                                                                       |
| **Started**         | 2025-10-24                                                                                                                                                                                                                                             |
| **Duration**        | 1 week (ends ~2025-10-31)                                                                                                                                                                                                                              |
| **Findings Path**   | `docs/projects/blocking-tdd-enforcement/` (inline in README/tasks)                                                                                                                                                                                     |
| **Pattern**         | Document violations/issues inline in monitoring sections                                                                                                                                                                                               |
| **Scope**           | TDD gate blocking effectiveness (file pairing validation preventing violations)                                                                                                                                                                        |
| **Monitors**        | • TDD violations (creating impl sources without tests)<br>• False positives (legitimate files blocked)<br>• Gate trigger accuracy<br>• Batch creation handling<br>• Error message clarity<br>• **Temporal ordering** (Gap #23: test-first enforcement) |
| **Out of Scope**    | • TDD scope (which files need TDD) → tdd-scope-boundaries<br>• Test quality → test-quality rules<br>• Intent routing                                                                                                                                   |
| **Cross-Reference** | If scope question → tdd-scope-boundaries<br>If gate bypassed → rules-enforcement-investigation                                                                                                                                                         |
| **Evidence**        | Gap #22 (created file without test), Gap #23 (edited file without test-first, 5 min after gate deployed); 13 violations total                                                                                                                          |

---

### rules-enforcement-investigation

| **Field**           | **Value**                                                                                                                                                                                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Status**          | ✅ Complete (Active) — Ongoing execution monitoring                                                                                                                                                                                               |
| **Started**         | 2025-10-15                                                                                                                                                                                                                                        |
| **Duration**        | Continuous (no end date)                                                                                                                                                                                                                          |
| **Findings Path**   | `docs/projects/rules-enforcement-investigation/findings/`                                                                                                                                                                                         |
| **Pattern**         | `gap-##-<short-name>.md` (individual files, numbered)                                                                                                                                                                                             |
| **Scope**           | Rule execution and compliance (following attached rules)                                                                                                                                                                                          |
| **Monitors**        | • AlwaysApply rule violations<br>• Execution failures (rule loaded but ignored)<br>• Investigation methodology gaps<br>• Self-improve pattern violations<br>• Changeset policy violations<br>• **TDD pre-edit gate violations** (Gap #22: latest) |
| **Out of Scope**    | • Intent routing accuracy (which rules attach)<br>• Rule trigger patterns                                                                                                                                                                         |
| **Cross-Reference** | If routing failure observed → See routing-optimization                                                                                                                                                                                            |

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

### tdd-scope-boundaries

| **Field**           | **Value**                                                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Status**          | 🔄 Active (Phase 3 validation - monitoring period)                                                                                                                                                            |
| **Started**         | 2025-10-24                                                                                                                                                                                                    |
| **Duration**        | 1 week (ends ~2025-10-31)                                                                                                                                                                                     |
| **Findings Path**   | `docs/projects/tdd-scope-boundaries/findings/`                                                                                                                                                                |
| **Pattern**         | `issue-##-<short-name>.md` (individual files, numbered)                                                                                                                                                       |
| **Scope**           | TDD scope check accuracy (does the right gate trigger for the right files?)                                                                                                                                   |
| **Monitors**        | • False negatives (code changes skip TDD gate)<br>• False positives (docs/configs trigger TDD gate)<br>• Ambiguity rate (% requiring clarification)<br>• Edge cases (file types not covered by current globs) |
| **Out of Scope**    | • Intent routing (which rules attach to requests)<br>• Execution compliance (was TDD gate followed after triggering)<br>• Rule content quality                                                                |
| **Cross-Reference** | If routing failure observed → See routing-optimization<br>If execution failure observed → See rules-enforcement-investigation                                                                                 |

---

### consent-gates-refinement

| **Field**           | **Value**                                                                                                                                                                                                                                        |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Status**          | 🔄 Active (Phase 3 validation - monitoring period)                                                                                                                                                                                               |
| **Started**         | 2025-10-24                                                                                                                                                                                                                                       |
| **Duration**        | 1-2 weeks (ends ~2025-11-07)                                                                                                                                                                                                                     |
| **Findings Path**   | `docs/projects/consent-gates-refinement/validation-findings.md`                                                                                                                                                                                  |
| **Pattern**         | `## Finding #N: <title>` sections in single file                                                                                                                                                                                                 |
| **Scope**           | Consent gate behavior accuracy (prompting frequency, state tracking, allowlist functionality)                                                                                                                                                    |
| **Monitors**        | • Over-prompting instances (unnecessary consent requests)<br>• Under-prompting instances (risky ops without consent)<br>• Session allowlist behavior<br>• Composite consent detection accuracy<br>• State tracking issues<br>• Category switches |
| **Out of Scope**    | • Intent routing (which rules attach)<br>• Rule execution (following TDD/testing rules)<br>• Workflow automation                                                                                                                                 |
| **Cross-Reference** | If routing failure observed → See routing-optimization<br>If execution failure observed → See rules-enforcement-investigation                                                                                                                    |

---

## Paused/Completed Monitoring

### routing-optimization

| **Field**         | **Value**                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------- |
| **Status**        | ✅ Complete — Archived 2025-10-24                                                                             |
| **Started**       | 2025-10-23                                                                                                    |
| **Completed**     | 2025-10-24                                                                                                    |
| **Final Results** | 100% routing accuracy (baseline: 68%), 0% false positives, all optimizations validated                        |
| **Archived To**   | `docs/projects/_archived/2025/routing-optimization/`                                                          |
| **Key Finding**   | Intent override tier + multi-intent handling + confidence scoring achieved perfect routing (25/25 tests pass) |

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
├─ Is this about TDD gate BLOCKING (file pairing enforcement)?
│  └─ YES → blocking-tdd-enforcement
│      Location: docs/projects/blocking-tdd-enforcement/ (inline in README/tasks)
│      Monitor: Violations, false positives, gate accuracy
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
├─ Is this about TDD scope check accuracy (which files trigger TDD gate)?
│  └─ YES → tdd-scope-boundaries
│      Location: docs/projects/tdd-scope-boundaries/findings/issue-##-<name>.md
│      Pattern: Individual file per issue, numbered sequentially
│
├─ Is this about consent gate behavior (prompting frequency, state tracking)?
│  └─ YES → consent-gates-refinement
│      Location: docs/projects/consent-gates-refinement/validation-findings.md
│      Pattern: ## Finding #N: <title>
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
