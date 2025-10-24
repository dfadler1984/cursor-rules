---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Document Templates Discovery (Lite)

Links: `docs/projects/readme-structure/erd.md` | `docs/projects/project-organization/erd.md` | `.cursor/rules/spec-driven.mdc`

## 1. Introduction/Overview

Identify documents we regularly create (ERDs, specs, plans, tasks, ADRs, READMEs, PR descriptions, issue templates, changelogs, release notes) that would benefit from standardized templates, and propose minimal, high‑signal templates.

## 2. Goals/Objectives

- Inventory recurring document types across this repo
- Decide which merit templates vs guidance-only
- Produce minimal, skimmable templates focused on acceptance and verification
- Avoid template bloat; prefer links to rules where possible

## 3. Approach

1. Inventory: scan `docs/`, `docs/projects/**`, `.github/`, and root docs
2. Categorize: project artifacts vs repository-wide docs vs platform configs
3. Propose: minimal templates with front matter and acceptance sections
4. Validate: dry-run with 1–2 existing projects; get feedback

## 4. Candidate Documents

- Project ERD (already standardized; confirm lite/full modes)
- Project tasks (owner, status, acceptance)
- ADRs (context, decision, consequences)
- README (root and per-project index)
- PR descriptions (script-driven body guidance)
- Changelog entries (Changesets is source of truth; guidance only)
- Release notes (derive from changelog; guidance only)

## 5. Acceptance Criteria

- Inventory doc produced with examples and frequency notes
- Decision matrix indicating template vs guidance for each type
- Draft templates for selected types committed under `docs/patterns/`
- One existing project updated to use the templates (before/after comparison)

## 6. Risks/Edge Cases

- Over-templating reduces readability → keep templates short with links
- Divergence between templates and rules → link to rules; avoid duplication

## 7. Rollout Plan

- Phase 1: Inventory + matrix
- Phase 2: Draft minimal templates
- Phase 3: Pilot on one project; refine
- Phase 4: Announce and add lightweight validator checks

---

Owner: rules-maintainers

Last updated: 2025-10-11
