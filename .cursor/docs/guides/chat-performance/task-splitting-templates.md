# Task Splitting Templates

**Purpose**: Break large, complex tasks into minimal, concrete slices that fit within lean chat context and deliver incremental value.

## Core Principle

**One end-to-end slice + verified outcome → next slice**

Prefer: thin vertical slices (feature → test → verify)  
Avoid: thick horizontal layers (all models → all routes → all tests)

---

## When to Split

### Signals (≥2 true → split)

- [ ] Task description >3 sentences
- [ ] Multiple files/components affected (>5 files)
- [ ] Crosses architectural boundaries (frontend + backend + db)
- [ ] Unclear how to verify success in one step
- [ ] Estimated effort >1 hour
- [ ] "And also..." appears in the request

### Decision Tree

```text
┌────────────────────────────────────────────┐
│ SHOULD I SPLIT THIS TASK?                  │
├────────────────────────────────────────────┤
│ 1) Can I verify success in <10 minutes?    │
│    - No → Split                            │
│    - Yes → 2) Does it touch >5 files?      │
│             - Yes → Split                  │
│             - No → 3) Multiple features?   │
│                    - Yes → Split           │
│                    - No → Ship as-is       │
└────────────────────────────────────────────┘
```

---

## Template 1: Minimal First Slice + Follow-Ups

### Pattern

1. **Slice 0 (minimal)**: Smallest end-to-end feature that delivers value
2. **Follow-ups (ordered)**: List 2-3 incremental enhancements
3. **Defer (explicit)**: Note what's intentionally excluded

### Example: User Registration Feature

**Before (monolithic):**

> "Implement user registration with email/password, email verification, password strength validation, rate limiting, and admin approval workflow"

**After (sliced):**

**Slice 0 (this chat):**

> "Add `POST /api/auth/register` to `routes/auth.ts`:
>
> - Body: `{ email, password }`
> - Return: `201 { userId }` on success, `400` on duplicate email
> - Store: plain password (bcrypt in follow-up)
> - Test: `routes/auth.test.ts` with valid/duplicate cases
> - Verify: `curl -X POST http://localhost:3000/api/auth/register -d '{"email":"test@example.com","password":"pass123"}'`"

**Follow-ups (next chats):**

1. Add bcrypt hashing before storing password
2. Add email verification flow (send token, verify endpoint)
3. Add password strength validation (min length, complexity)
4. Add rate limiting (5 registrations/hour per IP)
5. Add admin approval workflow

**Deferred (future):**

- OAuth (Google, GitHub)
- 2FA
- Magic links

---

## Template 2: End-to-End Thin Slice vs Layer-by-Layer

### Anti-Pattern: Layer-by-Layer (Thick Horizontal)

```
❌ Chat 1: Define all data models
❌ Chat 2: Create all API routes (no tests)
❌ Chat 3: Add all frontend forms
❌ Chat 4: Write all tests at the end
```

**Problems:**

- No verifiable outcome until Chat 4
- High risk of rework (models change → routes change → forms change)
- Large context accumulation across chats

### Preferred: Thin Vertical Slice (End-to-End)

```
✅ Chat 1: User model + register route + test → verify
✅ Chat 2: Login route + session handling + test → verify
✅ Chat 3: Profile route + update logic + test → verify
```

**Benefits:**

- Each chat delivers working feature
- Early feedback reduces rework risk
- Small context per chat

---

## Template 3: Backend-First, Frontend-Later

### Pattern (for full-stack features)

**Phase 1 (backend only):**

> "Add `GET /api/users/:id` to `routes/users.ts`:
>
> - Return: `{ id, email, name, created_at }`
> - Test: `routes/users.test.ts` with valid/invalid IDs
> - Verify: `curl http://localhost:3000/api/users/1`"

**Phase 2 (frontend, separate chat):**

> "Add user profile page at `/profile/:id` in `pages/Profile.tsx`:
>
> - Fetch: `GET /api/users/:id` (existing endpoint)
> - Display: user email, name, created date
> - Test: `pages/Profile.test.tsx` with mock fetch
> - Verify: visit `http://localhost:3001/profile/1`"

**Why separate:**

- Backend endpoint can be tested independently
- Frontend work doesn't bloat backend chat context
- Backend changes (if needed) don't invalidate frontend work

---

## Template 4: Read-Only First, Write-Later

### Pattern (for CRUD features)

**Phase 1 (read-only):**

> "Add `GET /api/todos` to `routes/todos.ts`:
>
> - Return: `[{ id, title, completed }]`
> - Test: `routes/todos.test.ts` with sample data
> - Verify: `curl http://localhost:3000/api/todos`"

**Phase 2 (create, separate chat):**

> "Add `POST /api/todos` to `routes/todos.ts`:
>
> - Body: `{ title }`
> - Return: `201 { id, title, completed: false }`
> - Test: `routes/todos.test.ts` with valid/invalid titles"

**Phase 3 (update/delete, separate chat):**

> "Add `PATCH /api/todos/:id` and `DELETE /api/todos/:id`..."

**Why separate:**

- Read path is simpler (no validation, side effects)
- Write paths share validation logic (DRY after read works)
- Reduces complexity per chat

---

## Template 5: Happy Path First, Edge Cases Later

### Pattern

**Phase 1 (happy path only):**

> "Add `parse` function to `src/parse.ts`:
>
> - Input: valid HAR JSON string
> - Output: `{ entries: [...] }`
> - Test: `parse.test.ts` with valid HAR sample
> - Assume: input is always valid JSON with entries array"

**Phase 2 (edge cases, separate chat):**

> "Add error handling to `parse.ts`:
>
> - Invalid JSON → return `{ ok: false, error: 'Invalid JSON' }`
> - Missing `entries` → return `{ ok: false, error: 'Missing entries' }`
> - Test: `parse.test.ts` with malformed inputs"

**Why separate:**

- Happy path validates core logic first
- Error handling patterns emerge from usage
- Avoids over-engineering before need is clear

---

## Quick Decision Matrix

| Task Complexity | Files Affected | Boundaries Crossed | Recommended Split Strategy       |
| --------------- | -------------- | ------------------ | -------------------------------- |
| Low             | 1-2            | None               | No split (single chat)           |
| Medium          | 3-5            | 1 (e.g., API)      | Thin slice (backend → frontend)  |
| High            | 6-10           | 2+ (API + DB + UI) | Layer per chat (data → API → UI) |
| Very High       | 10+            | 3+                 | Feature per chat (list → detail) |

---

## Splitting Anti-Patterns (Avoid These)

### Anti-Pattern: "Do Everything"

**Before:**

> "Implement complete user management system with auth, profiles, admin panel, and analytics"

**Fix (slice 0):**

> "Add `POST /api/users` to create a user with email/password, return `{ userId }`, test with curl"

---

### Anti-Pattern: "Add All Variants"

**Before:**

> "Add sorting to the users list (by name, email, created date, ascending/descending)"

**Fix (slice 0):**

> "Add `?sort=name` param to `GET /api/users` (ascending only), test with `?sort=name`"

---

### Anti-Pattern: "Future-Proof Now"

**Before:**

> "Design extensible plugin system for future integrations (Slack, email, webhooks, SMS)"

**Fix (slice 0):**

> "Add `sendEmail` function to `src/notify.ts` with Nodemailer, send plain text, test with console transport"

---

## Graduated Example: Todos API

### Vague (No Split)

> "Build a todos API with CRUD, filtering, sorting, pagination, and user authentication"

**Problem:** 6+ features, 10+ files, unclear where to start

---

### Better (One Split)

**Chat 1 (backend):**

> "Create todos API with GET/POST/PATCH/DELETE at `/api/todos`"

**Chat 2 (features):**

> "Add filtering, sorting, pagination to GET endpoint"

**Problem:** Still too broad per chat (4 operations in Chat 1)

---

### Best (Thin Slices)

**Chat 1 (read-only):**

> "Add `GET /api/todos` returning `[{ id, title, completed }]`, test with curl"

**Chat 2 (create):**

> "Add `POST /api/todos` with `{ title }` body, return `201 { id, title, completed: false }`"

**Chat 3 (update):**

> "Add `PATCH /api/todos/:id` with `{ completed }` body, return `200 { id, title, completed }`"

**Chat 4 (delete):**

> "Add `DELETE /api/todos/:id`, return `204`"

**Chat 5 (filtering):**

> "Add `?completed=true|false` param to `GET /api/todos`"

**Chat 6 (sorting):**

> "Add `?sort=title` param to `GET /api/todos` (ascending)"

---

## Integration with Context Efficiency Gauge

Splitting tasks improves gauge scores:

| Task Type      | Files | Context Score | Result                        |
| -------------- | ----- | ------------- | ----------------------------- |
| Monolithic     | 10+   | 1-2/5         | Bloated context, many rules   |
| Layer-by-layer | 5-7   | 2-3/5         | Moderate context, some rework |
| Thin slice     | 1-3   | 4-5/5         | Lean context, fast feedback   |

---

## Quick Reference Card

```text
┌──────────────────────────────────────────────┐
│ TASK SPLITTING QUICK CARD                    │
├──────────────────────────────────────────────┤
│ 1. Can I verify success in <10 min? (No → Split) │
│ 2. >5 files affected? (Yes → Split)         │
│ 3. Multiple features? (Yes → Split)         │
│                                              │
│ Prefer: thin vertical slices (E2E per chat) │
│ Avoid: thick horizontal layers (all at once)│
│                                              │
│ Slice 0: minimal working feature → verify   │
│ Follow-ups: list 2-3 incremental adds       │
│ Deferred: note what's excluded              │
└──────────────────────────────────────────────┘
```

---

## Related

- See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md) for making slices concrete
- See [summarize-workflow.md](./summarize-workflow.md) for handling accumulated context
- See [incident-playbook.md](./incident-playbook.md) for corrective actions when tasks are too large
