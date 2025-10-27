# `/plan` Command Implementation

**Purpose:** Create plan scaffold following spec-driven workflow when user types `/plan <topic>`

**Status:** Implementation specification for assistant behavior

---

## Command Syntax

```
/plan <topic>
```

**Required:**

- `topic` - Plan name (kebab-case recommended)

**Optional:** None for MVP

---

## Detection & Routing

### 1. Detect Command

**Pattern:** Message starts with `/plan` followed by topic

**Examples:**

```
/plan checkout-flow       → Valid
/plan user-authentication → Valid
/plan                     → Error: missing topic
```

### 2. Route to Workflow

**Attach rule:** `spec-driven.mdc`

**Trigger:** `/plan` command detected (highest priority, per spec-driven.mdc line 29)

---

## Execution Flow

### Step 1: Parse & Validate

**Parse topic:**

```typescript
Input: "/plan checkout-flow"
→ topic = "checkout-flow"
```

**Validation:**

- Topic must be present
- Recommend kebab-case (but don't enforce)
- If missing: Show error with usage example

**Error response (missing topic):**

```
Error: /plan requires a topic argument

Usage: /plan <topic>

Examples:
  /plan checkout-flow
  /plan user-authentication
  /plan api-refactor

Tip: Use kebab-case for consistency
```

### Step 2: Determine Plan Path

**Logic:**

1. Check if inside a project context (open files match `docs/projects/*/`)
2. If yes: Use `docs/projects/<project-slug>/plans/<topic>-plan.md`
3. If no: Use `docs/plans/<topic>-plan.md` (global plans directory)

**Examples:**

```
Context: No project open
/plan checkout-flow
→ Path: docs/plans/checkout-flow-plan.md

Context: Working in docs/projects/productivity/
/plan automation-examples
→ Path: docs/projects/productivity/plans/automation-examples-plan.md
```

**Note:** Create parent directories if needed

### Step 3: Request Consent

**Consent prompt format:**

```
Slash command: /plan <topic>

This will create:
  File: docs/plans/<topic>-plan.md
  Template: Spec-driven plan scaffold
    - Steps section
    - Acceptance Bundle section
    - Risks section

The plan will follow the spec-driven workflow format (see spec-driven.mdc).

Proceed?
```

**User must respond:** "Yes" / "Proceed" / "Go ahead"

**If "No" or silence:** Acknowledge and stop

```
Plan creation cancelled. Let me know if you'd like to proceed later.
```

### Step 4: Generate Plan Scaffold

**Template structure:**

```markdown
---
feature: <topic>
phase: planning
created: YYYY-MM-DD
---

# Plan — <Topic Title>


## 1. Overview

[Brief description of what this plan accomplishes]

## 2. Steps

### 2.1 [First Step]

**What:** [Action to take]

**How:** [Approach or method]

**Output:** [Expected result]

**Dependencies:** None

### 2.2 [Second Step]

[Repeat pattern...]

## 3. Acceptance Bundle

### Targets

- Files: [List specific files to change]
- Components: [List specific components/functions]

### Exact Changes

- [Specific change 1]
- [Specific change 2]

### Success Criteria

- [Measurable check 1]
- [Measurable check 2]

### Run Instructions

\`\`\`bash

# Commands to verify success

[command 1]
[command 2]
\`\`\`

### Owner Specs (for JS/TS changes)

- `path/to/file.spec.ts` - [What it tests]

## 4. Risks & Mitigations

**Risk 1:** [Description]

- Mitigation: [How to handle]

**Risk 2:** [Description]

- Mitigation: [How to handle]

## 5. Next Steps

After completing this plan:

1. Generate tasks: `/tasks` or follow task generation guidance
2. Begin implementation with TDD-first workflow
3. Update this plan as you learn
```

**Replace placeholders:**

- `<topic>` → user-provided topic
- `<Topic Title>` → title-case version
- `YYYY-MM-DD` → current date

### Step 5: Output & Next Steps

**Success message:**

```
✓ Plan created: docs/plans/<topic>-plan.md

Next steps:
1. Review and fill in plan sections
2. Generate tasks: /tasks or see generate-tasks-from-erd.mdc
3. Begin implementation with TDD-first workflow

Related:
- See spec-driven.mdc for full workflow
- See tdd-first.mdc for implementation guidelines
```

---

## Error Handling

### Missing Topic

**Input:** `/plan`

**Response:**

```
Error: /plan requires a topic argument

Usage: /plan <topic>

Example: /plan checkout-flow
```

### File Already Exists

**Input:** `/plan existing-topic` (file exists)

**Response:**

```
Warning: Plan already exists at docs/plans/existing-topic-plan.md

Options:
1. Open existing plan: [show file path]
2. Create with different name: /plan existing-topic-v2
3. Overwrite existing (requires explicit consent): "Overwrite existing-topic plan"

Choose an option or cancel.
```

### Invalid Filepath

**Input:** `/plan topic/with/slashes`

**Response:**

```
Error: Topic contains invalid characters: /

Topics should use kebab-case (letters, numbers, hyphens only).

Valid examples:
  /plan checkout-flow
  /plan user-auth-v2
  /plan api-refactor

Try again with a valid topic name.
```

---

## Integration with Other Commands

### After `/plan`, Suggest `/tasks`

**Pattern:** User creates plan, now needs tasks

**Suggestion in output:**

```
✓ Plan created: docs/plans/checkout-flow-plan.md

Next: Generate tasks from this plan?
- Use: /tasks (auto-detect) or
- Use: /tasks --from-plan checkout-flow
```

### Cross-linking with `/specify`

**If spec exists:** Link to it in plan front matter

**If spec doesn't exist:** Suggest creating one

```
Note: No spec found for this plan.

Consider creating a spec first: /specify <topic>
Or proceed with planning and backfill spec later.
```

---

## Testing Strategy

### Unit Tests (Parse & Validate)

```typescript
describe("/plan command", () => {
  it("parses topic from command", () => {
    const result = parsePlanCommand("/plan checkout-flow");
    expect(result.topic).toBe("checkout-flow");
  });

  it("errors on missing topic", () => {
    expect(() => parsePlanCommand("/plan")).toThrow("requires a topic");
  });

  it("determines correct plan path", () => {
    const path = resolvePlanPath("checkout-flow", { projectContext: null });
    expect(path).toBe("docs/plans/checkout-flow-plan.md");
  });

  it("uses project path when in project context", () => {
    const path = resolvePlanPath("automation-examples", {
      projectContext: "productivity",
    });
    expect(path).toBe(
      "docs/projects/productivity/plans/automation-examples-plan.md"
    );
  });
});
```

### Integration Tests (End-to-End)

1. **Detect** `/plan checkout-flow` in message
2. **Attach** `spec-driven.mdc` rule
3. **Request** consent with exact file path
4. **Create** plan file with scaffold
5. **Verify** file exists with correct template
6. **Output** success message with next steps

---

## Implementation Notes

**This is behavioral guidance for the assistant, not code to implement.**

When the assistant sees `/plan <topic>`:

1. Parse topic from command
2. Validate topic is present
3. Determine plan file path (project-aware)
4. Request consent with exact path
5. Create plan file with scaffold template
6. Output success message and suggest next steps

**No repository code needed** - this is assistant behavior specification.

---

**Status:** Draft specification for task 2.0 (Implement `/plan` command)

**Completed:** 2025-10-23

**Next:** Task 3.0 - Implement `/tasks` command
