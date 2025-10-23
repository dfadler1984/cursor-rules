# Prompt Tightening Patterns

**Purpose**: Transform vague, broad requests into concrete, actionable prompts that reduce context bloat and clarification loops.

## Core Principle

**Narrow scope + explicit targets + measurable success criteria = lean context**

---

## Pattern 1: Specify Target Files/Components

### Before (Vague)

> "Add authentication to the app"

**Problems:**

- No target files specified
- Unclear what "authentication" means (login? OAuth? JWT?)
- No boundaries (frontend? backend? both?)
- Triggers broad search and rule attachment

### After (Concrete)

> "Add JWT token validation to `api/middleware/auth.ts`:
>
> - Function: `validateToken(req, res, next)`
> - Check Authorization header, verify signature
> - Return 401 if invalid
> - Test: `api/middleware/auth.test.ts` with valid/invalid/expired tokens"

**Improvements:**

- ✅ Exact file path specified
- ✅ Function name and signature defined
- ✅ Clear behavior described
- ✅ Test criteria stated

---

## Pattern 2: Narrow Scope to Single Concrete Change

### Before (Vague)

> "Improve error handling across the system"

**Problems:**

- System-wide scope (all files)
- "Improve" is qualitative, not measurable
- No specific error types or patterns
- Will trigger many rules and broad searches

### After (Concrete)

> "Update `src/parse.ts` to return `Result<T, Error>` instead of throwing:
>
> - Wrap try-catch blocks → `{ ok: false, error: e }`
> - Success cases → `{ ok: true, value: x }`
> - Update tests to assert on Result shape
> - Leave other files unchanged for now"

**Improvements:**

- ✅ Single file targeted
- ✅ Exact change specified (throw → Result)
- ✅ Pattern defined with examples
- ✅ Boundaries set (other files unchanged)

---

## Pattern 3: Add Success Criteria and Constraints

### Before (Vague)

> "Make the summary command faster"

**Problems:**

- No baseline or target specified
- "Faster" is relative and unmeasurable
- No constraints (memory? compatibility?)
- No way to verify success

### After (Concrete)

> "Reduce `summary.ts` execution time for 10K-line files:
>
> - Current: ~3s, Target: <1s
> - Method: cache parsed entries instead of re-parsing
> - Constraint: maintain API compatibility (no breaking changes)
> - Test: run `time node dist/cli/summary.js example-10k.txt` before/after"

**Improvements:**

- ✅ Measurable baseline and target
- ✅ Specific optimization method
- ✅ Compatibility constraint stated
- ✅ Verification command provided

---

## Pattern 4: Provide Context Without Over-Explaining

### Before (Too Broad)

> "I'm working on a feature to let users export their data. We need to support multiple formats like CSV, JSON, XML, and PDF. It should be fast and handle large datasets. Also, we might need to add filtering and sorting options later. Can you help me design this?"

**Problems:**

- Multiple features mixed (export + formats + performance + future features)
- Design question without specific scope
- Will trigger broad exploration and many clarifications

### After (Focused)

> "Add CSV export to `src/export/csv.ts`:
>
> - Input: `User[]` array
> - Output: CSV string with headers (id, email, name, created_at)
> - Constraint: handle 10K users without blocking
> - Test: `export/csv.test.ts` with sample users array
> - Note: JSON/XML formats are follow-ups (not in this chat)"

**Improvements:**

- ✅ Single format (CSV) targeted first
- ✅ Clear input/output contract
- ✅ Performance constraint quantified
- ✅ Explicitly defers future work

---

## Quick Checklist (Use Before Sending)

Ask yourself:

1. **Target specified?** → Name exact file(s), function(s), or component(s)
2. **Change concrete?** → One-sentence imperative (add X, remove Y, change Z)
3. **Success measurable?** → Test assertion, output sample, or performance number
4. **Scope bounded?** → Explicitly exclude out-of-scope changes
5. **Commands provided?** → How to build, test, or verify the change

If ≥4 are "yes" → send  
If ≤3 are "yes" → tighten further

---

## Common Anti-Patterns (Avoid These)

### Anti-Pattern: "Improve/Enhance/Refactor"

**Vague:** "Refactor the parser module"

**Concrete:** "Extract `parseHeaders` function from `parse.ts` lines 45-67 into `parse-headers.ts` with unit tests"

---

### Anti-Pattern: "Add Feature X"

**Vague:** "Add pagination"

**Concrete:** "Add `?page=N&limit=M` params to `GET /api/users` in `routes/users.ts`; return `{ users, total, page, limit }`"

---

### Anti-Pattern: "Fix Bug"

**Vague:** "The summary command crashes sometimes"

**Concrete:** "Fix crash in `summary.ts` when input file is empty (line 23 `entries[0]` fails); add null check and return empty summary"

---

## Graduated Examples (Vague → Better → Best)

### Example: Authentication Task

**Vague (Score: 1/5):**

> "We need authentication"

**Better (Score: 3/5):**

> "Add login endpoint to the API"

**Best (Score: 5/5):**

> "Add `POST /api/auth/login` to `routes/auth.ts`:
>
> - Body: `{ email, password }`
> - Return: `{ token }` on success, `401` on invalid credentials
> - Test: `routes/auth.test.ts` with valid/invalid cases"

---

### Example: Performance Optimization

**Vague (Score: 1/5):**

> "The app is slow"

**Better (Score: 3/5):**

> "Speed up the dashboard page"

**Best (Score: 5/5):**

> "Reduce `Dashboard.tsx` initial render time from 2s to <500ms:
>
> - Method: memoize `computeStats` with `useMemo`
> - Test: measure with React DevTools Profiler
> - Target: 3 re-renders → 1 re-render on mount"

---

## Integration with Context Efficiency Gauge

Tight prompts directly improve gauge scores:

| Aspect              | Vague Prompt | Tight Prompt |
| ------------------- | ------------ | ------------ |
| Scope concrete?     | ❌ No        | ✅ Yes       |
| Rules attached      | 8-12 (high)  | 2-4 (low)    |
| Clarification loops | 3-5          | 0-1          |
| Gauge score         | 1-2/5        | 4-5/5        |

**Result**: Tight prompts → lean context → faster, higher-quality responses

---

## Quick Reference Card

```text
┌─────────────────────────────────────────────┐
│ PROMPT TIGHTENING QUICK CARD               │
├─────────────────────────────────────────────┤
│ 1. Target: name exact file(s)/function(s)  │
│ 2. Change: one-sentence imperative         │
│ 3. Success: test assertion or metric       │
│ 4. Scope: explicitly exclude out-of-scope  │
│ 5. Commands: how to verify the change      │
└─────────────────────────────────────────────┘
```

---

## Related

- See [task-splitting-templates.md](./task-splitting-templates.md) for breaking large tasks into slices
- See [incident-playbook.md](./incident-playbook.md) for corrective actions when prompts are too vague
- See [../erd.md](../erd.md) Section 15 for Context Efficiency Gauge specification
