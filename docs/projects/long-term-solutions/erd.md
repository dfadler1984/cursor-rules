---
status: active
owner: repo-maintainers
created: 2025-10-24
lastUpdated: 2025-10-24
---

# Engineering Requirements Document — Long‑term Solutions (Lite)

Mode: Lite

## 1. Introduction/Overview

Replace short‑term manual workarounds with durable, automated, and test‑backed fixes. Prioritize eliminating manual edits to generated artifacts (e.g., manually updating a final summary) by fixing the underlying tools (e.g., ` .cursor/scripts/final-summary-generate.sh`).

### Uncertainty / Assumptions

- Assumption: Prefer local scripts and documentation over external services.
- Assumption: We can add or adjust small validation/CI gates without introducing heavy dependencies.
- Open: Current failure modes of ` .cursor/scripts/final-summary-generate.sh` and required inputs/paths.

## 2. Goals/Objectives

- Establish a “fix the root cause” posture over manual workarounds.
- Identify top recurring manual fixes and replace each with a tested solution.
- Harden ` .cursor/scripts/final-summary-generate.sh` and similar generators with focused tests.
- Add lightweight guardrails (validators/CI) to prevent regression back to manual edits.

## 3. User Stories

- As a maintainer, I can rely on generators to produce correct summaries without manual tweaks.
- As a developer, I can run a single command to regenerate artifacts and verify no drift.
- As a reviewer, I can see automated checks that fail when artifacts diverge from their source.

## 4. Functional Requirements

1. Catalog recurring manual workarounds and rank by impact.
2. For each top item, write a minimal failing test (docs‑level or script‑level) that captures the gap.
3. Implement fixes in the underlying tool with the minimal change to pass the test.
4. Provide a drift check that compares generated output to committed artifacts.
5. Document run instructions and acceptance evidence in project tasks.

## 5. Non‑Functional Requirements

- Keep solutions small, readable, and portable (Markdown + POSIX‑friendly shell).
- Avoid new heavy dependencies; reuse repo rules and simple scripts.
- Deterministic outputs: same inputs produce identical outputs across runs.

## 6. Architecture/Design

- Principle: automation‑first, root‑cause fixes, TDD‑first.
- Effects at boundaries: scripts under `.cursor/scripts/`; tests use a focused shell test harness.
- Drift prevention via a lightweight validator (local script) and optional CI job.
- Documentation under `docs/projects/long-term-solutions/`; cross‑link from the projects index.

## 7. Data Model and Storage

- Artifacts: `erd.md`, `tasks.md` in this folder.
- Inputs: existing docs and generator scripts; no external data stores.
- Optional future doc: `docs/guides/long-term-vs-workaround.md` (decision checklist).

## 8. API/Contracts

- No external API. Provide CLI contracts for generators/validators with `--help`.

## 9. Integrations/Dependencies

- Reuse repository rules: consent‑first, TDD‑first, testing, project lifecycle.
- Optional CI integration using existing GitHub Actions patterns in this repo.

## 10. Edge Cases and Constraints

- Archived docs paths vary by year/slug; detectors must be path‑aware but simple.
- Generators must handle missing optional inputs gracefully with clear errors.
- Avoid non‑determinism (timestamps, ordering) in generated outputs.

## 11. Testing & Acceptance

- ERD and tasks exist; project listed under Active in `docs/projects/README.md`.
- A focused failing test is added first for ` .cursor/scripts/final-summary-generate.sh` capturing a real gap.
- The script is fixed minimally to pass; test turns green.
- A drift check exists and is runnable locally; optional CI gate added.
- Evidence recorded in `tasks.md` with commands and outputs.

## 12. Rollout & Ops

- Phase 1: Inventory and prioritize top 3 manual workarounds.
- Phase 2: TDD fix for final summary generation; add drift validator.
- Phase 3: Migrate current projects; enable optional CI.

## 13. Success Metrics

- Reduction in manual edits to generated artifacts.
- Green drift checks on main; fewer regressions.
- Time saved on releases and summaries.

## 14. Open Questions

- Which artifacts besides final summaries should be generator‑owned?
- What’s the minimal, portable drift‑check contract we want to standardize?
