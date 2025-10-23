# Tasks — Rule Introspection

## Relevant Files

- `docs/projects/rule-introspection/erd.md` — Requirements
- `docs/projects/rule-introspection/tasks.md` — This file
- `.cursor/rules/context-efficiency.mdc` — Context Efficiency Gauge specification
- `.cursor/scripts/context-efficiency-gauge.sh` — Gauge script

## Phase 1: Investigation

- [ ] 1.0 Explore Cursor's rule attachment visibility mechanisms

  - [ ] 1.1 Document what information is available in function results
  - [ ] 1.2 Check if Cursor provides metadata headers or APIs
  - [ ] 1.3 Test if rules are visible in system prompts or context

- [ ] 2.0 Design manual tracking protocol

  - [ ] 2.1 Define where rules appear (function results, always-applied section)
  - [ ] 2.2 Create counting methodology (always-apply + agent-requested + project)
  - [ ] 2.3 Document accuracy expectations and edge cases

- [ ] 3.0 Implement solution

  - [ ] 3.1 If API available: document usage and integrate into gauge invocation
  - [ ] 3.2 If manual only: update context-efficiency.mdc with tracking protocol
  - [ ] 3.3 Add examples showing accurate vs default gauge readings

- [ ] 4.0 Validate accuracy
  - [ ] 4.1 Test gauge with known rule counts (user-verified)
  - [ ] 4.2 Document accuracy margin (±N rules)
  - [ ] 4.3 Update gauge.md with limitation notes

## Notes

- User can see exact rule count in Cursor UI (screenshot shows 18 Always Apply rules)
- Assistant currently uses defaults (rules: 0) instead of actual values
- This impacts Pre-Send Gate enforcement added in assistant-behavior.mdc
