# Engineering Requirements Document — Chat Performance and Quality Tools

Mode: Full

## 1. Introduction/Overview

This project defines tools and guidance to maintain high-quality, efficient chats by tracking context usage (token headroom), estimating token counts, and providing practical heuristics to avoid context overflow and response degradation.

## 2. Goals/Objectives

- Provide a simple, reliable headroom estimator for chat sessions.
- Offer a tokenizer-based token estimation utility (script/library) for common models.
- Document per-model context limits with references to official documentation.
- Surface actionable heuristics to keep chats effective as they grow in length.
- Enable ingestion of provider API usage fields when available to report exact counts.

## 3. User Stories

- As a developer, I can quickly estimate remaining context headroom to plan my next message.
- As an author, I can trim or summarize content when nearing the context limit, guided by clear heuristics.
- As a reviewer, I can verify that a conversation stays within safe headroom bounds.

## 4. Functional Requirements

1. Headroom calculation given: model max context, current prompt tokens, planned completion budget, and safety buffer.
2. Token estimation from raw text/messages via a tokenizer matching the model.
3. Optional parsing of provider API usage fields to report exact prompt/completion/total tokens when supplied.
4. Output clear recommendations when headroom is low (e.g., suggest summarization or splitting the task).

## 5. Non-Functional Requirements

- Estimation accuracy within an acceptable bound (target: ±3–5% vs provider counts, where comparable).
- Fast: sub-second estimates for typical message sizes.
- Portable and dependency-light.

## 6. Architecture/Design

- Pure calculation module for headroom and budgeting.
- Tokenization adapter layer (pluggable; e.g., tiktoken-compatible) to avoid provider lock-in.
- Optional inputs path for provider usage fields (when available) to override estimates with exacts.

## 7. Data Model and Storage

- No persistent storage required; ephemeral calculations.

## 8. API/Contracts

- Function: `computeHeadroom({ maxContext, promptTokens, plannedCompletion, bufferPct }) -> { headroom, status }`.
- Function: `estimateTokens(messages, { model }) -> tokens`.
- Function: `deriveFromUsageFields(usage) -> { promptTokens, completionTokens, totalTokens }`.

## 9. Integrations/Dependencies

- Source model context window and provider-stated max output length from the Cursor models documentation — [Cursor models docs](https://cursor.com/docs/models).
- Optional tokenizer dependency for local estimation.

## 9.1 Provider API Signals (for Quality Management)

When available from the provider, incorporate the following signals to maintain high chat quality and actionable feedback:

- Usage & capacity

  - `model`, `max_output_tokens` (response/config echo)
  - `usage`: `prompt_tokens`, `completion_tokens`, `total_tokens`
  - Details (if present): `prompt_tokens_details.cached_tokens`, `completion_tokens_details.reasoning_tokens`

- Stopping/truncation

  - `finish_reason` (e.g., `stop`, `length`, `content_filter`, `tool_calls`)
  - `stop_sequence` (which rule fired)

- Confidence/uncertainty (if enabled)

  - `logprobs` / per‑token probabilities to derive entropy/uncertainty metrics

- Safety/moderation

  - Category flags/scores; block reasons or redaction markers

- Tool/function calling

  - `tool_calls` (names, arguments, token cost); tool validation errors

- Reasoning models (if supported)

  - Reasoning token counts, optional traces; separation of “reasoning” vs “final” tokens

- Caching/latency

  - Cache hits/reads/writes (token deltas), request/response IDs, latency metrics

- Generation controls (echoed back)
  - `temperature`, `top_p`, `top_k`, `frequency_penalty`, `presence_penalty`, `seed`

Usage in this project:

- Prefer exact `usage` counts over estimates to update headroom precisely.
- Trigger alerts/re-prompts when `finish_reason=length` or headroom < threshold.
- Adjust generation knobs in guidance when uncertainty is high.
- React to safety flags with targeted re-prompts or filtered regeneration.
- Log request IDs/model/knobs to reproduce issues; monitor latency and cache signals.

## 10. Edge Cases and Constraints

- Tooling discrepancies between estimated tokens and provider counts.
- Hidden/system prompts and tool metadata not visible to local estimators.
- Model upgrades that change encoding or context limits.

## 11. Testing & Acceptance

- Unit tests for headroom calculation and budgeting logic.
- Token estimator tests using fixed text samples with known counts (per tokenizer).
- Validation against provider usage fields when example payloads are available.

## 12. Rollout & Ops

- Release as a small utility (script/library) and a short guide.
- Document usage examples and recommended safety buffers.

## 13. Success Metrics

- Correct headroom calculation on sample scenarios.
- Estimation within ±3–5% compared to provider counts on test corpora.
- Reduced context-overflow incidents in typical workflows.

## 14. References

- Cursor models documentation — [Cursor models docs](https://cursor.com/docs/models)
- Discovery notes: [discovery.md](./discovery.md)

## 15. Context Efficiency Gauge (Presentation Layer)

Purpose: provide a lightweight, text-only gauge and decision aid that communicates context efficiency at-a-glance and recommends when to start a new chat. This complements the quantitative headroom tools with qualitative, zero-dependency outputs.

Outputs:

- Gauge line (1–5): "Context Efficiency Gauge: X/5 (lean|ok|bloated) — short rationale"
- ASCII dashboard banner (monospace-safe)
- ASCII decision-flow banner (rule-of-thumb: start a new chat when ≥2 signals are true)

Heuristic inputs (qualitative):

- Scope focus and concreteness of the current task
- Number of rules attached / search breadth
- Clarification loops or contradictions in the thread
- Latency spikes/timeouts vs baseline

Examples:

```text
┌───────────────────────────────┐
│ CONTEXT EFFICIENCY — DASHBOARD │
├───────────────────────────────┤
│ Gauge: [####-] 4/5 (lean)     │
└───────────────────────────────┘
```

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

Notes:

- Keep formatting text-only and portable; no external tooling required.
- When the quantitative headroom is low or ≥2 qualitative signals are true, recommend summarization/splitting or starting a new chat.
