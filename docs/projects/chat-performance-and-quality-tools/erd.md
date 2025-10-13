# Engineering Requirements Document — Chat Performance and Quality Tools

Mode: Full

## 1. Introduction/Overview

This project defines tools and guidance to maintain high-quality, efficient chats by tracking context usage (token headroom), estimating token counts locally, and providing practical heuristics to avoid context overflow and response degradation.

**Constraint**: No access to provider API response fields (usage, finish_reason, logprobs, etc.). All tooling relies on local estimation and qualitative heuristics.

## 2. Goals/Objectives

- Provide actionable heuristics to assess chat context efficiency (qualitative gauge).
- Offer a tokenizer-based token estimation utility (script/library) for common models.
- Calculate headroom using estimated tokens and known model context limits.
- Document per-model context limits with references to official documentation.
- Surface clear recommendations when context is becoming inefficient or bloated.
- Provide guidance, recipes, and an incident playbook for common failure modes.

## 3. User Stories

- As a developer, I can quickly assess context efficiency using qualitative signals (scope, rules attached, clarification loops).
- As a developer, I can estimate token usage and headroom using a local tokenizer.
- As an author, I can trim or summarize content when nearing the context limit, guided by clear heuristics and decision aids.
- As a reviewer, I can analyze chat transcripts to compare efficiency and identify improvement opportunities.
- As a developer, I can follow documented patterns and recipes to keep chats effective.

## 4. Functional Requirements

### 4.1 Context Efficiency Gauge (Tier 1: Ship Now)

1. Qualitative scoring rubric (1-5 scale: lean → bloated) based on:
   - Scope concreteness (narrow task vs vague goal)
   - Rules attached count
   - Clarification loop count
   - User-reported latency or quality issues
2. ASCII output: gauge line and decision banner ("Should I start a new chat?")
3. Recommendation: start new chat when ≥2 signals are true

### 4.2 Docs, Recipes, and Playbook (Tier 1: Ship Now)

4. Actionable recipes for common scenarios:
   - "Tighten your prompt" patterns
   - "Split task" templates
   - "Summarize-to-continue" workflow
5. Incident playbook: failure modes (vague scope, clarification loops, latency) → corrective steps

### 4.3 Token Estimation and Headroom (Tier 2: Ship Soon)

6. Local token estimation: tokenizer-based script/library (tiktoken or equivalent)
7. Headroom calculation: `max_context - (estimated_tokens + planned_completion + buffer)`
8. Output: remaining headroom, status (ok/warning/critical), and recommendation

### 4.4 CLI Tool (Tier 2: Ship Soon)

9. Unified command: `chat-analyze <transcript.txt>`
10. Output: estimated tokens, headroom, efficiency gauge, warnings

### 4.5 Quality Enhancements (Tier 3: Ship Later)

11. Prompts linter: static analysis for ambiguity, multi-intent, missing constraints
12. Quality rubric: manual checklist (factuality, specificity, actionability) with 1-5 scale
13. Chunking strategy: guidance for splitting large artifacts with semantic titles and per-chunk TL;DR
14. Prompt versioning: log prompt variants with model/settings for reproducibility

### 4.6 Future Vetting (Tier 4: Low Priority)

15. Auto-summarize cadence: heuristic-triggered prompt to summarize when estimated tokens > threshold
16. KPI dashboard: track avg estimated tokens, clarification loops, rules attached (manual logging + aggregation)
17. Replay harness: re-analyze saved transcripts for token/gauge scoring and efficiency comparison
18. Synthetic stress tests: validate token estimator accuracy and gauge scoring consistency

## 5. Non-Functional Requirements

- Estimation accuracy within an acceptable bound (target: ±5-10% vs actual token counts, acknowledging hidden system prompts and tool metadata).
- Fast: sub-second estimates for typical message sizes.
- Portable and dependency-light: prefer shell scripts + minimal dependencies (Node.js or Python for tokenizer).
- Zero-dependency gauge: qualitative heuristics must work without external tools.

## 6. Architecture/Design

- **Gauge module**: Pure heuristic scoring (no dependencies); outputs text/ASCII.
- **Token estimator**: Tokenization adapter layer (pluggable; e.g., tiktoken-compatible) for local estimation.
- **Headroom calculator**: Pure calculation module using estimated tokens + known model limits.
- **CLI wrapper**: Unified interface to all tools; reads transcript files or accepts piped input.
- **Docs/guidance**: Markdown files with recipes, playbook, and decision aids.

## 7. Data Model and Storage

- No persistent storage required; ephemeral calculations.

## 8. API/Contracts

### 8.1 Gauge Module

- Function: `scoreEfficiency({ scopeConcrete, rulesCount, clarificationLoops, userIssues }) -> { score, label, recommendation }`
- Output formats:
  - Gauge line: `Context Efficiency Gauge: X/5 (lean|ok|bloated) — rationale`
  - ASCII banner: decision flow chart

### 8.2 Token Estimator

- Function: `estimateTokens(text, { model }) -> { tokens, method }` (method: tiktoken | fallback)
- CLI: `token-estimate <file> --model <model-id>`

### 8.3 Headroom Calculator

- Function: `computeHeadroom({ maxContext, estimatedTokens, plannedCompletion, bufferPct }) -> { headroom, status, recommendation }`
- Status values: `ok` (>20% headroom), `warning` (10-20%), `critical` (<10%)

### 8.4 Unified CLI

- Command: `chat-analyze <transcript.txt> [--model <model-id>] [--buffer <pct>]`
- Output: JSON or formatted text (tokens, headroom, gauge, warnings)

## 9. Integrations/Dependencies

- **Model context limits**: Source from [Cursor models docs](https://cursor.com/docs/models) (manual sync).
- **Tokenizer**: Optional dependency (tiktoken for Python, js-tiktoken for Node.js); fallback to char-based estimate.
- **Assistant rules**: Integrate gauge with `.cursor/rules/assistant-behavior.mdc` status updates.

## 10. Edge Cases and Constraints

- **No provider API access**: All tooling relies on local estimation and qualitative signals; exact token counts unavailable.
- **Estimation variance**: Local tokenizers may differ from provider counts by ±5-10% due to hidden system prompts, tool metadata, and encoding differences.
- **Model upgrades**: Model context limits or encodings may change; require manual documentation sync.
- **User input quality**: Qualitative gauge depends on user-reported latency/issues; may be inconsistent or absent.
- **Transcript format**: CLI tools assume plain-text transcripts; no structured chat format yet.

## 11. Testing & Acceptance

### Tier 1 (Gauge, Docs, Playbook)

- Manual review of gauge scoring rubric against known chat scenarios
- ASCII output validation (formatting, readability)
- Docs/recipes peer review for clarity and actionability

### Tier 2 (Token Estimator, Headroom, CLI)

- Unit tests for headroom calculation logic
- Token estimator tests using fixed text samples with known counts (per tokenizer docs)
- CLI smoke tests: read sample transcript, output tokens/headroom/gauge

### Tier 3 (Linter, Rubric, Chunking, Versioning)

- Linter tests: known ambiguous prompts → expected warnings
- Rubric validation: score sample responses, check inter-rater reliability
- Chunking examples: large ERDs → semantically split chunks

### Tier 4 (Auto-Summarize, KPI, Replay, Stress Tests)

- Utility validation: defer until adoption signals warrant investment

## 12. Rollout & Ops

- **Phase 1**: Ship gauge as `.cursor/rules/context-efficiency.mdc` + docs snippets/playbook
- **Phase 2**: Release CLI tools (token estimator, headroom calculator, unified `chat-analyze`)
- **Phase 3**: Add linter, rubric, chunking, versioning as adoption grows
- **Phase 4**: Validate utility of auto-summarize, KPI dashboard, replay harness before committing

## 13. Success Metrics

- **Qualitative**: Reduced clarification loops; fewer user-reported "bloated context" issues
- **Quantitative**: Gauge score distribution shifts toward "lean" (4-5/5) over time
- **Tooling**: CLI used in ≥3 chat retrospectives; token estimates within ±10% of user-observed behavior
- **Adoption**: Gauge integrated into assistant status updates; docs/playbook referenced in ≥5 incidents

## 14. References

- Cursor models documentation — [Cursor models docs](https://cursor.com/docs/models)
- Discovery notes: [discovery.md](./discovery.md)

## 15. Context Efficiency Gauge (Specification)

### Purpose

Provide a lightweight, text-only gauge and decision aid that communicates context efficiency at-a-glance and recommends when to start a new chat. This complements quantitative headroom tools with qualitative, zero-dependency heuristics.

### Scoring Rubric (1-5 scale)

| Score | Label   | Characteristics                                                                 |
| ----- | ------- | ------------------------------------------------------------------------------- |
| 5     | lean    | Narrow scope, 0-2 rules, 0-1 clarification loops, no reported issues            |
| 4     | ok      | Focused scope, 3-5 rules, 1-2 clarification loops, minor issues                 |
| 3     | ok      | Moderate scope, 6-8 rules, 2-3 clarification loops, some latency/quality notes  |
| 2     | bloated | Vague scope, 9-12 rules, 4+ clarification loops, multiple issues                |
| 1     | bloated | Unclear scope, 13+ rules, 5+ clarification loops, severe latency/quality issues |

### Recommendation Logic

- **Score 4-5**: Continue in current chat
- **Score 3 + ≥2 signals true**: Suggest new chat or summarization
- **Score 1-2**: Strongly recommend new chat

### Output Formats

#### Gauge Line

```text
Context Efficiency Gauge: 4/5 (lean) — narrow scope, minimal rules
```

#### ASCII Dashboard

```text
┌───────────────────────────────┐
│ CONTEXT EFFICIENCY — DASHBOARD │
├───────────────────────────────┤
│ Gauge: [####-] 4/5 (lean)     │
│ Scope: narrow                 │
│ Rules: 3                      │
│ Loops: 1                      │
│ Issues: none                  │
└───────────────────────────────┘
```

#### ASCII Decision Flow

```text
┌───────────────────────────────────────────────┐
│ SHOULD I START A NEW CHAT?                    │
├───────────────────────────────────────────────┤
│ 1) Is the task scope narrow and concrete?     │
│    - No → New chat (seed exact file + change) │
│    - Yes → 2) ≥2 clarification loops?         │
│             - Yes → New chat                  │
│             - No → 3) Broad searches/many     │
│                    rules attached?            │
│                    - Yes → New chat           │
│                    - No → 4) Latency spikes?  │
│                           - Yes → New chat    │
│                           - No → Stay here    │
└───────────────────────────────────────────────┘
```

### Integration Points

- **Assistant status updates**: Include gauge line when score ≤3 or ≥2 signals true
- **CLI output**: Emit gauge dashboard when analyzing transcripts
- **Rule attachment**: Create `.cursor/rules/context-efficiency.mdc` with this specification

### Notes

- Keep formatting text-only and portable; no external tooling required.
- Combine with quantitative headroom (when available) for comprehensive assessment.
- Defer to user consent before suggesting new chat or summarization.
