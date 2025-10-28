---
logId: { { LOG_ID } }
timestamp: "{{TIMESTAMP}}"
project: "{{PROJECT_SLUG}}"
observer: "{{OBSERVER}}"
reviewed: false
reviewedBy: null
reviewedDate: null
context: "{{WORK_CONTEXT}}"
---

# Monitoring Log {{LOG_ID}} — {{DESCRIPTION}}

**Project**: {{PROJECT_SLUG}}  
**Observer**: {{OBSERVER}}  
**Context**: {{WORK_CONTEXT}}

---

## Observation

{{OBSERVATION_DESCRIPTION}}

<!--
Factual description of what happened. Keep objective and minimal interpretation.
Examples:
- Created `project-archive-ready.sh` (255 lines) without test file
- User said "implement X", guidance rules attached instead of implementation rules
- Pre-send gate did not trigger despite TDD rule loaded
-->

---

## System State

- **Rule(s) loaded**: {{RULES_LOADED}}
- **Gate status**: {{GATE_STATUS}}
- **Pre-send gate**: {{PRE_SEND_GATE_STATUS}}
- **Files involved**: {{FILES_INVOLVED}}

<!--
Capture the state of the system when the observation occurred:
- Which rules were attached/loaded (from intent routing)
- Did any gates trigger? (TDD pre-edit, pre-send, etc.)
- What was the gate response? (blocked, passed, warning)
- List specific files created, edited, or involved
-->

---

## Raw Data

- **Timestamp**: {{EXACT_TIMESTAMP}}
- **Duration**: {{DURATION}}
- **Error messages**: {{ERROR_MESSAGES}}
- **Command executed**: {{COMMAND_EXECUTED}}
- **Exit code**: {{EXIT_CODE}}
- **File size**: {{FILE_SIZE}}
- **Line count**: {{LINE_COUNT}}

<!--
Measurable data points. Include any quantifiable information:
- Exact timestamps (start/end if measurable)
- File sizes, line counts
- Commands that were run (or should have been run)
- Error messages verbatim
- Exit codes, response codes
- Time elapsed between events
-->

---

## Notes

{{ADDITIONAL_NOTES}}

<!--
Additional context that helps understand the observation, but keep interpretation minimal.
This is raw data collection, not analysis.
Examples:
- "This occurred 5 minutes after TDD gate was deployed"
- "Project context was rules-enforcement-investigation (ironic)"
- "User was working on archival script functionality"
- "Similar pattern observed in log-003 and log-007"
-->

---

## Related Logs

- {{RELATED_LOG_1}}
- {{RELATED_LOG_2}}

<!--
Reference other logs that might be related to this observation.
Use log IDs (log-001, log-002, etc.) not finding IDs.
-->

---

**Created**: {{CREATION_TIMESTAMP}}  
**Template version**: 1.0
