---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Rule Quality & Consolidation (Lite)

Links: `.cursor/rules/front-matter.mdc` | `.cursor/rules/rule-creation.mdc` | `.cursor/rules/rule-maintenance.mdc` | `.cursor/rules/rule-quality.mdc` | `.cursor/rules/capabilities.mdc`

## 1. Introduction/Overview

Create a focused, maintainable rules system by consolidating overlapping guidance, strengthening cross-linking, enforcing front matter/format standards, and adding automated validation plus routing sanity tests.

## 2. Goals/Objectives

- Streamline to ~8–10 core rules with concise quick refs (caps) per topic
- Single source of truth for global defaults (Consent-first, Status updates, TDD gate, Source-of-truth citations)
- Merge testing family into one `testing.mdc` with subsections; keep `testing.caps.mdc`
- Improve “See also”/dependency linking; remove duplicated paragraphs
- Add automated validation: front matter, links, globs breadth, duplication, caps↔mdc pairing
- Add routing sanity tests for intent triggers and progressive attachment

## 3. Functional Requirements

### 3.1 Organization & Consolidation

- Categories

  - Foundations: `00-assistant-laws`, `assistant-behavior`, `workspace-security`, `security`
  - Workflows: `spec-driven`, `tdd-first`, `refactoring`, `testing`
  - Automation & Routing: `intent-routing`, `favor-tooling`, `direct-answers`, `capabilities`
  - Git & CI: `assistant-git-usage`, `github-api-usage`, `.github-config-only`
  - Rule System: `front-matter`, `rule-creation`, `rule-maintenance`, `rule-quality`

- Consolidations
  - Merge `testing`, `testing-structure`, `testing-naming`, `test-quality` → `testing.mdc` (subsections); retain `testing.caps.mdc`
  - Fold `critical-thinking.caps.mdc` into `direct-answers.mdc` (Root‑cause‑first section)
  - Fold `task-list-process.mdc` into `project-lifecycle.mdc` (or subsection)
  - Fold `capabilities-discovery.mdc` into `capabilities.mdc` (Discovery section)
  - Add `global-defaults.mdc` and replace repeated blocks elsewhere with links

### 3.2 Link Hygiene & Front Matter

- Every rule includes: `description`, `lastReviewed` (YYYY‑MM‑DD), `healthScore` (content/usability/maintenance)
- CSV fields (`globs`, `overrides`): comma-separated, no spaces, no braces
- Standardize “See also” and “Depends on” sections across rules

### 3.3 Validation & Tooling

- Validation script covers:
  - Front matter shape and date format
  - Link existence for internal references
  - Over-broad `globs` (e.g., `**/*`) warnings with suggested narrower scope
  - Duplicate text blocks across rules (e.g., TDD gate) → recommend link to `global-defaults`
  - Caps pairing: ensure each `.caps.mdc` has exactly one `.mdc` counterpart
- Capabilities sync: when rules or scripts change, update `.cursor/rules/capabilities.mdc`

### 3.4 Routing Sanity Tests

- Prompt-based checks:
  - “Add tests …” → attach `testing`, `tdd-first` (minimal set)
  - “Refactor …” → attach `refactoring` (+ `testing` only if touching JS/TS)
  - “Create ERD …” → attach `create-erd`, `guidance-first`
  - Guidance-only queries do not trigger tool/execution rules

## 4. Acceptance Criteria

- Consolidation plan approved and tracked; redundant files merged as specified
- `global-defaults.mdc` exists; other rules link to it instead of duplicating
- `testing.mdc` contains structure/naming/quality subsections; `testing.caps.mdc` ≤ 1 screen
- Validation script flags: missing/invalid front matter, broken links, broad `globs`, duplicate blocks, caps↔mdc mismatches
- Routing tests pass for the defined prompts with minimal attachments
- `capabilities.mdc` updated to reflect scripts and available behaviors

## 5. Risks/Edge Cases

- Over-consolidation could hide important nuances → keep subsections with anchors
- Link rot after merges → run link validation and provide redirects/notes where needed
- Conflicting guidance between legacy and new `global-defaults` → deprecate with pointers

## 6. Rollout Plan

- Phase 1 (Plan): Land `global-defaults.mdc`, author consolidation PR outline, add validation script skeleton
- Phase 2 (Consolidate): Merge testing family; update links and remove duplicates
- Phase 3 (Validate): Run validation + routing sanity tests; fix findings; update `capabilities.mdc`
- Phase 4 (Adopt): Announce in `README.md`; add monthly/quarterly review cadence

## 7. Testing

- Run rules validation; paste exact output for any failure; fix and re-run
- Execute routing sanity prompts; confirm expected attachments only

---

Owner: rules-maintainers

Last updated: 2025-10-03
