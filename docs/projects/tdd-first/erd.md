---
---

# Engineering Requirements Document — TDD‑First (Lite)

Links: `.cursor/rules/tdd-first.mdc` | `docs/projects/tdd-first/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Enforce Red → Green → Refactor with colocated owner specs and effects seams.

## 2. Goals/Objectives

- JS/TS hard gate: list owner spec paths before edits
- Effects seams for IO/env/time/random; test pure resolvers first
- Coverage>0 guard and owner coupling alignment

## 3. Functional Requirements

- Red: add/update failing owner spec colocated with source
- Green: minimal changes to pass; Refactor while keeping green
- Include owner spec paths in acceptance bundles for code tasks

## 4. Acceptance Criteria

- Hard gate rules documented and examples provided
- Effects seam guidance included
- Integration points with test-quality rules noted

## 5. Risks/Edge Cases

- Framework-specific testing; allow explicit overrides while preserving owner mapping

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Focused Jest run examples and config notes

## 9. Lessons Learned (2025-10-04)

- Incident: While adding `.cursor/scripts/project-lifecycle-validate.sh`, I initially wrote a test that only checked exit codes and did not assert observable behavior (OK/FAIL lines, reasons, or flag handling). I also claimed behavior (“validated outputs”) that the test did not actually verify.
- Impact: The test could pass even if the validator script regressed (e.g., empty output or missing checks), violating the spirit of Red → Green and our Laws (Truth/Accuracy).
- Correction: Strengthened the test to assert concrete outputs and failure reasons and to exercise the `--projects-dir` flag. Re-ran focused tests to green.
- Policy reinforcement: Tests must fail meaningfully when the SUT behavior is incorrect; avoid assertion gaps that mask regressions. When stating what a test verifies, ensure assertions explicitly cover those claims.

## 8. Examples

- Owner spec path and failing assertion:

  - Owner: `src/parse.spec.ts`
  - Failing: `it('rejects bracketed globs', () => { /* ... */ })`

- Effects seam (time/env injection):

```ts
export function formatNow(now: () => Date): string {
  const d = now();
  return `${d.getUTCFullYear()}-${d.getUTCMonth() + 1}`;
}
```

Test injects a fixed clock:

```ts
it("formats year-month in UTC", () => {
  const fixed = () => new Date("2025-10-02T00:00:00Z");
  expect(formatNow(fixed)).toBe("2025-10");
});
```

---

Owner: rules-maintainers

Last updated: 2025-10-02
