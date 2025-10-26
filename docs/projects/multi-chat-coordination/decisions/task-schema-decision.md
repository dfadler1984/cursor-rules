# Decision: Task Schema Design

**Date**: 2025-01-26  
**Status**: Approved for Phase 1

## Context

Need a structured format for coordinator → worker task assignment that includes:

- Task identification and type
- Scoped context (what worker needs to know)
- Acceptance criteria (how to validate completion)
- Dependencies and ordering

## Decision

Use JSON schema with the following structure:

```json
{
  "id": "task-NNN",
  "type": "string (file-summary|test-generation|rule-validation|etc)",
  "description": "string (one-line summary)",
  "context": {
    "targetFiles": ["array of file paths"],
    "outputFiles": ["array of expected output paths"],
    "requirements": ["array of specific requirements"],
    "relevantRules": ["array of .cursor/rules/*.mdc to follow"]
  },
  "acceptance": {
    "criteria": ["array of measurable checks"],
    "validation": "bash command to run for validation"
  },
  "assignedTo": "string|null (worker ID)",
  "status": "pending|assigned|in-progress|completed|failed",
  "createdAt": "ISO 8601 timestamp",
  "completedAt": "ISO 8601 timestamp|null",
  "dependencies": ["array of task IDs that must complete first"]
}
```

## Rationale

**JSON over Markdown**:

- Machine-readable for validation scripts
- Easy to parse in both Node.js and shell scripts
- Structured validation possible

**Field choices**:

- `id`: Unique identifier for tracking and dependencies
- `type`: Enables type-specific worker behavior
- `context.targetFiles`: Worker knows exactly what to read
- `context.relevantRules`: Minimal rule attachment (context efficiency)
- `acceptance.validation`: Coordinator can auto-verify completion
- `dependencies`: Enables task ordering when needed

**Status transitions**:

```
pending → assigned → in-progress → completed
                   ↘ failed (escalate)
```

## Alternatives Considered

### Alternative 1: Markdown Format

**Pros**: Human-readable, familiar
**Cons**: Harder to parse programmatically, no schema validation
**Rejected**: Automation is priority; engineers can read JSON

### Alternative 2: Custom DSL

**Pros**: Optimized for our use case
**Cons**: Additional parser complexity, learning curve
**Rejected**: JSON is good enough for Phase 1

## Open Questions

1. **Task size**: What's the optimal complexity per task?
   - Answer during Phase 1 validation with various task types
2. **Context bloat**: How much context is too much?
   - Workers report efficiency score; adjust if <4

## Validation

Task schema must pass:

```bash
bash .cursor/scripts/task-schema-validate.sh <task-file.json>
```

Exit 0 = valid, exit 1 = invalid (with error message)

## Related

- Example: `examples/simple-summarization-task.json`
- Validation script: `.cursor/scripts/task-schema-validate.sh`
- Worker rule: `.cursor/rules/worker-chat.mdc`

