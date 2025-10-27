---
status: completed
completed: 2025-10-23
owner: rules-maintainers
created: 2025-01-15
mode: lite
---

# Engineering Requirements Document — Core Values Enhancement (Lite)


## 1. Introduction/Overview

**Current state**: The three assistant laws (Truth/Accuracy, Consistency/Transparency, Self-Correction/Accountability) are fully documented in `.cursor/rules/00-assistant-laws.mdc` with behavioral requirements and avoid patterns.

**Gap**: The laws lack concrete scenarios demonstrating practical application. Users benefit from seeing how abstract principles translate to real interactions.

**Scope**: Add 3-5 practical scenarios to `00-assistant-laws.mdc` showing each law in action, without expanding the file beyond usability limits (~150 lines max).

## 2. Goals/Objectives

- Provide concrete examples of low-confidence qualification and reversible steps (First Law)
- Show the 4-step self-correction protocol in action (Third Law)
- Demonstrate how to handle conflicting guidance sources (First Law)
- Illustrate gaming/evasion patterns and proper constraint surfacing (First Law)

## 3. Functional Requirements

Add scenarios to `00-assistant-laws.mdc`:

- **Scenario 1** (First Law): Low confidence → qualification + reversible step
- **Scenario 2** (Third Law): User correction → 4-step acknowledgment
- **Scenario 3** (First Law): Conflicting sources (docs vs code vs tests) → reconciliation
- **Scenario 4** (First Law): Gaming attempt → surface constraint instead of bypass
- **Scenario 5** (Second Law): Guidance change → explicit acknowledgment of what/why

Keep scenarios brief (3-5 lines each, before/after or dialogue format).

## 4. Acceptance Criteria

- 3-5 scenarios added to appropriate law sections in `00-assistant-laws.mdc`
- Each scenario is ≤5 lines and shows concrete dialogue or before/after comparison
- File stays under 150 lines (currently ~50, budget ~100 for scenarios + formatting)
- `lastReviewed` date updated to current date
- Links added from main README to `00-assistant-laws.mdc` (Task 3.0)

## 5. Risks/Edge Cases

- **Bloat risk**: Too many scenarios → file becomes unreadable
  - Mitigation: Limit to 5 scenarios, keep each ≤5 lines
- **Redundancy**: Scenarios duplicate existing "Avoid" bullets
  - Mitigation: Show what TO do, not just what NOT to do
- **False precision**: Scenarios become prescriptive rather than illustrative
  - Mitigation: Frame as examples, not templates

## 6. Rollout Note

- Owner: rules-maintainers
- Target: `.cursor/rules/00-assistant-laws.mdc` (edit in place)
- Comms: Update split-progress tracker; link from main README
- No breaking changes (additive only)

## 7. Testing

Manual validation:

- Read each scenario aloud → does it clarify the law's application?
- Check file length → under 150 lines?
- Verify `lastReviewed` updated and front matter intact
- Test link navigation from README → laws file
