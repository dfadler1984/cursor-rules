---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Project Lifecycle Hardening (Full)

Mode: Full

Links: `docs/projects/project-lifecycle-hardening/tasks.md` | `.cursor/templates/project-lifecycle/`

## 1. Introduction/Overview

Harden the project lifecycle process for consistency, portability, and light enforcement. Centralize templates under `.cursor/templates/project-lifecycle/`, encode usage in a rule (not per‑project READMEs), add front matter + versioning to templates, introduce a scoped CI validator, improve discoverability and archival, and standardize completion signals (retrospective + metrics, changelog guidance).

## 2. Goals/Objectives

- Centralize lifecycle templates under `.cursor/templates/project-lifecycle/` for portability.
- Encode usage/policy in a dedicated `project-lifecycle` rule.
- Add template front matter (`template`, `version`, `last-updated`).
- Add a lightweight, path‑scoped CI validator for closeout artifacts.
- Require a brief retrospective/impact section when closing.
- Improve discoverability (Active vs Completed index) and define archival layout.
- Provide guidance for finalizing PR titles so they appear in `CHANGELOG.md`.

## 3. User Stories

- As a maintainer, I want a repeatable lifecycle so projects finish cleanly.
- As a contributor, I want templates that are easy to locate and instantiate.
- As a reviewer, I want CI to catch missing closeout artifacts without noise.

## 4. Functional Requirements

1. Templates Canonicalization

   - Create canonical templates at `.cursor/templates/project-lifecycle/`:
     - `final-summary.template.md`, `completion-checklist.template.md`, `retrospective.template.md`.
   - Each template includes front matter:
     - `template: project-lifecycle/<name>`, `version: 1.0.0`, `last-updated: YYYY-MM-DD`.
   - Project instances live under `docs/projects/<project>/`.

2. Rule Updates (Usage Encoded)

   - Add/extend a `project-lifecycle` rule documenting: how to instantiate templates; required artifacts to mark complete; PR title guidance (`feat: Finalize <Project>` or similarly scoped) so entries land in `CHANGELOG.md`.
   - No dedicated PR template required; opt‑in guidance only.

3. CI Validator (Scoped)

   - Script path: `.cursor/scripts/validate-project-lifecycle.sh` (+ `*.test.sh`).
   - Scope to projects changed in a PR.
   - Checks (per changed project):
     - `docs/projects/<project>/final-summary.md` exists, non‑empty, has front matter `template` + `version`, and contains an “Impact”/metrics section.
     - `docs/projects/<project>/tasks.md` exists and either all items are checked or a `Carryovers` section is present.
     - `retrospective.md` present at close, or a `Retrospective` section in the final summary.
     - No template files under project folders (templates must originate from `.cursor/templates/`).
   - Optionally warn (non‑blocking) if the closing PR title is not a `feat:`.

4. Discoverability & Index

   - Update `docs/projects/README.md` to include an Active and Completed index.
   - Link each completed project’s `final-summary.md`.

5. Archival Policy

   - For completed, stable projects that are no longer evolving, move to `docs/projects/_archived/<YYYY>/<project>/`.
   - Keep an index entry pointing to the archived location.

6. Metrics & Retrospective

   - Final summary must include a brief Impact section (pre/post metrics or outcomes).
   - A short retrospective (what worked, what to improve, follow‑ups) is required.

## 5. Non‑Functional Requirements

- Documentation‑only; zero external services; fast checks.
- Minimal friction: CI validator runs only on touched projects.
- Portable: templates and rules are repo‑local and agent‑agnostic.

## 6. Architecture/Design

- Impacted rules:
  - `.cursor/rules/project-lifecycle.mdc` (new or updated)
  - Optionally `.cursor/rules/project-lifecycle.caps.mdc` (capabilities summary)
- New scripts:
  - `.cursor/scripts/validate-project-lifecycle.sh`
  - `.cursor/scripts/validate-project-lifecycle.test.sh`

## 7. Data Model & Storage

- Templates: `.cursor/templates/project-lifecycle/*.template.md`.
- Artifacts: `docs/projects/<project>/erd.md`, `tasks.md`, `final-summary.md`, `retrospective.md`.
- Index: `docs/projects/README.md` (Active/Completed lists).

## 8. Acceptance Criteria

- Templates exist in `.cursor/templates/project-lifecycle/` with front matter.
- Rule documents how to use templates and defines completion criteria.
- CI validator flags missing or misplaced artifacts for changed projects only.
- Completed projects appear in the Completed index; archival path is defined and used when appropriate.

## 9. Rollout & Ops

- Phase 0: Add templates and rule; update index (no CI).
- Phase 1: Add CI validator + tests; migrate existing projects to use templates.
- Phase 2: Introduce archival moves for eligible completed projects.
- Rollback: Disable validator; documents remain valid.

## 10. Open Questions

- Should the validator enforce strict mode (fail) vs advisory mode (warn) for PR title semantics?
- Do we auto‑generate the Active/Completed index or keep it manual for simplicity?
