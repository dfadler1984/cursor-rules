---
---

# Engineering Requirements Document — Productivity & Automation (Lite)

Links: `.cursor/rules/favor-tooling.mdc` | `docs/projects/productivity/tasks.md` | `docs/projects/split-progress/erd.md`

## 1. Introduction/Overview

Streamline repetitive operations with scripts and rule-guided behaviors while preserving safety.

## 2. Goals/Objectives

- Minimal prompting; act when explicit; ask one targeted question on ambiguity
- Automate common steps (git, validation, preflight) with safe defaults
- Keep TDD-first and core guardrails intact

## 3. Functional Requirements

- Provide guidance for when to use scripts vs manual steps
- Integrate with Git usage automation and spec-driven planning
- Prefer reversible, small steps; summarize progress concisely

## 4. Acceptance Criteria

- Example automations listed (branch naming, commit, PR create, preflight)
- Status update guidance (brief, high-signal) documented

## 5. Risks/Edge Cases

- Over-automation leading to hidden behavior; keep outputs explicit

## 6. Rollout Note

- Owner: rules-maintainers
- Comms: Link from README and progress doc

## 7. Testing

- Run script examples and confirm outputs align with rules

## 8. Examples

- Branch naming:
  - `.cursor/scripts/git-branch-name.sh --task checkout-flow --type feat --apply`
- Conventional commit:
  - `.cursor/scripts/git-commit.sh --type feat --scope cart --description "round totals"`
- Preflight check:
  - `.cursor/scripts/preflight.sh`

---

Owner: rules-maintainers

Last updated: 2025-10-02
