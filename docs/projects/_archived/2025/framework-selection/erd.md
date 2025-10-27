---
status: archived
---
# Engineering Requirements Document — Framework Selection (Spec Kit vs ai-dev-tasks) (Lite)


## 1. Introduction/Overview

Define how to select and configure the planning framework (Spec Kit or ai-dev-tasks), including `/start-project`, per-subproject overrides, and local-first operation.

## 2. Goals/Objectives

- Allow selecting framework via `.cursor/config.json` (framework)
- Support `/start-project` to scaffold subproject config under a configurable base dir
- Permit subproject overrides with nearest `.cursor/config.json`
- Keep manual naming (no auto-suggest)

## 3. Functional Requirements

- Config: `{ "specDriven": { "framework": "spec-kit|ai-dev-tasks", "projectBaseDir": "docs" } }`
- `/start-project`: prompt for name + framework; create `<base>/<name>/.cursor/config.json`
- Flags: `--framework` to override temporarily
- Guidance: installation steps per framework (copy-paste only)

## 4. Acceptance Criteria

- Example flows for big/small projects and monorepo subprojects
- README guidance referenced; no auto-suggest of names
- Spec-driven processes honor nearest config

## 5. Risks/Edge Cases

- Mixed frameworks in monorepos; ensure nearest-config lookup
- Missing configs; prompt instead of guessing

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and split-progress doc

## 7. Testing

- Dry-run `/start-project my-lib` with framework prompts
- Verify nearest config detection in nested folders

---

Owner: rules-maintainers

Last updated: 2025-10-02
