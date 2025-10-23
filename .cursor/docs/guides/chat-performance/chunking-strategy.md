# Chunking Strategy — Semantic Splitting for Large Artifacts

**Purpose**: Guide for splitting oversized documents, code files, and artifacts into manageable chunks while preserving meaning and context.

---

## When to Chunk

### Triggers

- Artifact >1000 tokens (estimated)
- Document >10 sections or >100 lines
- Code file >500 lines
- ERD/spec with >15 subsections
- Any content that would consume >10% of context window

### Decision Flow

```text
┌──────────────────────────────────────────────┐
│ SHOULD I CHUNK THIS ARTIFACT?                │
├──────────────────────────────────────────────┤
│ 1) Estimated tokens >1000?                   │
│    - Yes → Chunk                             │
│    - No → 2) >10 logical sections?           │
│             - Yes → Consider chunking        │
│             - No → Keep as single artifact   │
└──────────────────────────────────────────────┘
```

---

## Chunking Principles

### 1. Split by Logical Boundaries (Must)

**Prefer:**

- Natural section breaks (headings, separators)
- Functional boundaries (classes, modules, features)
- Dependency boundaries (keep related code together)

**Avoid:**

- Mid-function splits
- Breaking dependent sections apart
- Arbitrary line-count splits

---

### 2. Each Chunk = Self-Contained Unit (Must)

**Each chunk should include:**

- Clear title describing its content
- 1-2 sentence TL;DR at the top
- Minimal cross-references (or explicit "See chunk N")
- Complete logical unit (intro → body → conclusion)

---

### 3. Preserve Context Links (Should)

**At chunk boundaries, include:**

- **Previous:** 1-sentence summary of what came before
- **Next:** 1-sentence preview of what comes next
- **Index:** Optional chunk index (e.g., "Part 2 of 5")

---

## Chunking Patterns

### Pattern 1: Documentation by Sections

**Before (monolithic):**

```markdown
# Large Project Spec (2500 tokens)

## Introduction

...

## Goals

...

## Requirements (10 subsections)

...

## Architecture

...

## Testing

...
```

**After (chunked):**

**Chunk 1: Overview & Goals**

```markdown
# Project Spec — Part 1: Overview & Goals

**TL;DR:** High-level introduction, project goals, and success criteria.

**Next:** Part 2 covers functional requirements.

---

## Introduction

...

## Goals

...
```

**Chunk 2: Functional Requirements**

```markdown
# Project Spec — Part 2: Functional Requirements

**TL;DR:** Core feature requirements and user stories.

**Previous:** Part 1 covered overview and goals.  
**Next:** Part 3 covers architecture and testing.

---

## Functional Requirements

### 4.1 Feature A

...

### 4.2 Feature B

...
```

**Chunk 3: Architecture & Testing**

```markdown
# Project Spec — Part 3: Architecture & Testing

**TL;DR:** System design, data model, and testing strategy.

**Previous:** Part 2 covered functional requirements.

---

## Architecture

...

## Testing

...
```

---

### Pattern 2: Code by Module/Class

**Before (monolithic):**

```typescript
// user-service.ts (600 lines)
export class UserService {
  // Authentication (150 lines)
  // Profile management (200 lines)
  // Permissions (150 lines)
  // Audit logging (100 lines)
}
```

**After (chunked):**

**Chunk 1: user-auth.ts**

```typescript
// user-auth.ts
/**
 * User Authentication
 *
 * Handles login, logout, and token management.
 * See: user-profile.ts for profile operations.
 */

export class UserAuth {
  // Authentication logic (150 lines)
}
```

**Chunk 2: user-profile.ts**

```typescript
// user-profile.ts
/**
 * User Profile Management
 *
 * Handles profile CRUD and validation.
 * See: user-permissions.ts for authorization.
 */

export class UserProfile {
  // Profile logic (200 lines)
}
```

---

### Pattern 3: ERD by Feature Area

**Before (large ERD):**

```markdown
# ERD: Full Platform (3000 tokens, 20 sections)
```

**After (chunked by feature):**

**Chunk 1: Core Features ERD**

```markdown
# ERD: Core Features (Auth, Users, Profiles)

**TL;DR:** Authentication, user management, and profile features.

**Scope:** Sections 1-4 (Introduction, Goals, User Stories, Core Requirements)  
**Next:** Advanced Features ERD covers integrations and analytics.

---

## 1. Introduction

...

## 4. Core Functional Requirements

...
```

**Chunk 2: Advanced Features ERD**

```markdown
# ERD: Advanced Features (Integrations, Analytics)

**TL;DR:** Third-party integrations and analytics features.

**Previous:** Core Features ERD covered auth and user management.  
**Scope:** Sections 10-15 (Integrations, Analytics, Reporting)

---

## 10. Integrations

...
```

---

## Chunking Workflow

### Step 1: Estimate Total Size

Use token estimator:

```bash
.cursor/scripts/chat-performance/token-estimate.sh document.md
```

If >1000 tokens → proceed to Step 2.

---

### Step 2: Identify Split Points

**For documentation:**

- Top-level headings (##)
- Major sections (Introduction, Requirements, Architecture, Testing)
- Feature groupings (Core, Advanced, Admin)

**For code:**

- Class boundaries
- Module boundaries
- Feature boundaries

---

### Step 3: Create Chunk Files

**Naming convention:**

- Documentation: `{name}-part{N}-{slug}.md`
  - Example: `project-spec-part1-overview.md`
- Code: `{module}-{feature}.ts`
  - Example: `user-auth.ts`, `user-profile.ts`

---

### Step 4: Add TL;DR and Context Links

**Template for each chunk:**

```markdown
# {Title} — Part {N}: {Subtitle}

**TL;DR:** {1-2 sentence summary}

**Previous:** {if applicable}  
**Next:** {if applicable}

---

{Content}
```

---

### Step 5: Verify Chunk Quality

**Checklist:**

- [ ] Each chunk <1000 tokens?
- [ ] Each chunk has clear title and TL;DR?
- [ ] Logical boundaries respected (no mid-function splits)?
- [ ] Cross-references explicit?
- [ ] Dependencies kept together or documented?

---

## Token Budgets per Chunk

| Chunk Type          | Target Tokens | Max Tokens | Rationale                       |
| ------------------- | ------------- | ---------- | ------------------------------- |
| Documentation       | 500-800       | 1000       | One focused topic per chunk     |
| Code (class/module) | 300-500       | 800        | One responsibility per chunk    |
| ERD/Spec sections   | 600-900       | 1200       | Complete feature area per chunk |
| Config/Data         | 200-400       | 600        | One logical grouping per chunk  |

---

## Anti-Patterns (Avoid These)

### Anti-Pattern: Arbitrary Line-Count Split

**Bad:**

```markdown
# Part 1 (lines 1-100)

...mid-sentence...

# Part 2 (lines 101-200)

...sentence continues from Part 1...
```

**Good:**

```markdown
# Part 1: Introduction & Goals

...complete section...

# Part 2: Requirements

...new section starts cleanly...
```

---

### Anti-Pattern: Breaking Dependencies

**Bad:**

```typescript
// chunk-1.ts
export function processUser(user: User) {
  return validateUser(user); // validateUser defined in chunk-2!
}

// chunk-2.ts
function validateUser(user: User) { ... }
```

**Good:**

```typescript
// user-validation.ts
export function validateUser(user: User) { ... }

// user-processing.ts
import { validateUser } from './user-validation';
export function processUser(user: User) {
  return validateUser(user);
}
```

---

### Anti-Pattern: No Context Links

**Bad:**

```markdown
# Part 2

...starts abruptly with no context...
```

**Good:**

```markdown
# Part 2: Requirements

**TL;DR:** Core feature requirements.

**Previous:** Part 1 covered project overview and goals.  
**Next:** Part 3 covers architecture.

---

...
```

---

## Integration with Other Tools

### Use with Token Estimator

```bash
# Estimate size of each chunk
for file in *-part*.md; do
  echo "$file:"
  .cursor/scripts/chat-performance/token-estimate.sh "$file"
  echo ""
done
```

---

### Use with Chat Analyze

```bash
# Check if sending all chunks at once would exceed limits
cat *-part*.md | .cursor/scripts/chat-performance/chat-analyze.sh --model gpt-4-turbo
```

---

### Use with Summarize Workflow

When chat context is heavy:

1. Summarize progress through current chunk
2. Start new chat with summary
3. Attach next chunk only

See: [summarize-workflow.md](./summarize-workflow.md)

---

## Quick Reference Card

```text
┌──────────────────────────────────────────────┐
│ CHUNKING QUICK CARD                          │
├──────────────────────────────────────────────┤
│ When: >1000 tokens or >10 sections           │
│                                              │
│ Split by:                                    │
│ - Logical boundaries (headings, modules)     │
│ - Functional boundaries (classes, features)  │
│ - Dependency boundaries (keep related        │
│   together)                                  │
│                                              │
│ Each chunk:                                  │
│ - Title + TL;DR (1-2 sentences)              │
│ - Context links (Previous/Next)              │
│ - Self-contained unit                        │
│ - <1000 tokens                               │
│                                              │
│ Verify: token-estimate.sh each chunk         │
└──────────────────────────────────────────────┘
```

---

## Examples by Document Type

### ERD/Spec

**Split by:**

- Part 1: Introduction, Goals, Overview
- Part 2: Functional Requirements (Core)
- Part 3: Functional Requirements (Advanced)
- Part 4: Architecture, Data Model
- Part 5: Testing, Rollout, References

---

### Large Code File

**Split by:**

- `{module}-core.ts` — Core logic (pure functions)
- `{module}-api.ts` — API/boundary layer
- `{module}-types.ts` — Type definitions
- `{module}-utils.ts` — Helper utilities

---

### Implementation Guide

**Split by:**

- Part 1: Setup & Prerequisites
- Part 2: Core Implementation
- Part 3: Testing & Validation
- Part 4: Deployment & Rollout

---

## Related

- See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md) for narrowing request scope
- See [task-splitting-templates.md](./task-splitting-templates.md) for breaking work into slices
- See [summarize-workflow.md](./summarize-workflow.md) for reclaiming context
- See [incident-playbook.md](./incident-playbook.md) for handling context overload
