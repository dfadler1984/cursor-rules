# Engineering Requirements Document — Tooling Discovery

Mode: Lite

## 1. Introduction/Overview

Identify gaps, fragility, and duplication in our developer tooling across the repo (linting, testing, release/versioning, CI, security, documentation, scripts). Produce a clear inventory and a prioritized backlog to close the most impactful gaps first.

## 2. Goals/Objectives

- Provide a repo-wide tooling inventory (what exists, where it lives, how it’s enforced)
- Detect missing or weakly enforced tools and standards
- Score gaps by impact × effort and propose pragmatic next steps
- Produce a small, actionable backlog with owners and acceptance checks

## 3. Functional Requirements

1. Inventory capture
   - Catalog tools/configs by category: code style (ESLint/Prettier), tests (Jest + shell), builds, release/versioning (Changesets), CI workflows, Git hooks, security/licensing scans, docs tooling, local scripts
   - Map locations: `.cursor/scripts/`, `.github/workflows/`, `package.json` scripts, config files (e.g., `.eslintrc*`, `jest.*`, `tsconfig.*`)
2. Signals and probes (read-only)
   - Parse presence of configs and scripts; avoid networked calls
   - Note enforcement level: optional docs only vs CI gate vs pre-commit/pre-push
3. Artifacts
   - Tooling inventory matrix (category → present/configured/enforced/owner)
   - Gap list with recommendation and quick-win notes
   - Scoring rubric (Impact: High/Med/Low; Effort: S/M/L)
4. Backlog
   - Top 3–5 gaps with owners, measurable acceptance, and target dates

## 4. Acceptance Criteria

- `docs/projects/tooling-discovery/tasks.md` contains a prioritized backlog seeded from the inventory
- Inventory matrix drafted with at least 10 representative categories
- Each identified gap includes: recommendation, owner, acceptance check, and estimated effort
- No network calls or sensitive data reads during discovery; local-only, read-only

### 4.1 Inventory Matrix (Starter)

| Category          | Present | Config File(s)                                  | Enforcement | Owner     |
| ----------------- | ------- | ----------------------------------------------- | ----------- | --------- |
| ESLint/Prettier   | TBD     | `.eslintrc*`, `.prettierrc*`                    | TBD         | TBD       |
| Jest (JS/TS)      | TBD     | `jest.*`, `package.json` scripts                | TBD         | TBD       |
| Shell tests       | Yes     | `.cursor/scripts/tests/run.sh`                  | Partial     | eng-tools |
| Changesets        | Yes     | `.changeset/`, `package.json`                   | CI gated    | eng-tools |
| CI Workflows      | Yes     | `.github/workflows/*.yml`                       | Mixed       | eng-tools |
| Security scans    | TBD     | `scripts/security*`                             | TBD         | TBD       |
| Git hooks         | TBD     | `.husky/`, scripts                              | TBD         | TBD       |
| Project lifecycle | Yes     | `.cursor/scripts/validate-project-lifecycle.sh` | Optional    | eng-tools |
| Docs checks       | Yes     | `.cursor/scripts/links-check.sh`                | Optional    | eng-tools |
| Logging (ALP)     | Yes     | `.cursor/scripts/alp-*.sh`                      | Local-only  | eng-tools |

## 5. Risks/Edge Cases

- False positives/negatives from config drift or unused files
- Platform differences (macOS vs Linux) for shell tooling; prefer portable checks
- Over-scoping; keep initial pass to inventory + top gaps

## 6. Rollout Note

- Flag: tooling-discovery • Owner: eng-tools • Target: 2025-10-15

## 7. Testing

- Review: spot-check 3–5 categories against the repo to verify inventory accuracy
- Validation: confirm top gaps with maintainers before scheduling work

---

### Convert to Full ERD

- Add Architecture/Design (discovery method, data model for the matrix)
- Add Ops (how to keep the inventory fresh; cadence, ownership)
- Add Non-Functional Requirements (performance of scans, portability)
