---
status: active
owner: rules-maintainers
lastUpdated: 2025-10-14
---

# Engineering Requirements Document — Script Refinement (Optional Polish)

Mode: Lite

Links: [`tasks.md`](./tasks.md)

## 1. Introduction/Overview

Optional Unix Philosophy refinements for remaining script opportunities deferred from [shell-and-script-tooling](../shell-and-script-tooling/erd.md).

**Parent project:** shell-and-script-tooling (infrastructure complete)

**Priority:** P3 (nice-to-have polish, not blocking)

## 2. Goals/Objectives

- Further reduce Unix Philosophy violations (currently 2 remaining opportunities)
- Improve script composability for advanced users
- Complete the Unix Philosophy refinement story

**Non-goal:** Infrastructure work (complete in parent project)

## 3. Scope

**In scope:**

- Extract checks-status.sh into 3 focused scripts (fetch, format, wait)
- Split rules-validate-format.sh into 2 focused scripts (CSV validator, structure validator)

**Out of scope:**

- New infrastructure or standards (D1-D6 complete)
- Scripts already refactored (rules-validate, context-efficiency-gauge)
- New enforcement rules (shell-unix-philosophy.mdc active)

## 4. Functional Requirements

### 4.1 checks-status.sh Extraction

**Current:** 257 lines, 3 responsibilities (fetch, format, wait)

**Target:** 3 focused scripts

- `checks-fetch.sh` (~100 lines) - Fetch GitHub check runs, output JSON
- `checks-format.sh` (~80 lines) - Format check run JSON for display
- `checks-wait.sh` (~80 lines) - Polling wrapper with timeout

**Success criteria:**

- Each script < 150 lines
- Single responsibility per script
- Composable via pipes
- Backward compatibility (update checks-status to orchestrator)

### 4.2 rules-validate-format.sh Split

**Current:** 226 lines, 4 validations (CSV, booleans, deprecated refs, structure)

**Target:** 2 focused scripts

- CSV & boolean validator (~100 lines) - CSV spacing, boolean casing
- Structure validator (~120 lines) - Embedded FM, duplicate headers, deprecated refs

**Success criteria:**

- Each script < 150 lines
- Clear separation of concerns
- Update rules-validate.sh orchestrator to call new scripts

## 5. Acceptance Criteria

- [x] Project scaffold created (ERD, tasks)
- [ ] checks-status extracted (3 scripts + tests)
- [ ] rules-validate-format split (2 scripts + tests)
- [ ] All tests passing (backward compatibility verified)
- [ ] Documentation updated

## 6. Testing & Acceptance

- TDD-first for all new scripts (Red → Green → Refactor)
- Owner tests for each extracted script
- Existing integration tests must pass
- D1-D6 compliance for all new scripts

## 7. Risks/Edge Cases

- Low risk: patterns established in parent project
- Backward compatibility via orchestrators (proven approach)
- May discover these scripts are "good enough" and defer further

## 8. Rollout & Success Metrics

**Estimated effort:** 5-6 hours total

**Success metrics:**

- 2 additional Unix Philosophy violations eliminated
- ~400 additional lines reduced
- All scripts < 200 lines (target achieved)

## 9. Notes

This is **optional enhancement work** deferred from shell-and-script-tooling. Can be paused or abandoned without impact to core infrastructure.

**Parent achievements:**

- Infrastructure 100% complete (D1-D6)
- 3 major orchestrators done (839 lines reduced)
- Enforcement rule active
- All tests passing

---

Owner: rules-maintainers  
Status: Active (P3 priority)  
Last updated: 2025-10-14
