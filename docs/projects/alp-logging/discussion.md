# ALP Logging — Discussion & Design Notes

## Context & Goals

- Ensure consistent, high-signal Assistant Learning Protocol (ALP) logging that is lightweight and automatic on triggers.
- Respect the consent exception for ALP while preserving consent gates for all other tools.
- Keep entries concise (≤ 6 core lines), redacted, and routed through the logger to enable aggregation/archival hooks.

## Key Decisions

- Exception precedence: ALP consent exception overrides the general consent gate for log writes only.
- Mandatory end-of-turn "ALP-needed?" check with a must-pass send gate.
- Standard content shape: Timestamp, Event, Owner, What Changed, Next Step, Links, Learning. Optional: Signals.
- Logger-only writes via `.cursor/scripts/alp-logger.sh write-with-fallback`; no ad-hoc file edits.
- Primary destination `assistant-logs/` (configurable), fallback `docs/assistant-learning-logs/` with reason noted.
- Rate-limit duplicates (≥ 2 minutes) and prefer combining adjacent small triggers.

## Triggers (Minimum Set)

- Task Completed/Cancelled
- Routing Corrected
- Misunderstanding Resolved
- TDD Red / TDD Green
- Rule Added / Rule Updated
- Safety Near-Miss
- Improvement Opportunity

## Status Update Coupling

- Pre-tool micro-update: announce tool category switch and pending ALP check.
- Post-tool micro-update: confirm ALP outcome (event type or none+reason) and include path if logged.

## Usage Examples

- Minimal log (pipe body):

```
printf '%s\n' \
  "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  'Event: Task Completed' \
  'Owner: alp-logging' \
  'What Changed: Created ERD and tasks for ALP logging.' \
  'Next Step: Update assistant-behavior and assistant-learning rules.' \
  'Links: docs/projects/alp-logging/erd.md, docs/projects/alp-logging/tasks.md' \
  'Learning: Add ALP-needed? check to the send gate.' \
| .cursor/scripts/alp-logger.sh write-with-fallback assistant-logs 'alp-logging'
```

- Heredoc (safer multiline):

```
.cursor/scripts/alp-logger.sh write-with-fallback assistant-logs 'alp-logging' <<'BODY'
Timestamp: 2025-10-10T00:00:00Z
Event: Routing Corrected
Owner: alp-logging
What Changed: Clarified ALP exception precedence over consent gate.
Next Step: Update assistant-behavior.mdc with explicit precedence note.
Links: .cursor/rules/assistant-behavior.mdc, .cursor/rules/assistant-learning.mdc
Learning: Treat ALP writes as narrow, local-only exception; log immediately on trigger.
BODY
```

## Common Pitfalls & How We Address Them

- Confusing ALP with general tools: explicitly state exception precedence and log first on triggers.
- Skipping ALP at send time: enforce the end-of-turn check; block send if missing when required.
- Noisy duplicates: apply 2-minute duplicate guard and combine adjacent signals.
- Overlong entries: keep to ≤ 6 lines in main body; use "Signals" for extras.
- Secrets: always rely on logger redaction; never paste tokens/headers.

## Next Steps

- Update rules (`assistant-behavior.mdc`, `assistant-learning.mdc`) per this discussion.
- Add a cheat sheet in `docs/assistant-learning-logs/README.md`.
- Include usage examples in `README.md`.

## 100 Hows — Making ALP Logging Consistent

1. Clarify exception precedence in `assistant-behavior.mdc` (ALP overrides consent gate for logs).
2. Place precedence text immediately before the consent gate section.
3. Add “ALP-needed?” as a mandatory end-of-turn send-gate item.
4. Require status lines to include `ALP: <event|none>` whenever tools ran.
5. If `ALP-needed?` = yes and not logged, block send.
6. Log immediately on trigger; do not defer within the turn.
7. Keep ALP writes local-only and narrow in scope.
8. Enumerate minimal triggers in `assistant-learning.mdc`.
9. Require “Owner” as a stable slug (feature/rule).
10. Require “Learning” and “Next Step” to be one line each.
11. Enforce concise bodies (≤ 6 lines) + optional Signals.
12. Rate-limit duplicates within 2 minutes.
13. Combine adjacent small triggers into one entry.
14. Use `.cursor/scripts/alp-logger.sh write-with-fallback` exclusively.
15. Document heredoc usage for multiline bodies.
16. Document primary vs fallback destination and when to use fallback.
17. Require stating fallback reason in the log body when used.
18. Prohibit direct file writes to `assistant-logs/`.
19. Add a cheat sheet with example commands in `docs/assistant-learning-logs/README.md`.
20. Add examples to `README.md` under a Logging section.
21. In status, announce tool-category switches and pending ALP check.
22. After tools, state ALP outcome and include log path.
23. On todo transitions, log “Task Completed/Cancelled”.
24. On routing fixes, log “Routing Corrected” with trigger phrase.
25. On misunderstandings, log “Misunderstanding Resolved”.
26. On TDD Red, log failing behavior summary.
27. On TDD Green, log passing signal and selector.
28. On rule edits, log “Rule Added/Updated” with affected files.
29. On safety near-miss, log with the avoided risk.
30. Default uncertain cases to “Improvement Opportunity”.
31. Require a “Links” line pointing to relevant paths.
32. For multi-owner changes, pick primary; list others under Links.
33. Encourage ISO timestamps standardized by logger.
34. Redact secrets via logger’s redaction step.
35. Ban tokens/headers in bodies; never echo secrets.
36. Print resulting log path after writes in status.
37. If logger fails, print command and exit code in status.
38. On failure, attempt fallback destination.
39. If both fail, include a one-line manual note in status.
40. Retry once for transient FS errors.
41. Add weekly aggregation step (already scripted); document as must.
42. Archive threshold behavior described and linked.
43. Summarize top learnings in aggregate.
44. Tag repeated patterns as `[rule-candidate]`.
45. Track trigger coverage ratio in aggregate.
46. Encourage at least one ALP per implemented change batch.
47. Provide “Top 3” learnings guidance.
48. Require consistent capitalization of Event values.
49. Add an Event glossary at the top of `assistant-learning.mdc`.
50. Add status micro-template including an ALP field.
51. Add a routing correction example with Signals.
52. Add a task completion example with Links.
53. Add TDD Red and Green example snippets.
54. Add a safety near-miss example.
55. Document duplicate-guard rationale and examples.
56. Document combining signals rationale.
57. Document when to break logs apart (different owners/features).
58. Encourage an “Owner Map” for stable slugs.
59. Link ALP logs to final summaries when wrapping projects.
60. Require referencing the latest 3 logs in project final summaries.
61. Add a troubleshooting section (permissions, missing bash, etc.).
62. Document `logDir` override via `.cursor/config.json`.
63. Note cross-platform path considerations.
64. For Windows, recommend WSL or Git Bash when needed.
65. Encourage short, actionable “Learning” lines.
66. Encourage “Next Step” to be verb-led and near-term.
67. Disallow narrative “What Changed”; keep it a single sentence.
68. Prefer repo-relative links over external URLs.
69. If external links are needed, use descriptive anchors.
70. Mask sensitive parts of paths if necessary.
71. Add FAQ: “When in doubt, log Improvement Opportunity.”
72. Add FAQ: “What if I triggered two events?”
73. Add FAQ: “How do I redact sensitive values?”
74. Add FAQ: “Why logger-only writes?”
75. Add FAQ: “What if my log is too long?”
76. Add FAQ: “What if I already logged this?”
77. Add rule text: ALP logs are consent-exempt by default; do not prompt.
78. Add rule text: State ALP action in status updates.
79. Add rule text: For guidance-only turns with triggers, still log.
80. Add rule text: Skip only when no trigger; state reason.
81. Promote small, frequent logs over large, infrequent ones.
82. Encourage batching signals within one log to reduce noise.
83. Encourage adding “Operation/Dependency Impact” when relevant.
84. Capture “Owner” consistently (feature/rule slug).
85. Link “Owner” back to ERD or rule files when possible.
86. For ERD-driven changes, link the ERD and tasks.
87. For rule changes, link the exact `.mdc` files.
88. For script changes, link the script path.
89. For CI changes, link the workflow file.
90. For docs-only changes, link the doc path.
91. Encourage per-turn ALP sweep before send.
92. Encourage a quick self-check “Did a trigger fire?”
93. Encourage “smallest corrective next step” as Next Step.
94. Encourage noting duplicate suppression decisions.
95. Encourage noting fallback reasons explicitly.
96. Encourage a stable short slug in filenames.
97. Encourage log names to reflect the event (e.g., `task-completed`).
98. Encourage consistent tense in “What Changed”.
99. Encourage mirroring this list back into the rule files.
100. Close the loop: after updating rules, emit a “Rule Updated” ALP with links.
