# Summarize-to-Continue Workflow

**Purpose**: Reclaim context capacity when a chat becomes bloated by creating a concise summary and starting a fresh chat, preserving continuity without accumulated noise.

## When to Summarize

### Triggers (any 1 true → consider summarizing)

- [ ] Context Efficiency Gauge score ≤2/5
- [ ] Token headroom <20% (if estimated)
- [ ] ≥4 clarification loops in current chat
- [ ] User reports: "response seems cut off" or "slow/laggy"
- [ ] Task is only 30% complete but context feels heavy
- [ ] Rules attached ≥10 (without removing any)

### Decision Flow

```text
┌──────────────────────────────────────────────┐
│ SHOULD I SUMMARIZE AND START FRESH?          │
├──────────────────────────────────────────────┤
│ 1) Gauge score ≤2/5?                         │
│    - Yes → Summarize                         │
│    - No → 2) Headroom <20%?                  │
│             - Yes → Summarize                │
│             - No → 3) ≥4 clarification loops?│
│                    - Yes → Summarize         │
│                    - No → Continue here      │
└──────────────────────────────────────────────┘
```

---

## Workflow Steps

### Step 1: Assess Context State

**Ask yourself (or assistant):**

- What is the current gauge score?
- How many clarification loops have occurred?
- What is the estimated token headroom? (if available)
- Is progress stalled or slow?

**If ≥1 trigger is true → proceed to Step 2**

---

### Step 2: Generate Summary (Consent-First)

**Prompt (to assistant):**

> "The context feels bloated. Can you summarize our progress so far in 1-2 paragraphs, listing completed work and next steps?"

**Expected response:**

- **Completed:** List finished tasks (files created/edited, tests passing)
- **In Progress:** Current task state (what's partially done)
- **Next Steps:** 2-3 concrete actions (specific files/changes)
- **Decisions:** Key technical choices made (if any)

**Example summary:**

> **Summary:**
> We implemented user registration (`POST /api/auth/register`) in `routes/auth.ts` with basic email/password handling and duplicate checks. Tests pass in `routes/auth.test.ts`. We started adding bcrypt hashing but didn't complete the migration (plain passwords still stored).
>
> **Next steps:**
>
> 1. Complete bcrypt hashing in `routes/auth.ts` (replace plaintext storage)
> 2. Update tests to verify hashed passwords
> 3. Add email verification flow (separate chat after this works)

---

### Step 3: Start New Chat with Summary

**Close current chat** (or leave it open for reference)

**Open new chat and seed with summary:**

> "Continuing from previous chat:
>
> [Paste summary from Step 2]
>
> I'd like to proceed with: [next concrete task from summary]"

**Why this works:**

- New chat has minimal context (just the summary)
- Summary provides continuity (no loss of progress)
- Specific next task keeps new chat focused

---

### Step 4: Verify Handoff

**In new chat, ask assistant to confirm:**

> "Before we start, can you confirm what was completed and what we're working on next?"

**Expected response:**

- Assistant restates completed work (from summary)
- Assistant confirms next task
- Assistant asks for any missing context (if needed)

**If assistant misunderstands → refine summary and retry**

---

## Summary Template (Copy & Adapt)

```markdown
## Summary of Previous Chat

**Completed:**

- [File/feature 1]: [what was done]
- [File/feature 2]: [what was done]
- Tests: [which tests pass]

**In Progress:**

- [Current task]: [what's partially done, what's left]

**Next Steps (ordered):**

1. [Concrete task 1 with file name]
2. [Concrete task 2 with file name]
3. [Concrete task 3 with file name]

**Decisions Made:**

- [Technical choice 1]: [rationale]
- [Technical choice 2]: [rationale]

**Deferred (not in scope):**

- [Feature/task explicitly excluded]
```

---

## Example: Summarize Mid-Project

### Context (bloated chat)

- **Chat state:** 8 rules attached, 5 clarification loops, gauge score 2/5
- **Progress:** Completed 3 of 7 tasks for a "todos API" feature
- **Problem:** Responses getting slow, lots of back-and-forth

### Step 1: Assess

- Gauge: 2/5 (bloated)
- Loops: 5 (high)
- Progress: 40% complete

**Decision: Summarize**

### Step 2: Generate Summary

**Prompt:**

> "Can you summarize our progress on the todos API and list next steps?"

**Response:**

> **Summary:**
> We built a todos API with `GET /api/todos` (returns all todos) and `POST /api/todos` (creates new todo). Both routes are in `routes/todos.ts` with passing tests in `routes/todos.test.ts`. We added basic validation (title required) but haven't implemented `PATCH` or `DELETE` yet. Data is stored in-memory (no database).
>
> **Next steps:**
>
> 1. Add `PATCH /api/todos/:id` to update `completed` status
> 2. Add `DELETE /api/todos/:id` to remove todos
> 3. Add filtering (`?completed=true|false`) to `GET` endpoint

### Step 3: Start New Chat

**New chat prompt:**

> "Continuing from previous chat:
>
> **Context:**
>
> - Completed: `GET /api/todos` and `POST /api/todos` in `routes/todos.ts` with tests
> - In-memory storage (no DB)
> - Basic validation in place (title required)
>
> **Next task:**
> Add `PATCH /api/todos/:id` to `routes/todos.ts`:
>
> - Body: `{ completed: boolean }`
> - Return: `200 { id, title, completed }`
> - Test: `routes/todos.test.ts` with valid/invalid IDs"

### Step 4: Verify

**Assistant confirms:**

> "Got it. I'll add `PATCH /api/todos/:id` to `routes/todos.ts` with the spec you provided. The existing `GET` and `POST` routes are working, and I'll follow the same patterns for consistency. Proceed?"

**Result:** New chat has lean context (score 5/5), focused on single task

---

## Anti-Patterns (Avoid These)

### Anti-Pattern: Too Much Detail in Summary

**Bad summary (500+ words):**

> "We started by discussing authentication patterns, then explored JWT vs sessions, decided on JWT for statelessness, looked at bcrypt vs argon2, chose bcrypt for simplicity, created `routes/auth.ts`, refactored twice for cleaner code structure, added 15 tests covering edge cases, discussed error handling strategies, implemented custom error classes, added logging with Winston, configured log levels, discussed deployment options, chose Docker, drafted a Dockerfile, added docker-compose, tested locally, fixed port conflicts, updated docs, added comments..."

**Problem:** Summary itself bloats new chat context

**Good summary (50-100 words):**

> "Completed: user registration (`POST /api/auth/register`) in `routes/auth.ts` with bcrypt hashing and tests. Next: add email verification flow (send token endpoint, verify token endpoint). Decisions: using JWT (not sessions), bcrypt for hashing."

---

### Anti-Pattern: No Concrete Next Steps

**Bad summary:**

> "We worked on the API and got some stuff done. Need to finish the rest."

**Problem:** New chat has no clear starting point

**Good summary:**

> "Completed: `GET` and `POST` routes. Next: add `PATCH /api/todos/:id` to `routes/todos.ts` with `{ completed }` body."

---

### Anti-Pattern: Summarizing Too Early

**Premature summarization:**

- Chat has only 2-3 exchanges
- Gauge score is 4-5/5 (lean)
- No clarification loops
- Task is 80% complete

**Result:** Overhead of summarizing + new chat outweighs benefit

**When to hold off:**

- If task is almost done, finish in current chat
- If context is still lean, continue here
- Only summarize when context feels heavy (per triggers)

---

## Integration with Context Efficiency Gauge

Summarizing resets gauge to optimal state:

| Metric                | Before Summarize | After New Chat |
| --------------------- | ---------------- | -------------- |
| Gauge score           | 2/5 (bloated)    | 5/5 (lean)     |
| Rules attached        | 10+              | 2-3            |
| Clarification loops   | 4-5              | 0              |
| Token headroom (est.) | 15% (critical)   | 95% (ok)       |

---

## Quick Reference Card

```text
┌──────────────────────────────────────────────┐
│ SUMMARIZE-TO-CONTINUE QUICK CARD             │
├──────────────────────────────────────────────┤
│ When (any 1 true):                           │
│ - Gauge score ≤2/5                           │
│ - Headroom <20%                              │
│ - ≥4 clarification loops                     │
│ - User reports "cut off" or "slow"           │
│                                              │
│ Steps:                                       │
│ 1. Assess context state (check gauge)       │
│ 2. Generate summary (1-2 paragraphs)        │
│    - Completed, In Progress, Next Steps     │
│ 3. Start new chat with summary               │
│ 4. Verify handoff (confirm understanding)    │
│                                              │
│ Summary = 50-100 words, concrete next steps  │
└──────────────────────────────────────────────┘
```

---

## Related

- See [../../../docs/projects/chat-performance-and-quality-tools/erd.md](../../../docs/projects/chat-performance-and-quality-tools/erd.md) Section 15 for Context Efficiency Gauge specification
- See [incident-playbook.md](./incident-playbook.md) for corrective actions when responses seem truncated
- See [task-splitting-templates.md](./task-splitting-templates.md) for avoiding bloat in the first place
