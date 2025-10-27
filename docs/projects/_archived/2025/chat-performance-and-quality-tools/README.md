# Chat Performance and Quality Tools

**Status:** Complete — All Tiers Shipped/Documented  
**Project Type:** Tooling + Documentation

---

## Overview

This project provides tools and guidance to maintain high-quality, efficient chats by tracking context usage, providing actionable heuristics to avoid context overflow, and offering practical patterns for prompt crafting, task splitting, and recovery from common failure modes.

**Core Constraint:** No access to provider API response fields (usage, finish_reason, logprobs). All tooling relies on local estimation and qualitative heuristics.

---

## What's Shipped

**Note:** The 7 guides have been promoted to permanent documentation:

- **Canonical location:** `.cursor/docs/guides/chat-performance/` (portable, Cursor namespace)
- **Symlink:** `docs/guides/chat-performance/` → `.cursor/docs/guides/chat-performance/` (easy discovery)
- **Access:** Use either path; symlink ensures guides remain accessible after project archival

---

### 1. Context Efficiency Gauge

A lightweight, zero-dependency scoring system (1-5 scale: lean → bloated) based on qualitative signals:

- **Location:** `.cursor/rules/context-efficiency.mdc`
- **Inputs:** Scope concreteness, rules count, clarification loops, user-reported issues
- **Outputs:**
  - Gauge line: `Context Efficiency Gauge: 4/5 (lean) — narrow scope, minimal rules`
  - ASCII dashboard with scope/rules/loops/issues breakdown
  - Decision flow chart ("Should I start a new chat?")
- **Integration:** Surfaces in assistant status updates when score ≤3/5 or ≥2 signals true


---

### 2. Comprehensive Guides Library

Documentation for developers and chat users (permanent location):

| Guide                                                                                                           | Purpose                                                    | Status      |
| --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- | ----------- |
| [Prompt Tightening Patterns](../../../../../.cursor/docs/guides/chat-performance/prompt-tightening-patterns.md) | Transform vague requests into concrete, actionable prompts | ✅ Complete |
| [Task Splitting Templates](../../../../../.cursor/docs/guides/chat-performance/task-splitting-templates.md)     | Break large tasks into minimal, verifiable slices          | ✅ Complete |
| [Summarize-to-Continue Workflow](../../../../../.cursor/docs/guides/chat-performance/summarize-workflow.md)     | Reclaim context capacity when chat becomes heavy           | ✅ Complete |
| [Incident Playbook](../../../../../.cursor/docs/guides/chat-performance/incident-playbook.md)                   | Quick corrective actions for common failure modes          | ✅ Complete |
| [Chunking Strategy](../../../../../.cursor/docs/guides/chat-performance/chunking-strategy.md)                   | Split oversized artifacts into manageable chunks           | ✅ Complete |
| [Quality Rubric](../../../../../.cursor/docs/guides/chat-performance/quality-rubric.md)                         | Manual assessment checklist for response quality           | ✅ Complete |
| [Prompt Versioning](../../../../../.cursor/docs/guides/chat-performance/prompt-versioning.md)                   | Log and track prompt variants for reproducibility          | ✅ Complete |

**Entry Point:** [.cursor/docs/guides/chat-performance/](../../../../../.cursor/docs/guides/chat-performance/) (permanent location)  
**Symlink (for convenience):** [docs/guides/chat-performance/](../../../../guides/chat-performance/)

---

## Quick Start

### For Users (Want Better Chat Quality?)

1. **Before sending a request:** Use [Prompt Tightening Patterns](../../../../../.cursor/docs/guides/chat-performance/prompt-tightening-patterns.md)

   - 5-point checklist: target files, concrete change, success criteria, scope boundaries, verification commands

2. **Planning a large task?** Use [Task Splitting Templates](../../../../../.cursor/docs/guides/chat-performance/task-splitting-templates.md)

   - Break into 1-3 file slices, prefer thin vertical slices over horizontal layers

3. **Chat feels heavy?** Check the gauge

   - Ask: "Show gauge" or "Context efficiency?"
   - If score ≤2/5 → use [Summarize Workflow](../../../../../.cursor/docs/guides/chat-performance/summarize-workflow.md)

4. **Issues during chat?** Consult [Incident Playbook](../../../../../.cursor/docs/guides/chat-performance/incident-playbook.md)
   - 6 common incidents with recovery procedures (vague scope, loops, latency, truncation, etc.)

---

### For Contributors (Want to Understand the Project?)

1. **Requirements & Architecture:** [erd.md](./erd.md)

---

### For CLI Users (Want Quantitative Analysis?)

**Analyze chat transcripts:**

```bash
# Estimate tokens for a transcript
.cursor/scripts/chat-performance/token-estimate.sh transcript.txt --model gpt-4-turbo

# Full analysis: tokens + headroom + status
.cursor/scripts/chat-performance/chat-analyze.sh transcript.txt --buffer 15

# JSON output for automation
echo "Sample text" | .cursor/scripts/chat-performance/chat-analyze.sh --format json
```

**Supported models (13):**

- OpenAI (7): gpt-3.5-turbo, gpt-4, gpt-4-32k, gpt-4-turbo, gpt-4o, o1-preview, o1-mini
- Anthropic (6): claude-3-haiku, claude-3-sonnet, claude-3-opus, claude-3-5-sonnet, claude-3-5-haiku, claude-sonnet-4-5

---

## Success Metrics

### Delivered

- ✅ 7 comprehensive guides (prompt tightening, task splitting, summarization, incident recovery, chunking, quality rubric, versioning)
- ✅ Context Efficiency Gauge integrated into assistant behavior
- ✅ Token estimation CLI with tiktoken support (13 models: OpenAI 7, Anthropic 6)
- ✅ Headroom calculator with status thresholds
- ✅ Unified `chat-analyze` tool (text + JSON output)
- ✅ 23 unit tests (all passing)
- ✅ Integration with existing rules (scope-check, assistant-behavior, intent-routing)
- ✅ Model specs documented with sync procedure

### Target Outcomes

- Reduced clarification loops through tighter prompts
- Proactive context management using gauge + headroom tools
- Faster incident recovery with playbook procedures
- Better reproducibility through prompt versioning

---

## Key Design Decisions

### Why Qualitative First (Tier 1)?

- **Zero dependencies:** Works immediately, no tooling setup required
- **Human-friendly:** Scoring is transparent and intuitive (1-5 scale)
- **Actionable:** Guides provide concrete next steps, not just measurements
- **Portable:** Plain markdown, no external services or libraries

### Why Defer Provider API Features?


---

## Project Structure

```
chat-performance-and-quality-tools/         ← Project files (will archive)
├── README.md                               ← You are here
├── erd.md                                  ← Requirements and architecture
└── guides/                                 ← Original guide development location
    └── (7 guides)                          ← Promoted to permanent location (see below)

.cursor/docs/guides/chat-performance/       ← PERMANENT: Guides (portable location)
├── README.md                               ← Guide index
├── prompt-tightening-patterns.md           ← Make requests concrete
├── task-splitting-templates.md             ← Break tasks into slices
├── summarize-workflow.md                   ← Reclaim context capacity
├── incident-playbook.md                    ← Recovery procedures
├── chunking-strategy.md                    ← Split large artifacts
├── quality-rubric.md                       ← Response quality assessment
└── prompt-versioning.md                    ← Track prompt variants

docs/guides/chat-performance/               ← Symlink to .cursor/docs/guides/chat-performance/

.cursor/scripts/chat-performance/           ← PERMANENT: CLI tools
├── package.json                            ← Isolated dependencies
├── models.json                             ← Model configurations (13 models)
├── model-configs-sync.sh                   ← Model sync/validation script
├── token-estimator.js                      ← Token estimation module
├── token-estimator.test.js                 ← 10 unit tests
├── headroom-calculator.js                  ← Headroom calculation
├── headroom-calculator.test.js             ← 13 unit tests
├── token-estimate.sh                       ← Token estimation CLI
└── chat-analyze.sh                         ← Unified analysis CLI
```

**Archival Note:** When this project archives to `docs/projects/_archived/2025/chat-performance-and-quality-tools/`, the guides and CLI tools remain accessible at their permanent locations under `.cursor/`.

---

## Related Projects

- **[Context Efficiency Gauge Rule](/.cursor/rules/context-efficiency.mdc)** — Integration point for assistant behavior
- **[Scope Check Rule](/.cursor/rules/scope-check.mdc)** — Pre-work checklist (complements prompt tightening)
- **[Assistant Behavior Rule](/.cursor/rules/assistant-behavior.mdc)** — Status updates include gauge when needed

---

## How to Contribute

### Improving Guides

If you discover:

- **New failure modes** → add to [Incident Playbook](../../../../../.cursor/docs/guides/chat-performance/incident-playbook.md)
- **Effective patterns** → add to [Prompt Tightening Patterns](../../../../../.cursor/docs/guides/chat-performance/prompt-tightening-patterns.md)
- **Better splitting strategies** → add to [Task Splitting Templates](../../../../../.cursor/docs/guides/chat-performance/task-splitting-templates.md)

### Maintaining Model Configurations

**Source Requirement:**

- Model context limits should be synced with [Cursor models docs](https://cursor.com/docs/models)
- Current specs compiled from OpenAI/Anthropic public documentation
- Last sync: 2025-10-22

**Update Procedure:**

1. Check Cursor docs for new/updated models
2. Update `MODEL_CONFIGS` in `.cursor/scripts/chat-performance/token-estimator.js`
3. Run tests: `cd .cursor/scripts/chat-performance && npm test`
4. Update help text in `token-estimate.sh` and `chat-analyze.sh`

**Current Status (13 models):**

- OpenAI (7): gpt-3.5-turbo, gpt-4 variants, gpt-4o, o1 variants
- Anthropic (6): Claude 3 family, Claude 3.5 family, Claude Sonnet 4.5

**Note:** GPT-5 not yet released (as of Oct 2025); will add when available

---

## Quick Reference

### Gauge Triggers (When to Check)

- Before starting work (proactive baseline)
- After 3-4 exchanges (periodic check)
- When chat feels slow or heavy
- When responses seem vague or truncated

### Gauge Scores

| Score | Label   | Recommendation                              |
| ----- | ------- | ------------------------------------------- |
| 5     | lean    | Continue here                               |
| 4     | lean    | Continue here                               |
| 3     | ok      | Monitor; consider summarizing if ≥2 signals |
| 2     | bloated | Strongly recommend new chat                 |
| 1     | bloated | Strongly recommend new chat                 |

### Recovery Quick Actions

| Issue                    | First Action                                       |
| ------------------------ | -------------------------------------------------- |
| Vague scope              | Specify target files + success criteria            |
| Clarification loops      | Provide explicit intent + acceptance bundle        |
| Latency / slow responses | Check gauge → reduce rules → new chat              |
| Response truncated       | Ask "Continue" or summarize + new chat             |
| Context feels heavy      | Tighten prompts → split tasks → preemptive summary |

---

## Golden Rule

**Tight prompts + small slices + proactive monitoring = lean context + fast, high-quality responses**

---

## Links

- **Full Requirements:** [erd.md](./erd.md)
- **User Guides:** [.cursor/docs/guides/chat-performance/](../../../../../.cursor/docs/guides/chat-performance/) (permanent location)
