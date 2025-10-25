---
status: active
owner: rules-maintainers
---

# Engineering Requirements Document — Test Coverage (Lite)

Mode: Lite


Links: `.cursor/rules/testing.mdc` | `.cursor/rules/test-quality-js.mdc` | `docs/projects/test-coverage/tasks.md`

## 1. Introduction/Overview

Define and enforce a pragmatic coverage policy for JS/TS: diff-aware gates or minimum thresholds that complement TDD-First.

## 2. Goals/Objectives

- Choose a default policy: "no new uncovered lines" or a minimal diff threshold (e.g., ≥30% statements)
- Provide local and CI commands to evaluate the policy
- Document exceptions and review protocol

## 3. Functional Requirements

- Local script or command to compute coverage for changed files
- CI wiring sketch (workflow snippet) to enforce the same policy on PRs
- Clear failure messaging and next steps

## 4. Acceptance Criteria

- Policy documented with rationale and examples
- Commands documented for local runs and CI
- Exceptions documented (generated files, barrels) with required justification

## 5. Risks/Edge Cases

- Flaky or slow coverage runs; prefer V8 provider and focused related-tests mode

## 6. References

- See `test-quality-js.mdc` for coverage options and focused-run commands
