---
status: completed
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Platform Capabilities Guidance (Genericization)

Mode: Full

## 1. Introduction/Overview

Generalize the rule currently scoped to Cursor (`.cursor/rules/cursor-platform-capabilities.mdc`) into a vendor-agnostic guidance that applies to any product/platform capabilities we may reference. Preserve the safety and accuracy guarantees (docs as source of truth + citations) while avoiding vendor-specific wording.

## 2. Goals/Objectives

- Define a generic capabilities guidance rule (`.cursor/rules/platform-capabilities.mdc`) usable across products (Cursor, GitHub, Vercel, etc.)
- Keep the “source of truth and citations” pattern; require links to official docs when stating capabilities
- Reduce duplication by making vendor-specific files thin pointers to the generic rule
- Maintain clarity, scannability, and front-matter compliance per `front-matter.mdc`

## 3. User Stories

- As a maintainer, I want one canonical, vendor-agnostic rule so guidance stays consistent.
- As an engineer, I want clear requirements to cite official docs when stating capabilities.
- As a reviewer, I want concise rules that avoid duplicated vendor-specific copies.

## 4. Functional Requirements

1. Create a new generic rule file: `.cursor/rules/platform-capabilities.mdc`.
   - Front matter must follow `front-matter.mdc` (description, lastReviewed, healthScore; optional globs/alwaysApply/overrides as needed)
   - Scope: applies when discussing any product/platform capabilities (limits, models, tool use, context, UI behaviors)
   - Guidance: treat official product documentation as source of truth; include citations; defer when uncertain; reconcile conflicts to docs
2. Deprecate vendor-specific rule `cursor-platform-capabilities.mdc` to a short pointer
   - Keep a small file with a deprecation header and a link to the new generic rule
   - If Cursor-specific notes exist, retain only what’s unique (purely vendor-specific cautions) and cite official Cursor docs
3. Update cross-references across rules/docs to point to the generic rule
   - Replace references to `cursor-platform-capabilities.mdc` where the generic rule suffices
4. Validation & maintenance
   - Run `.cursor/scripts/rules-validate.sh` and fix issues
   - Update `lastReviewed` only on substantive edits per `rule-maintenance.mdc`

## 5. Non-Functional Requirements

- Concise and scannable (≤100 lines where practical), clear sections, no duplication
- Portable and vendor-neutral phrasing; examples should not assume a specific platform
- Easy to maintain; explicit cross-references; valid front matter

## 6. Architecture/Design

- Impacted files:
  - `.cursor/rules/cursor-platform-capabilities.mdc` (deprecate → pointer)
  - `.cursor/rules/platform-capabilities.mdc` (new, generic)
  - `.cursor/rules/capabilities.mdc` or `@capabilities` mentions (if any) — update references
  - Any docs that cite the Cursor-specific rule
- Routing/Attachment: keep attachment minimal; prefer intent routing to attach only when discussing platform capabilities

## 7. Data Model and Storage

- Markdown rules/docs in-repo only; no databases or external services

## 8. Acceptance Criteria

- New `.cursor/rules/platform-capabilities.mdc` exists with valid front matter and generic guidance
- `cursor-platform-capabilities.mdc` replaced with a deprecation header and pointer to the generic rule
- References updated; validation script passes without errors

## 9. Integrations/Dependencies

- None; docs-only changes. Follow existing rule validation scripts and maintenance cadence

## 10. Edge Cases and Constraints

- Product names/brands: keep neutral; examples should use placeholders unless a vendor-specific point is necessary
- Conflicting third-party blog posts vs official docs: prefer official docs; note conflict briefly when relevant

## 11. Testing & Acceptance

- Run `.cursor/scripts/rules-validate.sh` and ensure no front-matter or cross-reference errors
- Spot-check attachments: ensure rule does not attach too broadly; keep `alwaysApply` conservative

## 12. Rollout & Ops

- Step 1: Draft the new generic rule
- Step 2: Deprecate and point the Cursor-specific rule
- Step 3: Update references; validate; announce in README or changelog
- Rollback: keep the old file intact (pointer can be reverted) — docs-only risk

## 13. Success Metrics

- Fewer vendor-specific references needed; consistent citation behavior across products
- Validation passes; reviewers find the guidance clear and reusable

## 14. Open Questions

- Should `alwaysApply` remain `false` to avoid noisy attachments, relying on intent routing?
- Do we want short vendor-specific appendices per product (only when truly unique)?
- Where should living examples of “good citations” reside (rule vs separate examples doc)?
