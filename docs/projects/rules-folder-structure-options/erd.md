---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Rules Folder Structure Options (Lite)

Mode: Lite


Links: `.cursor/rules/front-matter.mdc` | `.cursor/rules/rule-creation.mdc` | `.cursor/rules/rule-maintenance.mdc` | `.cursor/rules/rule-quality.mdc` | `docs/projects/project-organization/erd.md`

## 1. Introduction/Overview

Explore options to add more structure to `.cursor/rules/` for easier navigation, maintenance, and routing sanity. Produce a short list of viable structure patterns with trade-offs, an evaluation matrix, and a low-risk migration plan.

## 2. Goals/Objectives

- Clarify an organizational scheme for rules (categories, naming, pairing of `.mdc` and `.caps.mdc`).
- Reduce duplication and improve discoverability with predictable paths and cross-links.
- Define migration guidance that minimizes churn and broken links.
- Keep rules portable, self-contained, and consistent with existing validation.

## 3. Functional Requirements

1. Current State Inventory

   - Enumerate existing files under `.cursor/rules/` and categorize them.
   - Identify overlaps, duplicate guidance, and pairing gaps (`.caps.mdc` ↔ `.mdc`).

2. Structure Options (design and examples)

   - Option A — Flat + Prefixes: keep flat folder; enforce filename prefixes (e.g., `00-`, `workflow-`, `git-`).
   - Option B — Category Subfolders: group into `foundations/`, `workflows/`, `automation-routing/`, `git-ci/`, `rule-system/`.
   - Option C — Hybrid: category subfolders for large sets; keep a small flat root for global defaults.
   - For each option, show 3–5 representative files in their proposed locations.

3. Conventions & Contracts

   - File naming: kebab-case; no spaces; stable suffixes (`.mdc`, `.caps.mdc`).
   - Front matter: required keys and date hygiene (see `front-matter.mdc`).
   - Cross-links: “See also”/“Depends on” patterns; index/readme pointers.

4. Validation & Tooling

   - Assess whether existing validators need updates (caps pairing, link checks, broad globs warnings).
   - Define simple checks for category consistency and forbidden wildcards.

5. Migration Plan

   - Draft a phased plan: prepare, move, link-fix, validate, announce.
   - Provide guidance for redirect notes or stub files where necessary.

## 4. Acceptance Criteria

- Options document (matrix) comparing at least three structures across criteria: discoverability, maintenance effort, routing clarity, churn risk, portability.
- Sample tree for the recommended option with at least 10 representative files mapped.
- Clear naming/cross-linking conventions documented.
- Migration plan with checkpoints and validation steps.
- No broken internal links in rules after migration (verified by validator).

## 5. Risks/Edge Cases

- Over-structuring adds friction; keep minimal categories and stable paths.
- Link rot during migration; mitigate with validation and redirect notes.
- CI/docs scripts may assume current paths; audit before moving.

## 6. Rollout Plan

- Phase 1: Inventory and options draft (no moves).
- Phase 2: Validate recommended structure on a branch; fix validators and links.
- Phase 3: Migrate in one PR with clear changeset and comms; archive old paths if needed.

## 7. Testing

- Run rules validation and link checks; paste exact outputs and fix findings.
- Spot-check routing triggers against representative prompts after any path changes.

---

Owner: rules-maintainers

Last updated: 2025-10-11
