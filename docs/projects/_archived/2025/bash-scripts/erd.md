---
status: completed
---
# Engineering Requirements Document — Bash Script Standards (Lite)


## 1. Introduction/Overview

Define standards for repository shell scripts (`scripts/*.sh`): style, safety, logging, and optional linting exploration.

## 2. Goals/Objectives

- Establish minimal style and safety baselines (set -euo pipefail)
- Require a top comment with description and usage
- Explore linting (ShellCheck) before enforcing
- Declare standards ownership for all repo scripts; the scripts suite adopts these standards

## 3. Functional Requirements

- Header comment: `# Description: ...` and `# Usage: ...`
- Safe defaults: `set -euo pipefail`; quote variables; avoid unguarded rm
- Logging: concise stderr on errors; exit non-zero
- Linting: optional; document how to run if adopted

### 3.1 Ownership and Adoption

- This ERD is the authoritative source for bash style/safety standards (repo-wide).
- `docs/projects/shell-scripts/erd.md` (suite) MUST explicitly adopt these standards and link back here. New/updated suite scripts MUST meet these rules.

## 4. Acceptance Criteria

- Example header snippet and safe patterns included
- Documented linting command (optional)

## 5. Risks/Edge Cases

- Over-enforcement; start advisory and iterate
- Platform differences (macOS default); avoid GNU-only flags

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Run a sample script with error paths; confirm safe behavior and messages

---

Owner: rules-maintainers

Last updated: 2025-10-02
