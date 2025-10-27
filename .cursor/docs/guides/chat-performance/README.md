# Chat Quality Guides — Index

**Purpose**: Practical guides, recipes, and playbooks to maintain high-quality, efficient chats by managing context, tightening prompts, and recovering from common failure modes.

**Source Project**: [chat-performance-and-quality-tools](../../../../docs/projects/chat-performance-and-quality-tools/)  
**Canonical Location**: `.cursor/docs/guides/chat-performance/` (portable)  
**Symlink**: `docs/guides/chat-performance/` → `.cursor/docs/guides/chat-performance/` (discoverability)  
**Status**: Permanent documentation (will remain accessible after project archival)

---

## Quick Navigation

| Guide                                                         | When to Use                                  | Key Benefit                          |
| ------------------------------------------------------------- | -------------------------------------------- | ------------------------------------ |
| [Prompt Tightening Patterns](./prompt-tightening-patterns.md) | Before sending any request                   | Reduce clarification loops and bloat |
| [Task Splitting Templates](./task-splitting-templates.md)     | Task involves >5 files or crosses boundaries | Keep chats focused and verifiable    |
| [Summarize-to-Continue Workflow](./summarize-workflow.md)     | Gauge score ≤2/5 or headroom <20%            | Reclaim context capacity             |
| [Incident Playbook](./incident-playbook.md)                   | Chat has issues (latency, truncation, loops) | Quick corrective actions             |
| [Chunking Strategy](./chunking-strategy.md)                   | Artifact >1000 tokens or >10 sections        | Split while preserving meaning       |
| [Quality Rubric](./quality-rubric.md)                         | Assessing response quality                   | Consistent quality measurement       |
| [Prompt Versioning](./prompt-versioning.md)                   | Tracking prompt iterations                   | Reproducibility and comparison       |

---

## At-a-Glance: When to Use Each Guide

### Before Starting Work (Proactive)

1. **Planning a task?** → [Task Splitting Templates](./task-splitting-templates.md)

   - Check: Does task involve >5 files or multiple features?
   - Action: Break into minimal slices (1-3 files per chat)

2. **Writing a request?** → [Prompt Tightening Patterns](./prompt-tightening-patterns.md)
   - Check: Have you specified target files, exact change, and success criteria?
   - Action: Use the 5-point checklist before sending

---

### During Work (Monitoring)

3. **Check context efficiency periodically**
   - Prompt: "Show gauge" or "Context efficiency?"
   - If score ≤3/5 → consult [Incident Playbook](./incident-playbook.md)

---

### When Issues Occur (Reactive)

4. **Chat feels slow or heavy?** → [Incident Playbook](./incident-playbook.md) → Incident 3 (Latency)
5. **Response truncated?** → [Incident Playbook](./incident-playbook.md) → Incident 4 (Truncation)
6. **Multiple clarification rounds?** → [Incident Playbook](./incident-playbook.md) → Incident 2 (Loops)
7. **Assistant asks "could you clarify"?** → [Incident Playbook](./incident-playbook.md) → Incident 1 (Vague Scope)

---

### When Context Is Bloated (Recovery)

8. **Need to continue work but chat is heavy?** → [Summarize-to-Continue Workflow](./summarize-workflow.md)
   - Action: Generate summary (1-2 paragraphs), start new chat with next task

---

## Common Workflows

### Workflow 1: Starting a New Feature

```text
1. Plan minimal first slice → [Task Splitting Templates]
2. Write tight request → [Prompt Tightening Patterns]
3. Implement slice → verify outcome
4. Check gauge → if score ≤3/5, consider summarizing
5. Repeat for next slice
```

---

### Workflow 2: Recovering from Context Bloat

```text
1. Recognize symptoms → slow responses, ≥4 clarification loops, gauge ≤2/5
2. Check gauge → confirm score and signals
3. Generate summary → [Summarize-to-Continue Workflow]
4. Start new chat → seed with summary + next concrete task
5. Verify handoff → assistant confirms understanding
```

---

### Workflow 3: Handling Truncated Responses

```text
1. Symptom: response ends mid-sentence
2. Try continuation → "Continue" or "Please finish"
3. If truncation repeats → [Summarize-to-Continue Workflow]
4. Alternative: split request → [Task Splitting Templates]
```

---

## Integration with Context Efficiency Gauge

All guides work together with the [Context Efficiency Gauge](../.cursor/rules/context-efficiency.mdc):

- **Gauge score 4-5/5 (lean):** Continue with current approach, apply prompt tightening proactively
- **Gauge score 3/5 (ok):** Monitor for signals (≥2 true → consider summarizing)
- **Gauge score 1-2/5 (bloated):** Use [Incident Playbook](./incident-playbook.md) + [Summarize Workflow](./summarize-workflow.md)

---

## Quick Reference Cards

Each guide includes a **Quick Reference Card** for at-a-glance reminders:

- **Prompt Tightening:** 5-point checklist (target, change, success, scope, commands)
- **Task Splitting:** 3-question decision tree (verify in <10 min? >5 files? multiple features?)
- **Summarize Workflow:** When to summarize (gauge ≤2/5, headroom <20%, ≥4 loops)
- **Incident Playbook:** Diagnostic flow (check gauge → identify symptom → apply action)

---

## Examples by Scenario

### Scenario: Building a REST API

**Phase 1 (read-only endpoint):**

- Guide: [Task Splitting Templates](./task-splitting-templates.md) → "Read-Only First"
- Request: "Add `GET /api/users` to `routes/users.ts`, return `[{ id, email }]`, test with curl"

**Phase 2 (create endpoint):**

- Guide: [Prompt Tightening Patterns](./prompt-tightening-patterns.md) → Pattern 2 (narrow scope)
- Request: "Add `POST /api/users` to `routes/users.ts`, body `{ email, password }`, return `201 { userId }`"

**Phase 3 (context check):**

- Check gauge → if score 3/5 + 2 signals → [Summarize Workflow](./summarize-workflow.md)

**Phase 4 (continue with new features):**

- New chat with summary: "Completed GET/POST endpoints. Next: add `PATCH /api/users/:id`..."

---

### Scenario: Debugging a Performance Issue

**Step 1 (narrow scope):**

- Guide: [Prompt Tightening Patterns](./prompt-tightening-patterns.md) → Pattern 3 (add success criteria)
- Request: "Optimize `summary.ts` for 10K-line files, target <1s (current 3s), method: cache parsed entries"

**Step 2 (if clarifications occur):**

- Guide: [Incident Playbook](./incident-playbook.md) → Incident 2 (clarification loops)
- Action: Provide acceptance bundle (file, metric, verification command)

**Step 3 (verify):**

- Run: `time node dist/cli/summary.js example-10k.txt`
- If still slow → start new chat with refined constraints

---

## Related Project Files

- **[ERD](../../../../docs/projects/chat-performance-and-quality-tools/erd.md):** Full project requirements and architecture
- **[Tasks](../tasks.md):** Implementation checklist and progress tracking
- **[Discovery](../discovery.md):** Initial research and open questions
- **[Scoring Rubric](../scoring-rubric-implementation.md):** Context Efficiency Gauge algorithm details

---

## Feedback and Iteration

These guides are living documents. If you encounter:

- **New failure modes** not covered → add to [Incident Playbook](./incident-playbook.md)
- **Effective patterns** → add to [Prompt Tightening Patterns](./prompt-tightening-patterns.md)
- **Better splitting strategies** → add to [Task Splitting Templates](./task-splitting-templates.md)

Document improvements in the main project or open a discussion for review.

---

## Quick Start (First-Time Users)

1. **Read:** [Prompt Tightening Patterns](./prompt-tightening-patterns.md) (5 min)
2. **Try:** Apply the 5-point checklist to your next request
3. **Monitor:** Ask for gauge status after 3-4 exchanges
4. **Recover:** If gauge ≤3/5, use [Incident Playbook](./incident-playbook.md) or [Summarize Workflow](./summarize-workflow.md)

---

## Summary

| What You Want                           | Use This Guide                 |
| --------------------------------------- | ------------------------------ |
| Make requests clearer                   | Prompt Tightening Patterns     |
| Break large tasks into pieces           | Task Splitting Templates       |
| Recover from bloated context            | Summarize-to-Continue Workflow |
| Fix issues (latency, truncation, loops) | Incident Playbook              |
| Split large documents/code              | Chunking Strategy              |
| Assess response quality                 | Quality Rubric                 |
| Track prompt effectiveness              | Prompt Versioning              |

**Golden Rule:** Tight prompts + small slices + proactive monitoring = lean context + fast, high-quality responses
