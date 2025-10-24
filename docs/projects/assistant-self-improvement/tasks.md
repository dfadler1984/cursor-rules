---
title: Assistant Self-Improvement — Tasks
owner: repo-maintainers
status: in-progress
start: 2025-10-11
last: 2025-10-11
tags: [assistant, self-improvement, redesign, deprecation]
---

## Tasks

### Phase 1: Legacy Cleanup (Complete)

1. ✅ Create project scaffold with ERD and tasks (this file)
2. ✅ Move legacy Assistant Learning rule files into `legacy/rules/`
3. ✅ Move ALP scripts and tests into `legacy/scripts/`
4. ✅ Remove references to Assistant Learning and ALP outside this project

### Phase 2: Approach Implementation (In Progress)

**Current approach: Rule-Adoption**

See [`approaches/rule-adoption/tasks.md`](approaches/rule-adoption/tasks.md) for detailed implementation tasks.

**Summary of approach tasks**:

- [ ] Phase 1: Rule Integration (4 phases) - Modify assistant-behavior, rule-maintenance, rule-creation, rule-quality, create self-improve.mdc
- [ ] Phase 2: Behavior Validation (5 validation tests)
- [ ] Phase 3: Pivot Project Setup (create contingency plan documentation)
- [ ] Phase 4: Monitoring & Iteration (track acceptance rate, overhead, feedback)

**Contingency**: If pivot triggers fire (latency >200ms, false positives >50%, context bloat >10%, user distraction), activate [`approaches/pivot-alternatives/erd.md`](approaches/pivot-alternatives/erd.md)

### Overall Project Completion Criteria

- [ ] ✅ One implementation approach validated (rule-adoption OR pivot alternative)
- [ ] ✅ Pattern observation mechanism working
- [ ] ✅ Proposal surfacing mechanism working
- [ ] ✅ Consent-first behavior preserved
- [ ] ✅ Monitoring period complete (10+ tasks with >50% acceptance rate)

## Notes

- After migration, legacy assets are archived and not referenced outside this project.
- This umbrella project is complete when ONE nested approach (rule-adoption or pivot alternative) is fully implemented and validated.
