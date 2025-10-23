---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Enterprise Portable Workflow Toolkit

**Links**: [ai-workflow-integration](../ai-workflow-integration/erd.md) | [portability](../portability/erd.md)

## 1. Introduction/Overview

Extract the FULL enterprise-grade workflow from cursor-rules (ERD → Plan → Tasks → Analyze → Implement) and make it **portable across Fortune 500 projects** with zero code changes. Goal: Drop into any enterprise environment, run config wizard, get full workflow capabilities without hardcoded assumptions about folder structure, tooling, or processes.

**Context**: User needs to use this workflow across multiple Fortune 500 projects with different tech stacks, compliance requirements, and tooling ecosystems (Jira vs GitHub Issues, GitLab vs GitHub, etc.).

## 2. Goals/Objectives

- **Full-featured portability**: ALL cursor-rules capabilities, ZERO hardcoding
- **Configuration-driven**: Paths, tools, and conventions via config file
- **Adapter-based integration**: Plug in existing enterprise tools (Jira, GitLab, CircleCI)
- **Multi-project validated**: Works in 2-3 different Fortune 500 environments
- **Zero-touch migration**: No code changes when moving between projects
- **Preserve enterprise features**: 14-section ERDs, 7-stage lifecycle, validation periods, dependencies/priority, full automation

## 3. Functional Requirements

### 1. Configuration System

**Config file** (`.workflow/config.json` or `workflow-config.json`):

```json
{
  "structure": {
    "projectsRoot": "docs/projects",
    "rulesDir": ".cursor/rules",
    "plansDir": "docs/plans",
    "specsDir": "docs/specs",
    "erdFilename": "erd.md",
    "tasksFilename": "tasks.md"
  },
  "tools": {
    "issueTracker": "github|jira|linear",
    "ciSystem": "github-actions|gitlab-ci|circleci",
    "vcs": "github|gitlab|bitbucket"
  },
  "features": {
    "slashCommands": true,
    "validationPeriods": true,
    "fullLifecycle": true,
    "dependenciesTracking": true
  },
  "templates": {
    "erdMode": "full|lite",
    "customSections": []
  }
}
```

**Config wizard**: Interactive setup that detects environment and generates config.

### 2. Full Template Suite (Config-Aware)

**All cursor-rules templates**, but parameterized:

- Full ERD (14 sections) — paths/structure from config
- Lite ERD (6 sections) — optional mode
- Spec template — uses `specsDir` from config
- Plan template — uses `plansDir` from config
- Tasks template — uses `tasksFilename` from config
- Acceptance bundle — tool-agnostic schema

### 3. Tool Adapters (Pluggable)

**Issue Tracker Adapter Interface**:

- `createIssue(title, body, labels)`
- `updateIssue(id, changes)`
- `linkIssues(parentId, childIds)`
- `getIssue(id)`

**Implementations**:

- GitHub Issues adapter
- Jira adapter
- Linear adapter
- Generic REST adapter (for custom systems)

**CI Adapter Interface**:

- `triggerWorkflow(name, params)`
- `getStatus(workflowId)`
- `waitForCompletion(workflowId)`

**Implementations**:

- GitHub Actions adapter
- GitLab CI adapter
- CircleCI adapter

### 4. Validators (Config-Driven)

**All cursor-rules validators**, reading config:

- ERD validator — checks sections based on `erdMode`
- Tasks validator — validates against configured structure
- Cross-link validator — resolves paths from config
- Lifecycle validator — checks stages if `fullLifecycle` enabled
- Acceptance bundle validator

### 5. Automation Scripts (Adapter-Based)

**All cursor-rules scripts**, but parameterized:

- `project-create.sh` — scaffolds using config paths
- `project-status.sh` — reads from config structure
- `erd-validate.sh` — validates against config template
- `pr-create.sh` — uses VCS adapter
- All other scripts adapted for config-driven operation

### 6. Migration Tool

**Cursor-rules → Portable converter**:

- Scans existing cursor-rules project
- Detects all paths, conventions, integrations
- Generates portable config
- Rewrites references to use config placeholders
- Validates conversion

## 4. Acceptance Criteria

1. **Feature Completeness**:

   - ALL cursor-rules capabilities available (no feature reduction)
   - Full ERD (14 sections), Lite ERD (6 sections), Spec/Plan/Tasks
   - 7-stage lifecycle with validation periods
   - Dependencies, priority, parallelizable markers
   - Slash commands (where supported)
   - Full automation suite

2. **Zero-Hardcoding**:

   - NO hardcoded paths (all from config)
   - NO hardcoded tool names (all via adapters)
   - NO hardcoded conventions (all configurable)
   - NO code changes when moving between projects

3. **Multi-Environment Validation**:

   - Deploy to 3 different Fortune 500 projects:
     - Different tech stacks (e.g., Java, Python, Go)
     - Different companies (different tooling/compliance)
     - Different VCS (GitHub, GitLab)
   - Each validation: Full workflow (ERD → Tasks → Implement) without code changes
   - Success = Same workflow experience across all environments

4. **Adapter Coverage**:

   - GitHub Issues, Jira, Linear (at least 2 working)
   - GitHub Actions, GitLab CI (at least 1 working)
   - GitHub, GitLab (both working)

5. **Migration Path**:

   - Existing cursor-rules project → portable config in < 1 hour
   - Automated converter handles 90% of work
   - Clear manual steps for remaining 10%

6. **Documentation**:
   - Config reference (all options documented)
   - Adapter development guide (how to add new tools)
   - Multi-project deployment guide
   - Troubleshooting for common enterprise constraints

## 5. Risks/Edge Cases

### Risks

- **Tool integration complexity**: Each Fortune 500 has unique tooling

  - Mitigation: Adapter pattern isolates integration logic
  - Fallback: Generic REST adapter + manual API config

- **Compliance variations**: Different audit/security requirements per company

  - Mitigation: Config sections for compliance hooks
  - Example: `validationHooks: { preCommit: "./compliance/check.sh" }`

- **Conflicting conventions**: Projects have established folder structures

  - Mitigation: Config respects existing structure
  - Example: Use their `engineering/rfcs/` instead of `docs/projects/`

- **Migration complexity**: Cursor-rules projects are deeply integrated

  - Mitigation: Automated converter + validation suite
  - Acceptance: 80% automated, 20% documented manual steps

- **Maintenance burden**: Keep toolkit in sync with cursor-rules innovations
  - Mitigation: Toolkit IS the source; cursor-rules is one deployment
  - Strategy: Dogfood — use toolkit config for cursor-rules itself

### Edge Cases

- **Air-gapped environments**: No external tool APIs

  - Solution: File-based adapters (write to `.workflow/issues/`, CI picks up)

- **Legacy systems**: Ancient issue trackers with no API

  - Solution: Template generation → manual copy-paste → validation

- **Custom workflows**: Company has 10-stage lifecycle

  - Solution: Config overrides for custom stages

- **Restricted permissions**: Can't install tools/scripts

  - Solution: Pure markdown workflow + manual validator checklist

- **Monorepos**: 50+ projects in one repo
  - Solution: Per-project `.workflow/` config with inheritance

## 6. Rollout Note

**Phase 1 — Core Infrastructure** (1-2 weeks):

- Design config schema and adapter interfaces
- Implement config loader and validator
- Create GitHub adapter (reference implementation)
- Parameterize all templates to use config

**Phase 2 — Adapters & Scripts** (2-3 weeks):

- Implement Jira adapter
- Implement GitLab adapter
- Refactor all cursor-rules scripts to be config-driven
- Build migration tool (cursor-rules → portable)

**Phase 3 — Validation** (1-2 weeks):

- Deploy to Fortune 500 project #1 (measure friction)
- Deploy to Fortune 500 project #2 (different stack/company)
- Deploy to Fortune 500 project #3 (different VCS)
- Iterate based on real-world feedback

**Phase 4 — Documentation & Dogfooding** (1 week):

- Write config reference and adapter dev guide
- Convert cursor-rules to use portable toolkit
- Validate: cursor-rules works identically via toolkit config
- Publish standalone toolkit repo

## 7. Testing

### Per-Environment Validation

For each of 3 Fortune 500 projects:

1. **Setup** (should be < 2 hours):

   - Run config wizard
   - Install toolkit
   - Configure adapters for their tools
   - Validate all scripts executable

2. **Workflow Test** (full cycle):

   - Create new ERD (14 sections)
   - Generate Plan with acceptance bundle
   - Generate Tasks (two-phase with dependencies)
   - Run `/analyze` gate
   - Validate all artifacts
   - Create PR via adapter
   - Check CI integration

3. **Success Criteria**:
   - Zero code changes to toolkit
   - Same workflow experience as cursor-rules
   - All automation working
   - Team can adopt without external help

### Automated

- CI tests for each adapter (mocked responses)
- Config validation suite
- Template generation smoke tests
- Cross-reference resolver tests

## 8. Success Metrics

- **Zero-touch portability**: 3/3 Fortune 500 projects with NO code changes
- **Feature parity**: 100% of cursor-rules features available
- **Setup time**: < 2 hours per new project (vs days of manual adaptation)
- **Maintenance**: 1 codebase → N deployments (not N copies)
- **Adoption**: User can use across all their Fortune 500 projects
- **Dogfooding**: Cursor-rules itself runs on toolkit config

## 9. Non-Goals

- **Not building**: Minimal/"lite" version (user needs full enterprise features)
- **Not targeting**: Small teams or open source projects (wrong use case)
- **Not simplifying**: Workflow structure (complexity is necessary at Fortune 500 scale)
- **Not avoiding**: Enterprise integrations (that's the whole point)

## 10. User Stories

- As a Fortune 500 engineer, I want to use the same workflow across my Java microservices project (Company A with Jira) and my Python ML platform (Company B with GitHub Issues) without relearning or reconfiguring.

- As a project lead, I want to onboard new team members to our workflow by pointing them to the toolkit, regardless of whether we're using GitHub or GitLab.

- As a compliance officer, I want to inject our security gates into the workflow without modifying the core toolkit code.

- As a toolkit maintainer, I want to add new features once and have them available across all my Fortune 500 deployments instantly.

## 11. Related Work

- [ai-workflow-integration](../ai-workflow-integration/erd.md) — Source of unified workflow
- [portability](../portability/erd.md) — Taxonomy framework (reframe for enterprise)
- [ai-workflow-integration/portability-analysis.md](../ai-workflow-integration/portability-analysis.md) — Extraction guidance (now enterprise-focused)

---

**Owner**: rules-maintainers  
**Status**: Active (queued after ai-workflow-integration completion)  
**Last Updated**: 2025-10-23  
**Priority**: High (enables multi-project Fortune 500 usage)
