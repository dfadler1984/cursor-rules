---
status: archived
---
# Engineering Requirements Document — Deterministic, Structured Outputs

Mode: Full

Scope note: This Full ERD covers artifact contracts plus architecture, non-functional requirements, data, APIs, rollout/ops, testing/acceptance, and success metrics. Implementation/scaffolding remains out of scope unless explicitly requested with consent.

## 1. Introduction/Overview

We need predictable, reusable artifacts for planning and execution: specifications, plans, and task lists. Today, outputs can vary in format and completeness, which makes automation and cross-repo reuse harder. This ERD standardizes the artifact templates, cross-linking, naming, and validation rules so that planning is deterministic and directly usable by humans and tools.

## 2. Goals/Objectives

- Define canonical templates for Specs, Plans, and Tasks with minimum required sections
- Enforce cross-links across sibling artifacts and consistent kebab-case feature names
- Require an acceptance bundle that ties planning to execution with measurable checks
- Provide validation rules to detect missing sections, broken links, and naming drift
- Align with portability config (`artifacts.*Dir`) and house style rules (markdown/code citation)

## 2.1 User Stories

- As a rules maintainer, I want predictable Spec/Plan/Tasks artifacts so that automation and reviews are straightforward.
- As a contributor, I want clear templates and acceptance bundles so that I can implement with confidence.
- As a tooling integrator, I want stable file locations and headings so that validators and generators are reliable.

## 2.2 Non-Functional Requirements

- Performance: Validation runs should complete under a few seconds on typical repositories.
- Reliability: Templates and validation rules must be backward-compatible with minor revisions.
- Security/Privacy: ERDs and artifacts must not expose secrets; follow redaction rules.
- Portability: Respect `artifacts.*Dir` and avoid absolute paths in configuration.
- Cost: No new heavy dependencies by default.

## 2.3 Architecture/Design

- Effects boundary: Keep validators and scaffolds as separate scripts/modules; domain logic for contracts remains pure.
- Deterministic templates: Define minimal required headings; avoid optional prose in validators.
- Cross-link strategy: Use relative links; compute expected sibling paths from configuration.

## 2.4 Data Model and Storage

- No database changes. Filesystem artifacts stored under configured directories.
- Optional cache for discovery/validation results may be stored as JSON under a temp directory.

## 2.5 API/Contracts

- CLI contract (validator):

  - Command: `node scripts/rules/validate-artifacts.ts [--paths <csv>] [--format json|text] [--fail-on any|missing-headings|broken-links|naming-drift] [--help] [--version]`
  - Behavior: Validates required headings, sibling cross-links, and kebab-case `<feature>` consistency. For JS/TS tasks, checks `ownerSpecs` presence in acceptance bundles.
  - Exit codes:
    - `0`: no validation errors
    - `1`: validation errors present (category flagged by `--fail-on`)
    - `2`: usage/configuration error
  - Output:
    - `--format json` (default): prints a JSON summary with counts and details per file
    - `--format text`: prints a human-readable summary
  - Example:

    ```bash
    node scripts/rules/validate-artifacts.ts --paths docs/specs/sample-feature-spec.md,docs/plans/sample-feature-plan.md --format json --fail-on any | jq
    ```

- Template contract: Required headings and link presence as specified in 3.1.

## 2.6 Integrations/Dependencies

- GitHub/CI: Optional wiring for pre-merge checks.
- Local scripts: Integrate with repository scripts under `scripts/` when present; avoid mandatory dependencies.

## 2.7 Success Metrics

- ≥ 90% of newly created artifacts pass validation on first run.
- Reduction in review comments about structure by ≥ 50% over two weeks.
- Consistent cross-links across artifacts in target repositories.

## 3. Functional Requirements

### 3.1 Artifact Templates (minimum required sections)

Specs live at `docs/specs/<feature>-spec.md`, Plans at `docs/plans/<feature>-plan.md`, and Tasks at `projects/<feature>/tasks/tasks-<feature>.md`. All three must use the following minimal structures.

```markdown
# <feature> Spec

## Overview

## Goals

## Functional Requirements

## Acceptance Criteria

## Risks/Edge Cases

[Links: Plan | Tasks]
```

Example links line (feature: `sample-feature`):

```markdown
[Links: Plan] (../plans/sample-feature-plan.md)
```

```markdown
# <feature> Plan

## Steps

## Acceptance Bundle

## Risks

[Links: Spec | Tasks]
```

Example links line (feature: `sample-feature`):

```markdown
[Links: Spec] (../specs/sample-feature-spec.md)
```

```markdown
# Tasks — <feature>

## Relevant Files

## Todo
```

Single active sub-task progression example:

```markdown
- [x] Initialize templates and links
- [ ] Author deterministic-outputs rule (active)
- [ ] Update README with links
```

Additional template rules:

- Filenames must use the same `<feature>` (kebab-case) across all three artifacts
- Each artifact must include top-of-file sibling links using the `[Links: ...]` line shown above
- Tasks files must keep exactly one active sub-task at any time

### 3.2 Acceptance Bundle (schema and example)

The Plan must include a machine-checkable acceptance bundle with at least these keys:

- `targets`: list of files/components to change
- `exactChange`: single imperative sentence describing the change
- `successCriteria`: measurable checks (e.g., specific spec names or visible outputs)
- `constraints`: optional perf/compat notes
- `runInstructions`: commands to verify behavior
- `ownerSpecs`: for JS/TS tasks, the owner spec path(s) required by TDD-first

Example:

```json
{
  "targets": ["src/parse.ts", "src/parse.spec.ts"],
  "exactChange": "Validate CSV-only globs in parse.ts",
  "successCriteria": ["Spec 'rejects bracketed globs' passes"],
  "constraints": ["No new dependencies"],
  "runInstructions": [
    "yarn test src/parse.spec.ts -t 'rejects bracketed globs'"
  ],
  "ownerSpecs": ["src/parse.spec.ts"]
}
```

### 3.3 Validation Rules

- Reject artifacts missing required headings listed in 3.1
- Verify that sibling cross-links resolve to existing files
- Enforce kebab-case `<feature>` consistency across spec/plan/tasks filenames
- When JS/TS changes are planned, ensure `ownerSpecs` are present and match colocated files
- Enforce house style for markdown and code citations (see `markdown_spec` and `citing_code` rules)

### 3.4 Portability and Configuration

- Respect `artifacts.*Dir` from repository configuration for write locations
- Default directories:
  - Specs: `docs/specs`
  - Plans: `docs/plans`
  - Tasks: `tasks`
- Cross-links must update automatically or be verified when directories are overridden

## 4. Acceptance Criteria

- Templates: New Specs/Plans/Tasks use the exact section headings shown in 3.1
- Cross-links: Each artifact contains sibling links that resolve to existing paths
- Naming: All three artifacts share the same kebab-case `<feature>` name
- Acceptance bundle: Each Plan includes a bundle with required keys; JS/TS tasks include `ownerSpecs`
- Validation: A validator can detect missing headings, broken links, and naming drift (manual or scripted)
- House style: Outputs adhere to markdown structure and code citation rules without mixing formats

## 5. Risks/Edge Cases

- Over-constraining formats could reduce flexibility; templates are intentionally minimal
- Cross-repo differences in directory layout; mitigated by `artifacts.*Dir` alignment
- Manual edits drifting from templates; mitigated by validation and example scaffolds

## 6. Rollout Note

- Flag: deterministic-outputs
- Owner: rules-maintainers
- Target: 2025-10-09
- Comms: Link new templates and rules from `README.md`; reference validator guidance

## 7. Testing

- Create a sample trio (`<feature>=sample-feature`) and verify:
  - Required headings exist and cross-links resolve
  - Filenames align on `<feature>` and kebab-case
  - Acceptance bundle includes required keys; JS/TS tasks include `ownerSpecs`
- If a validator exists, run it to confirm it flags missing sections or link/name mismatches

## 8. Open Questions

- Do we need additional required headings for specific feature types?
- Should acceptance bundles include coverage thresholds or performance budgets by default?
- Preferred language/runtime for a validator CLI if/when implemented?
