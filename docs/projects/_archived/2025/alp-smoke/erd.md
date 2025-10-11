---
archived: true
archivedOn: 2025-10-11
source: docs/projects/alp-smoke/erd.md
---

# Engineering Requirements Document — ALP Smoke (Archived)

---

status: skipped
owner: rules-maintainers

---

# Engineering Requirements Document — ALP Smoke

Mode: Lite

## 1. Introduction/Overview

Investigate the utility of the `alp-smoke` flow to validate the Assistant Learning Protocol (ALP) logging pipeline end-to-end without touching real repo logs. The investigation centers on `.cursor/scripts/alp-smoke.sh`, which writes logs under `.test-artifacts/` using the official logger and attempts threshold behavior (aggregation + archival) safely in a sandbox.

## 2. Goals/Objectives

- Provide a concise reference of what the smoke does and why it exists.
- Define acceptance criteria for a successful smoke run.
- Capture safe validation steps and expected evidence.
- Keep runs isolated to `.test-artifacts/` and avoid modifying `assistant-logs/`.

## 3. Functional Requirements

1. Sandbox writes: all artifacts must be placed under `.test-artifacts/alp` via `ALP_LOG_DIR`/`ASSISTANT_LOG_DIR`.
2. Log writes: create 11 log entries using `.cursor/scripts/alp-logger.sh` to exercise filename building, redaction pass-through, and write-with-fallback.
3. Threshold behavior: attempt the threshold script to archive the oldest N logs and emit a summary.
4. Output: print a single summary line in the form `top-level logs=<N> archived=<M> summaries=<S>` followed by the last written log path.

## 4. Non-Functional Requirements

- Safety: no writes outside `.test-artifacts/`.
- Deterministic naming shape: `log-<ISO>-alp-smoke-XX.md`.
- Portability: no external network; plain Bash and local scripts only.

## 5. Acceptance

Given a clean workspace:

- After a smoke run, there is exactly 1 top-level log under `.test-artifacts/alp/` (newest kept), with `>= 10` logs archived under `.test-artifacts/alp/_archived/YYYY/MM/`.
- At least one `summary-*.md` exists at the top level of `.test-artifacts/alp/`.
- The last printed path resolves to an existing file and matches the `log-*.md` naming.

Notes:

- Acceptance mirrors the repository’s threshold policy: once unarchived logs reach the threshold, generate an aggregate summary and archive the oldest logs, leaving the newest at the top level.

## 6. Validation (read-only friendly)

- Inspect `.cursor/scripts/alp-smoke.sh` to confirm:
  - Exports `TEST_ARTIFACTS_DIR`, sets `ALP_LOG_DIR`/`ASSISTANT_LOG_DIR` beneath it.
  - Writes 11 logs via `.cursor/scripts/alp-logger.sh write-with-fallback`.
  - Invokes `.cursor/scripts/alp-threshold.sh` best-effort.
  - Emits a one-line counts summary and then the last path.
- Expected summary shape: `top-level logs=1 archived>=10 summaries>=1` (exact counts may vary if threshold is overridden during tests).

Optional (when executing locally): run the smoke and verify counts without committing `.test-artifacts/`.

## 7. Risks/Limitations

- If the threshold helper is missing or not executable, archival may be skipped; counts will still reflect written logs.
- Extremely fast writes can collide on timestamps in some environments; the script adds a small sleep to avoid this.

## 8. Links

- `.cursor/scripts/alp-smoke.sh`
- `.cursor/scripts/alp-logger.sh`
- `.cursor/scripts/alp-threshold.sh`
