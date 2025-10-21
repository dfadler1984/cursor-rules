# Context Efficiency Gauge

Check context health and efficiency for the current chat:

## Quick Check

Ask the assistant directly:

```text
Show gauge
```

or

```text
How's our context?
```

or

```text
Context efficiency
```

## What It Shows

The gauge evaluates context health on a 1-5 scale based on:

- **Scope**: narrow/focused/moderate/vague/unclear
- **Rules count**: number of rules attached to current chat
- **Clarification loops**: how many times scope/target needed clarification
- **Issues**: user-reported latency, quality problems

## Output Formats

**Gauge Line** (minimal, in status updates):

```text
Context Efficiency Gauge: 4/5 (lean) — narrow scope, minimal rules
```

**Dashboard** (detailed, on request):

```text
┌───────────────────────────────┐
│ CONTEXT EFFICIENCY — DASHBOARD │
├───────────────────────────────┤
│ Gauge: [####-] 4/5 (lean)     │
│ Scope: narrow                 │
│ Rules: 3                      │
│ Loops: 1                      │
│ Issues: none                  │
└───────────────────────────────┘
```

**Decision Flow** (when score ≤ 2):

```text
┌───────────────────────────────────────────────┐
│ SHOULD I START A NEW CHAT?                    │
├───────────────────────────────────────────────┤
│ 1) Is the task scope narrow and concrete?     │
│    - No → New chat (seed exact file + change) │
│    - Yes → 2) ≥2 clarification loops?         │
│             - Yes → New chat                  │
│             - No → 3) Broad searches/many     │
│                    rules attached?            │
│                    - Yes → New chat           │
│                    - No → 4) Latency spikes?  │
│                           - Yes → New chat    │
│                           - No → Stay here    │
└───────────────────────────────────────────────┘
```

## Scoring Scale

| Score | Label   | When to See It                                                                  |
| ----- | ------- | ------------------------------------------------------------------------------- |
| 5     | lean    | Narrow scope, 0-2 rules, 0-1 clarification loops, no reported issues            |
| 4     | ok      | Focused scope, 3-5 rules, 1-2 clarification loops, minor issues                 |
| 3     | ok      | Moderate scope, 6-8 rules, 2-3 clarification loops, some latency/quality notes  |
| 2     | bloated | Vague scope, 9-12 rules, 4+ clarification loops, multiple issues                |
| 1     | bloated | Unclear scope, 13+ rules, 5+ clarification loops, severe latency/quality issues |

## When It Appears Automatically

The gauge line appears in status updates when:

- Score ≤ 3/5, OR
- ≥ 2 efficiency signals are true

## Recommendations

**Score 4-5**: Continue in current chat

**Score 3 + ≥2 signals**: Consider starting new chat or summarizing progress

**Score 1-2**: Strongly recommend new chat with narrow, concrete scope

## Examples

**Check current context**:

```text
Show gauge
```

**Request dashboard**:

```text
Context efficiency dashboard
```

**Ask for recommendation**:

```text
Should I start a new chat?
```

## Future Enhancement

A CLI script `.cursor/scripts/context-efficiency-gauge.sh` is planned to provide programmatic access with format options:

```bash
# Planned (not yet implemented)
bash .cursor/scripts/context-efficiency-gauge.sh --format dashboard
bash .cursor/scripts/context-efficiency-gauge.sh --format line
bash .cursor/scripts/context-efficiency-gauge.sh --format decision
```

## See Also

- [context-efficiency.mdc](../rules/context-efficiency.mdc) - Full gauge specification
- [scope-check.mdc](../rules/scope-check.mdc) - Handling vague requests
- [assistant-behavior.mdc](../rules/assistant-behavior.mdc) - Status update integration
