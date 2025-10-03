---
---

# Engineering Requirements Document — Portability and Paths (Lite)

Links: `.cursor/rules/portability.mdc` | `docs/projects/portability/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Define a clear, portable configuration model for artifact directories and logs. Ensure repos can override defaults without code changes, avoid absolute paths in configuration, and support environment-variable expansion.

## 2. Goals/Objectives

- Document configuration keys for artifacts and logs (specsDir, plansDir, tasksDir, logDir)
- Enforce relative-path policy; reject absolute paths in configuration
- Support `${ENV_VAR}` expansion with safe fallbacks
- Keep behavior identical across repositories with different directory layouts

## 3. Functional Requirements

- Configuration keys are read from `.cursor/config.json` under `artifacts.*Dir` and `logDir`
- All configured paths are repository-relative; absolute paths are rejected with actionable guidance
- Environment variables in paths expand when present; otherwise defaults apply and a warning is surfaced
- Missing directories do not hard-fail read operations; writers create or print next steps

## 4. Acceptance Criteria

- The ERD documents keys, defaults, and path policies with examples
- Example config shows defaults and an override variant with `${ENV_VAR}` usage
- Guidance text for absolute-path rejection is specified
- Smoke notes: changing `artifacts.*Dir` updates write locations for new artifacts; overriding `logDir` moves learning logs

## 4.1 Examples

Example defaults (non-binding):

```json
{
  "logDir": "./assistant-logs/",
  "artifacts": {
    "specsDir": "docs/specs",
    "plansDir": "docs/plans",
    "tasksDir": "tasks"
  }
}
```

Example with `${ENV_VAR}` overrides:

```json
{
  "logDir": "${LOG_DIR:-./assistant-logs/}",
  "artifacts": {
    "specsDir": "${SPECS_DIR:-docs/specs}",
    "plansDir": "${PLANS_DIR:-docs/plans}",
    "tasksDir": "${TASKS_DIR:-tasks}"
  }
}
```

Absolute-path rejection message:

"Absolute path rejected in config key '<key>'. Use a repo-relative path like 'docs/specs/'."

## 5. Risks/Edge Cases

- Mixed OS paths (Windows vs POSIX) — prefer POSIX-style paths in docs
- Missing environment variables — expand to defaults and warn
- Non-writable directories — learning logs fall back to `docs/assistant-learning-logs/`

## 6. Rollout Note

- Owner: rules-maintainers
- Target: next minor docs update
- Comms: Link from README and `docs/projects/split-progress/erd.md`

## 7. Testing

- Manual: verify examples against a sample repo with overridden `artifacts.*Dir`
- Optional: validator/checks in shell script align with policy
