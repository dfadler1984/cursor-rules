---
status: active
owner: rules-maintainers
lastUpdated: 2025-10-05
---

# Engineering Requirements Document — Networkless Scripts Refactor

[Links: Glossary](../../glossary.md)

Mode: Lite

## 1. Introduction/Overview

Refactor all repository scripts so they never perform real network requests. All behaviors that would otherwise require network access must be implemented via deterministic fakes/fixtures and clear, actionable outputs (e.g., guidance or compare URLs), ensuring tests and local usage are fully isolated from external systems.

## 2. Goals/Objectives

- Provide a standard, composable network effects boundary for scripts
- Enforce a no-network policy: scripts MUST NOT perform network I/O under any circumstances
- Preserve current UX and outputs via fixtures/deterministic prints where applicable
- Improve test reliability and speed by eliminating live network calls

## 3. Functional Requirements

1. Effects seam: centralize any would-be network calls behind a single function (e.g., `net_request`) in a shared script library
2. No network: `net_request` MUST NOT issue real HTTP; it must either return fixture data or emit explicit guidance without performing I/O
3. Guard rails: environment overrides (`CURL_BIN=false`, `HTTP_BIN=false`) are honored and tests fail if any path attempts to invoke them
4. Sensitive data: tokens MUST NOT be required or read; redact any token-like input if provided accidentally
5. Script coverage: apply to `pr-create`, `security-scan`, and any script that could reach the network now or in the future

## 4. Acceptance Criteria

- Deterministic outputs: fixture outputs are stable and asserted in tests
- No direct `curl`/`gh` invocations remain in scripts; all go through the effects seam and never reach the network
- Tokens are never accessed; scripts function without `GITHUB_TOKEN`
- Documentation updated: clearly states no-network policy and how fixtures/guidance are surfaced

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
