---
---

# Engineering Requirements Document — Collaboration Options (Lite)

Links: `.cursor/rules/github-config-only.mdc` | `docs/projects/collaboration-options/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Outline collaboration surfaces (PR templates, optional remote sync like Google Docs/Confluence) while keeping the repo as source of truth.

## 2. Goals/Objectives

- Keep `.github/` boundaries configuration-only
- Use optional, opt-in templates for feature-specific PRs
- Defer remote sync by default; local artifacts remain canonical

## 3. Functional Requirements

- Dedicated PR templates under `.github/PULL_REQUEST_TEMPLATE/` when needed
- Tooling may append per-PR content; generic template stays minimal
- Remote sync gated by explicit enablement and credentials

## 4. Acceptance Criteria

- `.github/` boundaries documented; examples provided
- Guidance for when to use dedicated templates vs docs in `docs/`

## 5. Risks/Edge Cases

- Template sprawl; prefer opt-in templates to avoid clutter

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Verify CI/workflows unaffected; confirm templates load when present

## 8. Examples

- Dedicated PR template placement:
  - `.github/PULL_REQUEST_TEMPLATE/feature-checkout.md`

---

Owner: rules-maintainers

Last updated: 2025-10-02
