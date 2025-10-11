# Discovery — Chat Performance and Quality Tools

### Context & Questions

- Can we determine the exact model and max context? Model label is available in-session; authoritative max context per model comes from documentation.
- Can we introspect live token usage? Not directly; providers expose usage fields (prompt/completion/total) via API responses.
- Can we estimate tokens locally? Yes, with a tokenizer matching the model; estimates may differ from provider counts due to hidden/system prompts and tool metadata.

### Findings

- Headroom concept: remaining token capacity before reaching the model’s context window; practical to avoid truncation/eviction.
- Headroom formula: `headroom = max_context − (prompt_tokens + planned_completion + buffer)`.
- Buffer selection: 5–15% recommended based on risk tolerance and variability in hidden/overhead tokens.
- Exact counts vs estimates:
  - Exact: use provider API usage fields when available/shared.
  - Estimate: use tokenizer for visible text/messages; expect small variance.
- Documentation source: per-model context window and provider-stated max output length are referenced from the Cursor models documentation — [Cursor models docs](https://cursor.com/docs/models).

### Example Calculation

- Assume max_context = 128,000
- prompt_tokens = 32,500
- planned_completion = 2,000
- buffer = 10% of max (12,800)
- headroom = 128,000 − (32,500 + 2,000 + 12,800) = 80,700

### Open Questions

- Which specific models should be first-class (IDs and encodings)?
- Preferred default buffer percentage?
- Should we expose both CLI and library forms initially?

### Next Steps

- Add a tokenizer adapter and unit tests.
- Document common model limits and example headroom tables.
- Provide a simple script to compute headroom from a pasted transcript.

### Provider API signals to explore (summary)

- Usage & capacity: `model`, `max_output_tokens`, `usage` (`prompt_tokens`, `completion_tokens`, `total_tokens`), and any detailed fields (e.g., cached/reasoning tokens).
- Stopping/truncation: `finish_reason` (e.g., `stop`, `length`, `content_filter`), `stop_sequence`.
- Confidence/uncertainty: `logprobs` / per-token probabilities for entropy metrics (if enabled).
- Safety/moderation: category flags/scores, block reasons/redactions.
- Tool/function calling: `tool_calls` (names, args, token cost), validation errors.
- Reasoning models: reasoning token counts, optional traces.
- Caching/latency: cache hits/reads/writes, request/response IDs, latency metrics.
- Generation controls echo: `temperature`, `top_p`, `top_k`, `frequency_penalty`, `presence_penalty`, `seed`.

### Additional ideas to explore

- **Prompts linter**: static checks for ambiguity, multi-intent, missing constraints; suggest fixes before sending.
- **Adaptive buffer policy**: dynamically adjust safety buffer based on recent `finish_reason`, entropy, and latency.
- **Headroom HUD**: small inline gauge in docs/PRs/chats showing live headroom and risk color.
- **Auto-summarize cadence**: when headroom < threshold, propose a one-paragraph recap and replace older context.
- **Entropy monitor**: use logprobs to flag high-uncertainty outputs; recommend tighter constraints or lower temperature.
- **Prompt versioning**: short IDs for major prompt variants; record model, knobs, and diffs for reproducibility.
- **Replay harness**: feed a saved conversation + settings to compare models/knobs; produce diffs and scores.
- **Quality rubric**: lightweight checklist (factuality, specificity, actionability) with 1–5 scoring per turn.
- **Cost/latency budgeter**: estimate tokens/$ and p95 latency per planned step before executing.
- **Tool-call validator**: schema-check tool arguments and simulate side effects; retry with auto-fixes for minor errors.
- **Safety triage**: map moderation flags to targeted re-prompts or content filters; log minimal redaction footprints.
- **Provider-agnostic schema**: normalize usage/finish_reason/logprobs/tools into one JSON for dashboards.
- **Model fallback policy**: define when to sidegrade/downshift models (e.g., on length stops or slow SLOs).
- **Knowledge distillation**: extract durable insights from long threads into a reusable "context file" for reseeding.
- **Synthetic stress tests**: generate large/noisy transcripts to validate estimators, buffers, and summarizers.
- **Chunking strategy**: split oversized artifacts with semantic titles and per-chunk TL;DR to keep recall crisp.
- **Incident playbook**: quick steps when `finish_reason=length` or moderation trips; include a new chat template.
- **KPI set**: overflow rate, average headroom at send, % length-stops, revision count, reviewer rubric score.
- **CLI UX**: one command that reads a transcript and prints tokens, headroom, risks, and fixes.
- **Docs snippets**: copy‑paste recipes for “tighten prompt,” “split task,” and “summarize-to-continue” patterns.
