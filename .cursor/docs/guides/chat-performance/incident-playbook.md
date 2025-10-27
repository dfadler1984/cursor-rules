# Incident Playbook — Chat Quality Issues

**Purpose**: Quick corrective actions for common chat failure modes (vague scope, clarification loops, latency, truncation) with step-by-step recovery procedures.

---

## Incident 1: Vague Scope

### Symptoms

- Assistant asks multiple clarifying questions
- Response includes phrases like "could you clarify..." or "what do you mean by..."
- Context Efficiency Gauge shows "vague scope" in rationale
- Multiple rules attached (6+) without clear target

### Root Cause

Request lacks concrete targets (files, functions) or measurable success criteria

### Corrective Actions (Priority Order)

1. **Specify target files/components**

   - Example: "Update `src/parse.ts`" (not "update the parser")
   - List exact file paths, function names if known

2. **Add measurable success criteria**

   - Example: "Return 401 status code" (not "handle errors")
   - State expected output, test assertion, or performance target

3. **Narrow scope to single change**

   - Example: "Add token validation only" (not "improve auth")
   - Defer related changes to follow-up chats

4. **Provide verification command**
   - Example: `curl -X POST http://localhost:3000/api/login`
   - Show how to manually test the change

### Recovery Template

```markdown
**Refined request:**

Target: [exact file path and function name]
Change: [one-sentence imperative: add X, remove Y, change Z]
Success: [test assertion or measurable outcome]
Verify: [command to run or manual test steps]
Defer: [explicitly list out-of-scope items]
```

### Example Recovery

**Before (vague):**

> "Add authentication to the API"

**After (refined):**

> "Add JWT token validation to `api/middleware/auth.ts`:
>
> - Function: `validateToken(req, res, next)`
> - Check `Authorization: Bearer <token>` header, verify signature
> - Return 401 if invalid or missing
> - Test: `api/middleware/auth.test.ts` with valid/invalid/expired tokens
> - Verify: `curl -H "Authorization: Bearer <token>" http://localhost:3000/api/users`
> - Defer: token refresh, OAuth, 2FA"

---

## Incident 2: Clarification Loops

### Symptoms

- ≥3 back-and-forth exchanges without starting implementation
- Assistant repeatedly asks "Do you mean..." or "Should I..."
- Context Efficiency Gauge shows ≥4 clarification loops
- Gauge score ≤3/5

### Root Cause

Ambiguous intent, missing context, or multiple interpretations possible

### Corrective Actions (Priority Order)

1. **Provide explicit intent**

   - State whether you want guidance (exploration) or implementation (action)
   - Example: "I want you to implement X" (not "What do you think about X?")

2. **Attach acceptance bundle**

   - Targets: exact files
   - Change: one-sentence imperative
   - Success: measurable criteria
   - (See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md))

3. **If still unclear → start new chat**
   - Summarize what was discussed (1-2 sentences)
   - Restate request with refined specifics in new chat
   - (See [summarize-workflow.md](./summarize-workflow.md))

### Recovery Template

```markdown
**Clarified request:**

Intent: [implementation | guidance | review]
Target: [exact file paths]
Change: [concrete imperative]
Success: [test or metric]
Context: [1-2 sentences of background, if needed]
```

### Example Recovery

**Before (ambiguous):**

> "How should we handle errors in the parser?"

**After (clarified - guidance):**

> "I'm exploring error handling strategies. Should `parse.ts` throw exceptions or return `Result<T, Error>`? Constraints: must be testable, prefer functional style."

**After (clarified - implementation):**

> "Update `parse.ts` to return `Result<T, Error>` instead of throwing:
>
> - Wrap try-catch → `{ ok: false, error: e }`
> - Success cases → `{ ok: true, value: x }`
> - Test: `parse.test.ts` asserts on Result shape"

---

## Incident 3: Latency / Slow Responses

### Symptoms

- Responses take >10 seconds to start
- User perceives "thinking" or delay
- Context Efficiency Gauge shows high rules count (9+) or many clarifications
- Gauge score ≤2/5

### Root Cause

Bloated context (many rules, broad search, accumulated history)

### Corrective Actions (Priority Order)

1. **Check Context Efficiency Gauge**

   - Ask: "Show gauge" or "Context efficiency?"
   - If score ≤2/5 → proceed to action 2

2. **Reduce rules attached**

   - Remove rules not relevant to current task
   - Start new chat with only essential rules
   - (Most rules are auto-attached; new chat resets)

3. **Narrow search scope**

   - Provide exact file paths (avoid broad semantic search)
   - Use `@filename` to focus assistant attention

4. **Summarize and start fresh**
   - Generate 1-paragraph summary of progress
   - Open new chat with summary + next concrete task
   - (See [summarize-workflow.md](./summarize-workflow.md))

### Recovery Template

```markdown
**Action: Start new chat**

Summary: [1-2 sentences of completed work]
Next: [concrete task with file path]
Rules needed: [list 2-3 essential rules only]
```

### Example Recovery

**Current state:**

- Gauge: 2/5 (bloated)
- Rules: 12 attached
- Clarifications: 5
- Latency: noticeable

**Action:**

> "Starting new chat. Previous: implemented `GET /api/users` in `routes/users.ts` with tests passing. Next: add `POST /api/users` with email/password validation to `routes/users.ts`, test in `routes/users.test.ts`."

---

## Incident 4: Response Truncated / Incomplete

### Symptoms

- Response ends mid-sentence or mid-code block
- Missing expected sections (tests, documentation)
- Assistant says "..." or stops abruptly
- Output feels incomplete

### Root Cause

Token limit reached (completion tokens exceeded) or context too full

### Corrective Actions (Priority Order)

1. **Ask for continuation**

   - Simple: "Continue" or "Please finish the response"
   - Assistant will resume from where it stopped

2. **Check token headroom** (if estimator available)

   - Run: `chat-analyze <transcript>` (when CLI exists)
   - If headroom <10% → proceed to action 3

3. **Summarize and start fresh**

   - Request: "Summarize progress and next steps"
   - Start new chat with summary
   - (See [summarize-workflow.md](./summarize-workflow.md))

4. **Split request into smaller tasks**
   - Instead of "implement feature X with A, B, C"
   - Ask for "implement A only" in new chat
   - (See [task-splitting-templates.md](./task-splitting-templates.md))

### Recovery Template (Continuation)

```markdown
**Request:**
"Continue from where you stopped."
```

### Recovery Template (New Chat)

```markdown
**New chat seed:**

Summary: [completed work, 1 sentence]
Next: [smallest next task, with file path]
Constraint: [if output was too large, add "output code only, no explanations"]
```

### Example Recovery

**Symptom:**

> Response stopped mid-code block while generating `routes/auth.ts`

**Action 1 (try continuation):**

> "Continue"

**If continuation fails or response truncates again:**

> "Start new chat:
>
> Context: implementing `POST /api/auth/register` in `routes/auth.ts`.
> Next: provide only the route handler code (no explanations), I'll add tests separately."

---

## Incident 5: Context Feels Heavy (Proactive)

### Symptoms

- Not yet experiencing issues, but:
  - Gauge score = 3/5 with ≥2 signals true
  - Rules attached ≥8
  - Clarifications ≥3
  - Task is <50% complete

### Root Cause

Accumulating context without hitting hard failure yet

### Corrective Actions (Priority Order)

1. **Check gauge status**

   - Request: "Show gauge" or "Context efficiency?"
   - If score 3/5 + ≥2 signals → consider action 2

2. **Tighten remaining requests**

   - Use prompt tightening patterns for next tasks
   - (See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md))

3. **Split remaining work**

   - Break large task into smaller slices (1-2 files each)
   - Complete current slice, then summarize
   - (See [task-splitting-templates.md](./task-splitting-templates.md))

4. **Preemptive summarization**
   - Before hitting critical state (score ≤2/5)
   - Summarize progress, start fresh with next slice
   - (See [summarize-workflow.md](./summarize-workflow.md))

### Example Action

**Current state:**

- Gauge: 3/5 (ok, but 2 signals true: 8 rules, 3 clarifications)
- Task: 40% complete (3 of 7 endpoints done)

**Action:**

> "Before continuing, let's summarize:
>
> - Completed: `GET /users`, `POST /users`, `GET /users/:id`
> - Next: `PATCH /users/:id` only (defer DELETE and filtering)
> - Starting new chat with refined scope."

---

## Incident 6: Response Quality Degraded

### Symptoms

- Assistant provides generic or vague answers
- Code suggestions lack specificity (placeholder names, missing logic)
- Explanations feel boilerplate or off-topic
- Not directly addressing the request

### Root Cause

Context overload (too many rules/files/history) or ambiguous request

### Corrective Actions (Priority Order)

1. **Verify request clarity**

   - Check if request has concrete targets and success criteria
   - If vague → refine per "Incident 1: Vague Scope"

2. **Reduce context noise**

   - Start new chat with minimal context
   - Provide only essential files/rules

3. **Ask for specific output format**

   - Example: "Provide only the code diff, no explanations"
   - Example: "Show the exact test assertion, not a description"

4. **Provide example of desired output**
   - Example: "Format like this: `function foo() { ... }`"
   - Example: "Use this style: imperative commit messages"

### Recovery Template

```markdown
**Refined request:**

Target: [exact file path]
Change: [concrete action]
Output format: [code only | diff | test assertion | bullet list]
Example: [paste sample of desired format, if helpful]
```

---

## Quick Reference Table

| Incident                  | Symptom                       | First Action                                     | Tool/Guide                    |
| ------------------------- | ----------------------------- | ------------------------------------------------ | ----------------------------- |
| Vague Scope               | Multiple clarifying questions | Specify target files + success criteria          | prompt-tightening-patterns.md |
| Clarification Loops       | ≥3 back-and-forth exchanges   | Provide explicit intent + acceptance bundle      | prompt-tightening-patterns.md |
| Latency / Slow Responses  | >10s delay, high rules count  | Check gauge, reduce rules, start new chat        | summarize-workflow.md         |
| Response Truncated        | Mid-sentence cutoff           | Ask "Continue" or start new chat with summary    | summarize-workflow.md         |
| Context Feels Heavy       | Gauge 3/5 + ≥2 signals        | Tighten prompts, split tasks, preemptive summary | task-splitting-templates.md   |
| Response Quality Degraded | Generic/vague answers         | Refine request, reduce context, specify format   | prompt-tightening-patterns.md |

---

## Diagnostic Flow (Use This First)

```text
┌─────────────────────────────────────────────────┐
│ CHAT ISSUE DIAGNOSTIC                           │
├─────────────────────────────────────────────────┤
│ 1) Check Context Efficiency Gauge               │
│    - Score ≤2/5? → Incident 3 or 4              │
│    - Score 3/5 + ≥2 signals? → Incident 5       │
│    - High clarification loops? → Incident 2     │
│                                                 │
│ 2) Check symptoms                               │
│    - Multiple "could you clarify"? → Incident 1 │
│    - Slow responses? → Incident 3               │
│    - Truncated output? → Incident 4             │
│    - Vague/generic answers? → Incident 6        │
│                                                 │
│ 3) Apply corrective action from playbook       │
│                                                 │
│ 4) Verify recovery                              │
│    - Re-check gauge after action                │
│    - If still issues → escalate to new chat     │
└─────────────────────────────────────────────────┘
```

---

## Related

- See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md) for making requests concrete
- See [task-splitting-templates.md](./task-splitting-templates.md) for breaking large tasks into slices
- See [summarize-workflow.md](./summarize-workflow.md) for reclaiming context capacity
- See [../../../../docs/projects/chat-performance-and-quality-tools/erd.md](../../../../docs/projects/chat-performance-and-quality-tools/erd.md) Section 15 for Context Efficiency Gauge specification
