---
"cursor-rules": minor
---

Implement slash commands enforcement pattern and document assistant self-testing limits

- feat: Created git-slash-commands.mdc with enforcement protocol for /commit, /pr, /branch, /pr-update
- feat: Updated intent-routing.mdc to route slash commands at highest priority
- feat: Created assistant-self-testing-limits project documenting testing paradox
- fix: Added process-order trigger to self-improve.mdc (Gap #7)
- docs: Updated rules-enforcement-investigation with Gaps #7 and #8

Decision: Slash commands Phase 3 testing deferred - H1 (alwaysApply) already achieving 96% compliance (target >90%). Testing paradox identified: assistants cannot objectively measure own behavior without observer bias.
