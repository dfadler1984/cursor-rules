# Prompt Versioning — Reproducibility & Iteration Tracking

**Purpose**: Log prompt variants with metadata (model, settings, context) for reproducibility and comparative analysis.

---

## Why Version Prompts?

### Benefits

- **Reproducibility**: Re-run same prompt with same settings
- **A/B Comparison**: Compare different phrasings/models/temperatures
- **Iteration Tracking**: See how prompts evolved over time
- **Debugging**: Isolate which change caused regression
- **Knowledge Sharing**: Share effective prompts with team

---

## Versioning Format

### ID Format

**Pattern:** `{slug}-{date}-{counter}`

**Examples:**

- `auth-impl-20251022-01`
- `perf-opt-20251022-02`
- `bug-fix-20251023-01`

**Components:**

- `slug`: Human-readable topic (kebab-case, 2-4 words)
- `date`: YYYY-MM-DD
- `counter`: 01, 02, 03... (resets daily)

---

### Metadata Schema

```json
{
  "id": "auth-impl-20251022-01",
  "timestamp": "2025-10-22T14:30:00Z",
  "model": "gpt-4-turbo",
  "settings": {
    "temperature": 0.7,
    "max_tokens": 4096,
    "top_p": 1.0
  },
  "context": {
    "filesAttached": ["src/auth.ts", "src/auth.test.ts"],
    "rulesAttached": ["tdd-first", "code-style"],
    "estimatedTokens": 3200
  },
  "prompt": "Add JWT token validation to auth middleware...",
  "outcome": {
    "success": true,
    "quality": "excellent",
    "notes": "Clean implementation, all tests passed"
  }
}
```

---

## Logging Workflow

### Manual Logging (Markdown)

**File:** `prompts-log.md`

```markdown
## auth-impl-20251022-01

**Date:** 2025-10-22 14:30  
**Model:** gpt-4-turbo  
**Settings:** temp=0.7, max_tokens=4096  
**Context:** src/auth.ts, src/auth.test.ts (est. 3200 tokens)

**Prompt:**
```

Add JWT token validation to auth middleware in src/auth.ts:

- Function: validateToken(req, res, next)
- Check Authorization: Bearer <token>
- Verify with jsonwebtoken.verify()
- Return 401 if invalid
- Tests: src/auth.test.ts

```

**Outcome:** ✅ Excellent
**Notes:** Clean implementation, all tests passed on first try

---

## auth-impl-20251022-02

**Date:** 2025-10-22 15:45
**Model:** claude-3-5-sonnet
**Settings:** temp=0.5
**Context:** Same as -01

**Prompt:** (Same as -01, testing different model)

**Outcome:** ✅ Good
**Notes:** Slightly more verbose, but also correct

---
```

---

### Structured Logging (JSON)

**File:** `prompts-log.json`

```json
[
  {
    "id": "auth-impl-20251022-01",
    "timestamp": "2025-10-22T14:30:00Z",
    "model": "gpt-4-turbo",
    "settings": {
      "temperature": 0.7,
      "max_tokens": 4096
    },
    "context": {
      "filesAttached": ["src/auth.ts", "src/auth.test.ts"],
      "rulesAttached": ["tdd-first", "code-style"],
      "estimatedTokens": 3200
    },
    "prompt": "Add JWT token validation...",
    "outcome": {
      "success": true,
      "quality": "excellent",
      "iterationCount": 1
    }
  }
]
```

---

## Comparison Workflows

### Workflow 1: Model Comparison

**Goal:** Test same prompt with different models

```markdown
## Comparison: auth-impl (2025-10-22)

**Prompt:** (Same for all)
"Add JWT token validation to auth middleware..."

| ID  | Model             | Quality   | Notes                      |
| --- | ----------------- | --------- | -------------------------- |
| -01 | gpt-4-turbo       | Excellent | Clean, passed tests        |
| -02 | claude-3-5-sonnet | Good      | More verbose               |
| -03 | gpt-4             | Good      | Simpler, missing edge case |

**Winner:** gpt-4-turbo (-01)  
**Reason:** Most concise, complete edge case handling
```

---

### Workflow 2: Temperature Comparison

**Goal:** Find optimal temperature for task type

```markdown
## Comparison: perf-opt (2025-10-22)

**Model:** gpt-4-turbo (same for all)  
**Prompt:** "Optimize Dashboard.tsx render time..."

| ID  | Temperature | Quality   | Notes                        |
| --- | ----------- | --------- | ---------------------------- |
| -01 | 0.3         | Good      | Safe, standard optimizations |
| -02 | 0.7         | Excellent | Creative, novel approach     |
| -03 | 1.0         | Fair      | Too experimental, risky      |

**Winner:** temp=0.7 (-02)  
**Lesson:** Creative tasks benefit from higher temperature
```

---

### Workflow 3: Iteration Tracking

**Goal:** See how prompt evolved to final version

```markdown
## Evolution: bug-fix-login (2025-10-23)

### v1 (Vague)

**Prompt:** "Fix the bug in the login page"  
**Outcome:** ❌ Vague response, needed clarification

### v2 (Better)

**Prompt:** "Fix crash in LoginForm.tsx when password field is empty"  
**Outcome:** ⚠️ Fixed symptom, not root cause

### v3 (Specific)

**Prompt:** "Fix crash in LoginForm.tsx line 45 when password is empty:

- Add null check before password.trim()
- Test with empty string input"  
  **Outcome:** ✅ Excellent, root cause fixed

**Lesson:** Specificity matters; v1→v2→v3 shows progression
```

---

## Retrieval & Replay

### Retrieve by ID

```bash
# Grep markdown log
grep -A 10 "## auth-impl-20251022-01" prompts-log.md

# Query JSON log
cat prompts-log.json | jq '.[] | select(.id == "auth-impl-20251022-01")'
```

---

### Replay Prompt

To re-run a logged prompt:

1. Retrieve metadata (model, settings, context)
2. Recreate context (attach same files/rules)
3. Send same prompt text
4. Compare outcome with logged outcome

**Use case:** Verify model improvements over time (same prompt, months later)

---

## Storage Options

### Option 1: Local Markdown (Simplest)

**Pros:**

- Human-readable
- Easy to edit/annotate
- Works offline

**Cons:**

- Manual logging
- No automated analysis

**Best for:** Individual use, small teams

---

### Option 2: Local JSON (Structured)

**Pros:**

- Machine-parseable
- Easy aggregation
- Support for scripts

**Cons:**

- Harder to read
- Requires JSON editor

**Best for:** Automation, trend analysis

---

### Option 3: Database (Advanced)

**Pros:**

- Queryable
- Multi-user
- Analytics-friendly

**Cons:**

- Infrastructure overhead
- Requires setup

**Best for:** Teams, large-scale tracking

---

## Integration with Token Estimator

```bash
# Estimate prompt size before logging
echo "Your prompt text..." | .cursor/scripts/chat-performance/token-estimate.sh

# Add to log metadata
"estimatedTokens": 3200
```

---

## Logging Template (Copy & Paste)

### Markdown Template

```markdown
## {slug}-{YYYYMMDD}-{counter}

**Date:** YYYY-MM-DD HH:MM  
**Model:** {model-id}  
**Settings:** temp={X}, max_tokens={Y}  
**Context:** {files}, {rules} (est. {N} tokens)

**Prompt:**
```

{Your prompt text}

```

**Outcome:** [✅ Excellent | ⚠️ Good | ❌ Poor]
**Notes:** {observations}

---
```

---

### JSON Template

```json
{
  "id": "{slug}-{YYYYMMDD}-{counter}",
  "timestamp": "{ISO8601}",
  "model": "{model-id}",
  "settings": {
    "temperature": 0.7,
    "max_tokens": 4096
  },
  "context": {
    "filesAttached": [],
    "rulesAttached": [],
    "estimatedTokens": 0
  },
  "prompt": "{text}",
  "outcome": {
    "success": true,
    "quality": "excellent|good|fair|poor",
    "notes": ""
  }
}
```

---

## Analysis Queries

### Most Successful Model

```bash
# From JSON log
cat prompts-log.json | jq '[.[] | select(.outcome.success == true)] | group_by(.model) | map({model: .[0].model, count: length}) | sort_by(.count) | reverse'
```

---

### Average Quality by Temperature

```bash
# From CSV export
# temp,quality_score
# 0.3,4
# 0.7,5
# 1.0,3

awk -F',' '{sum[$1]+=$2; count[$1]++} END {for (temp in sum) print temp, sum[temp]/count[temp]}' prompts-quality.csv | sort -n
```

---

## Best Practices

### 1. Log Immediately (Must)

**Don't wait:** Log right after receiving response while details are fresh.

---

### 2. Include Context (Must)

**Always log:**

- Files attached
- Rules active
- Estimated tokens

**Why:** Context affects output; needed for reproducibility.

---

### 3. Rate Quality Consistently (Should)

**Use consistent scale:**

- Excellent (5): Perfect, no edits needed
- Good (4): Minor tweaks needed
- Fair (3): Significant edits needed
- Poor (2): Mostly unusable
- Failure (1): Complete miss

---

### 4. Document Learnings (Should)

**Capture patterns:**

- "Specific prompts → better results"
- "Model X excels at Y tasks"
- "Temperature 0.7 optimal for creative work"

---

### 5. Review Periodically (Should)

**Monthly review:**

- Which prompts worked best?
- Which models/settings optimal?
- What patterns emerge?

---

## Quick Reference Card

```text
┌──────────────────────────────────────────────┐
│ PROMPT VERSIONING QUICK CARD                 │
├──────────────────────────────────────────────┤
│ ID Format: {slug}-{YYYYMMDD}-{counter}       │
│ Example: auth-impl-20251022-01               │
│                                              │
│ Log Immediately After Response:              │
│ - Timestamp                                  │
│ - Model + settings                           │
│ - Context (files, rules, tokens)             │
│ - Prompt text                                │
│ - Outcome (quality rating + notes)           │
│                                              │
│ Use Cases:                                   │
│ - Reproducibility (replay later)             │
│ - Comparison (models, temps, phrasings)      │
│ - Learning (what works, what doesn't)        │
│                                              │
│ Storage: Markdown (simple) or JSON (analysis)│
└──────────────────────────────────────────────┘
```

---

## Related

- See [quality-rubric.md](./quality-rubric.md) for scoring response quality
- See [prompt-tightening-patterns.md](./prompt-tightening-patterns.md) for improving prompts
- See [../../../docs/projects/chat-performance-and-quality-tools/erd.md](../../../docs/projects/chat-performance-and-quality-tools/erd.md) Section 4.5 for prompt versioning requirements
