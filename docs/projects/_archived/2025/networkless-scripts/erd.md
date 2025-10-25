---
status: completed
owner: rules-maintainers
lastUpdated: 2025-10-05
---

# Engineering Requirements Document — Networkless Scripts Refactor

Mode: Lite

## 1. Introduction/Overview

Refactor repository **tests** to never perform real network requests. Production scripts may make API calls when necessary (e.g., pr-create.sh), but their tests must use deterministic fixtures and seams, ensuring test isolation from external systems.

**Scope:** Test isolation, not production functionality.

## 2. Goals/Objectives

- Provide a standard, composable network effects boundary for **test code**
- Enforce test isolation: **tests** MUST NOT perform network I/O
- Production scripts CAN make network calls when that's their primary purpose
- Preserve current production UX; use fixtures only in test environments
- Improve test reliability and speed by eliminating live network calls from test suites

## 3. Functional Requirements

1. Test seams: scripts accept seam overrides (e.g., `CURL_CMD=cat`, `JQ_CMD=jq`) to inject fixture data during tests
2. Test fixtures: `.lib-net.sh` provides `net_fixture()` for loading test data; used only in test code
3. Guard rails: tests can set `CURL_BIN=false` to ensure scripts don't bypass seams
4. Production behavior: scripts make real network calls by default when tokens available
5. Test coverage: tests for `pr-create`, `pr-update`, `checks-status`, etc. use fixtures/seams, never live API

## 4. Acceptance Criteria

- Deterministic outputs: test fixtures are stable and asserted in tests
- Tests use seams (`CURL_CMD=cat`, `JQ_CMD=jq`) to inject fixtures; never make live API calls
- Production scripts can access tokens when available; tests use fixtures regardless
- Documentation updated: clearly states test isolation approach and seam usage
- Guard tests (with `CURL_BIN=false`) verify scripts respect seams and don't bypass to live network

## 5. Non-Functional Requirements

- Fast: offline mode should be faster than live operations
- Portable: macOS bash primary; prefer POSIX-sh compatible patterns
- Minimal dependencies: allow `jq` when helpful; degrade gracefully if missing

## 6. Architecture/Design

- Introduce `.cursor/scripts/.lib-net.sh` providing:
  - `net_request` — returns fixtures or prints actionable guidance; never performs HTTP
  - `net_fixture` — helper to load fixture JSON or echo an instruction when fixture missing
- Scripts import shared libs (existing `.lib.sh` + new `.lib-net.sh`) and replace any direct network call sites to use the seam
- Fixtures live near tests under `.cursor/scripts/tests/fixtures/`

## 7. Risks/Edge Cases

- Divergence between fixture outputs and live API responses; mitigate with golden fixtures and periodic refresh guidance
- Hidden network paths (e.g., transitive commands); detect via guard tests that fail when network binaries are invoked
- Token leakage in logs; ensure redaction and avoid printing headers

## 8. Testing & Acceptance

- Unit-style shell tests cover fixture-based behavior for each script
- A guard test verifies that no network client is invoked (override clients with `false` to fail fast)

## 9. Rollout & Ops

- Phase 1: add seam and non-networking library
- Phase 2: migrate `pr-create` and `security-scan`
- Phase 3: migrate remaining scripts and update docs

## 10. Success Metrics

- 0 live network calls during test suite execution and local usage
- Reduced flakiness related to connectivity or credentials
