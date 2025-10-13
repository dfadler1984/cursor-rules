## Relevant Files

- `docs/projects/chat-performance-and-quality-tools/erd.md`
- `docs/projects/chat-performance-and-quality-tools/discovery.md`

## Notes

- **Constraint**: No access to provider API response fields (usage, finish_reason, logprobs, etc.)
- All tooling relies on local estimation and qualitative heuristics
- Features organized by tier based on value/effort trade-offs

---

## Tier 1: Ship Now (Priority: High)

### 1.0 Context Efficiency Gauge

- [x] 1.1 Define scoring rubric implementation
  - [x] 1.1.1 Map heuristic inputs → 1-5 score (scope, rules, loops, issues)
  - [x] 1.1.2 Define recommendation logic (score + signals → stay/new chat)
  - [x] 1.1.3 Document scoring examples for calibration
- [x] 1.2 Create `.cursor/rules/context-efficiency.mdc`
  - [x] 1.2.1 Include § 15 specification (rubric, outputs, integration)
  - [x] 1.2.2 Add trigger conditions (when to surface gauge)
  - [x] 1.2.3 Define consent-first prompt for "start new chat" suggestion
- [x] 1.3 Implement ASCII output generators
  - [x] 1.3.1 Gauge line formatter: `Context Efficiency Gauge: X/5 (label) — rationale`
  - [x] 1.3.2 Dashboard banner (table with scope/rules/loops/issues)
  - [x] 1.3.3 Decision-flow banner (flowchart text)
- [x] 1.4 Integrate with assistant behavior
  - [x] 1.4.1 Hook into `assistant-behavior.mdc` status updates
  - [x] 1.4.2 Surface gauge when score ≤3 or ≥2 signals true
  - [x] 1.4.3 Test integration in sample chat scenarios

### 2.0 Docs, Recipes, and Playbook

- [ ] 2.1 Create "Tighten your prompt" patterns
  - [ ] 2.1.1 Pattern: specify target files/components
  - [ ] 2.1.2 Pattern: narrow scope to single concrete change
  - [ ] 2.1.3 Pattern: add success criteria and constraints
  - [ ] 2.1.4 Add before/after examples
- [ ] 2.2 Create "Split task" templates
  - [ ] 2.2.1 Template: minimal first slice + follow-up list
  - [ ] 2.2.2 Template: end-to-end thin slice (vs layer-by-layer)
  - [ ] 2.2.3 Add decision criteria (when to split)
- [ ] 2.3 Create "Summarize-to-continue" workflow
  - [ ] 2.3.1 Document when to summarize (headroom/gauge thresholds)
  - [ ] 2.3.2 Template: one-paragraph recap format
  - [ ] 2.3.3 Workflow: consent → summarize → start new chat with recap
- [ ] 2.4 Create incident playbook
  - [ ] 2.4.1 Failure mode: vague scope → corrective: specify files/change
  - [ ] 2.4.2 Failure mode: clarification loops → corrective: narrow scope or new chat
  - [ ] 2.4.3 Failure mode: latency spikes → corrective: reduce rules, focus fewer files
  - [ ] 2.4.4 Failure mode: response seems cut off → corrective: check token estimate, summarize
- [ ] 2.5 Organize documentation structure
  - [ ] 2.5.1 Create `docs/chat-quality/` or add to existing docs area
  - [ ] 2.5.2 Index: recipes, playbook, gauge guide
  - [ ] 2.5.3 Cross-reference from relevant rules (scope-check, assistant-behavior)

---

## Tier 2: Ship Soon (Priority: Medium)

### 3.0 Local Token Estimator

- [ ] 3.1 Research and select tokenizer library
  - [ ] 3.1.1 Evaluate: tiktoken (Python), js-tiktoken (Node.js)
  - [ ] 3.1.2 Test accuracy against known samples (GPT-4, Claude)
  - [ ] 3.1.3 Document accuracy variance (±5-10% expected)
- [ ] 3.2 Implement token estimator module
  - [ ] 3.2.1 Function: `estimateTokens(text, { model }) -> { tokens, method }`
  - [ ] 3.2.2 Support models: GPT-4, Claude 3.5 Sonnet, Claude 3 Opus
  - [ ] 3.2.3 Fallback: char-based estimate (tokens ≈ chars / 4) when tokenizer unavailable
- [ ] 3.3 Create CLI wrapper
  - [ ] 3.3.1 Script: `token-estimate <file> --model <model-id>`
  - [ ] 3.3.2 Output: estimated tokens, method used, model
  - [ ] 3.3.3 Add help text and usage examples
- [ ] 3.4 Unit tests
  - [ ] 3.4.1 Test fixed text samples with known counts (from tokenizer docs)
  - [ ] 3.4.2 Test fallback accuracy on sample transcripts
  - [ ] 3.4.3 Test model ID validation

### 4.0 Headroom Calculator

- [ ] 4.1 Document known model context limits
  - [ ] 4.1.1 Source from [Cursor models docs](https://cursor.com/docs/models)
  - [ ] 4.1.2 Table: model ID → max_context, max_output
  - [ ] 4.1.3 Add sync date and update cadence note
- [ ] 4.2 Implement headroom calculation module
  - [ ] 4.2.1 Function: `computeHeadroom({ maxContext, estimatedTokens, plannedCompletion, bufferPct })`
  - [ ] 4.2.2 Return: `{ headroom, status, recommendation }`
  - [ ] 4.2.3 Status logic: ok (>20%), warning (10-20%), critical (<10%)
- [ ] 4.3 Add recommendation text
  - [ ] 4.3.1 OK: "Headroom sufficient; continue"
  - [ ] 4.3.2 Warning: "Approaching limit; consider summarizing or narrowing scope"
  - [ ] 4.3.3 Critical: "Low headroom; recommend starting new chat"
- [ ] 4.4 Unit tests
  - [ ] 4.4.1 Test headroom calculation on sample scenarios
  - [ ] 4.4.2 Test status thresholds (boundary cases)
  - [ ] 4.4.3 Test buffer percentage variations

### 5.0 Unified CLI Tool

- [ ] 5.1 Design CLI architecture
  - [ ] 5.1.1 Command: `chat-analyze <transcript.txt> [--model <id>] [--buffer <pct>]`
  - [ ] 5.1.2 Integrate: token estimator + headroom calculator + gauge scorer
  - [ ] 5.1.3 Output format: JSON and human-readable text
- [ ] 5.2 Implement CLI entry point
  - [ ] 5.2.1 Parse arguments (file path, model, buffer)
  - [ ] 5.2.2 Read transcript file (plain text)
  - [ ] 5.2.3 Orchestrate: estimate tokens → compute headroom → score gauge
- [ ] 5.3 Implement output formatters
  - [ ] 5.3.1 JSON output: tokens, headroom, status, gauge, warnings
  - [ ] 5.3.2 Text output: formatted summary + ASCII gauge dashboard
  - [ ] 5.3.3 Color/emoji support (optional, off by default)
- [ ] 5.4 Add help and documentation
  - [ ] 5.4.1 Help text: usage, options, examples
  - [ ] 5.4.2 Document transcript format expectations
  - [ ] 5.4.3 Add troubleshooting section (e.g., tokenizer not found)
- [ ] 5.5 Smoke tests
  - [ ] 5.5.1 Test with sample transcripts (short, medium, long)
  - [ ] 5.5.2 Test output formats (JSON, text)
  - [ ] 5.5.3 Test error handling (file not found, invalid model)

---

## Tier 3: Ship Later (Priority: Low)

### 6.0 Prompts Linter

- [ ] 6.1 Define linting rules
  - [ ] 6.1.1 Rule: detect missing target files/components
  - [ ] 6.1.2 Rule: detect multi-intent prompts (and/or split)
  - [ ] 6.1.3 Rule: detect vague scope (no concrete change specified)
  - [ ] 6.1.4 Rule: detect missing success criteria
- [ ] 6.2 Implement linter module
  - [ ] 6.2.1 Function: `lintPrompt(text) -> warnings[]`
  - [ ] 6.2.2 Return: warning type, message, suggested fix
  - [ ] 6.2.3 Support rule enable/disable flags
- [ ] 6.3 Integrate with CLI
  - [ ] 6.3.1 Add `--lint` flag to `chat-analyze`
  - [ ] 6.3.2 Output: lint warnings before token/headroom analysis
  - [ ] 6.3.3 Add lint-only mode (skip estimation)
- [ ] 6.4 Unit tests
  - [ ] 6.4.1 Test known ambiguous prompts → expected warnings
  - [ ] 6.4.2 Test clear prompts → no warnings
  - [ ] 6.4.3 Test suggested fixes accuracy

### 7.0 Quality Rubric

- [ ] 7.1 Define scoring dimensions
  - [ ] 7.1.1 Dimension: factuality (claims match sources, no hallucinations)
  - [ ] 7.1.2 Dimension: specificity (concrete vs vague; actionable vs platitudes)
  - [ ] 7.1.3 Dimension: actionability (clear next steps, no deferral)
  - [ ] 7.1.4 Add 1-5 scale definitions per dimension
- [ ] 7.2 Create rubric checklist
  - [ ] 7.2.1 Checklist format: dimension → 1-5 score + notes
  - [ ] 7.2.2 Add example scored responses (calibration set)
  - [ ] 7.2.3 Document self-review and peer-review processes
- [ ] 7.3 Optional: CLI integration
  - [ ] 7.3.1 Add `--rubric` flag to score a response
  - [ ] 7.3.2 Prompt for manual scores per dimension
  - [ ] 7.3.3 Log scores to CSV for trend analysis

### 8.0 Chunking Strategy

- [ ] 8.1 Document semantic splitting guidance
  - [ ] 8.1.1 When to chunk: artifact > X tokens or > Y sections
  - [ ] 8.1.2 How to split: by logical sections, keep dependencies together
  - [ ] 8.1.3 Add per-chunk TL;DR template (1-2 sentences)
- [ ] 8.2 Create chunking examples
  - [ ] 8.2.1 Example: large ERD → split by sections (Intro, Goals, Requirements, etc.)
  - [ ] 8.2.2 Example: long spec → split by features or user stories
  - [ ] 8.2.3 Example: code file → split by class/function boundaries
- [ ] 8.3 Optional: CLI chunking tool
  - [ ] 8.3.1 Command: `chunk-artifact <file> --max-tokens <N>`
  - [ ] 8.3.2 Output: multiple files with semantic titles + TL;DR headers
  - [ ] 8.3.3 Add markdown/code-aware splitting logic

### 9.0 Prompt Versioning

- [ ] 9.1 Define versioning format
  - [ ] 9.1.1 ID format: short hash or human-readable slug
  - [ ] 9.1.2 Metadata: timestamp, model, settings (temperature, etc.), context summary
  - [ ] 9.1.3 Storage: JSON log or markdown index
- [ ] 9.2 Implement prompt logger
  - [ ] 9.2.1 Function: `logPrompt({ id, timestamp, model, settings, prompt })`
  - [ ] 9.2.2 Append to log file or database
  - [ ] 9.2.3 Add retrieval: `getPrompt(id) -> prompt + metadata`
- [ ] 9.3 Optional: CLI integration
  - [ ] 9.3.1 Command: `prompt-log --id <slug> --model <id> <file>`
  - [ ] 9.3.2 Command: `prompt-recall <id>` → print prompt + metadata
  - [ ] 9.3.3 Add diff tool: compare two prompt IDs

---

## Tier 4: Low Priority / Future Vetting

### 10.0 Auto-Summarize Cadence

- [ ] 10.1 Define trigger conditions
  - [ ] 10.1.1 Trigger: estimated tokens > 80% of max context
  - [ ] 10.1.2 Trigger: gauge score ≤2/5
  - [ ] 10.1.3 Trigger: user reports "response seems cut off"
- [ ] 10.2 Implement summarization prompt generator
  - [ ] 10.2.1 Template: "Shall I summarize the conversation so far and start fresh?"
  - [ ] 10.2.2 Include current gauge score and headroom in prompt
  - [ ] 10.2.3 Defer to user consent (no auto-action)
- [ ] 10.3 Validate utility
  - [ ] 10.3.1 Test in ≥3 chat scenarios where trigger fires
  - [ ] 10.3.2 Collect user feedback (helpful vs noisy)
  - [ ] 10.3.3 Decide: promote to Tier 3, refine, or archive

### 11.0 KPI Dashboard

- [ ] 11.1 Define trackable KPIs (no provider API)
  - [ ] 11.1.1 Metric: avg estimated tokens per chat
  - [ ] 11.1.2 Metric: clarification loop count
  - [ ] 11.1.3 Metric: rules attached count per chat
  - [ ] 11.1.4 Metric: user-reported issues (latency, quality, truncation)
- [ ] 11.2 Implement manual logging system
  - [ ] 11.2.1 Log format: CSV or JSON (timestamp, chat_id, metrics)
  - [ ] 11.2.2 Entry point: `kpi-log --chat <id> --tokens <N> --loops <N> --rules <N> --issues "<notes>"`
  - [ ] 11.2.3 Aggregation script: compute averages, trends, distributions
- [ ] 11.3 Create dashboard output
  - [ ] 11.3.1 CLI: `kpi-dashboard` → summary table (avg, min, max per metric)
  - [ ] 11.3.2 Add time-series view (e.g., by week or month)
  - [ ] 11.3.3 Optional: export to Markdown or HTML report
- [ ] 11.4 Validate utility
  - [ ] 11.4.1 Collect ≥10 chat sessions of data
  - [ ] 11.4.2 Analyze trends (gauge scores improving? loops decreasing?)
  - [ ] 11.4.3 Decide: promote to Tier 3, refine, or archive

### 12.0 Replay Harness

- [ ] 12.1 Define transcript format
  - [ ] 12.1.1 Plain text or structured JSON (user/assistant turns)
  - [ ] 12.1.2 Metadata: model, timestamp, rules attached
  - [ ] 12.1.3 Document manual export/save process
- [ ] 12.2 Implement replay scorer
  - [ ] 12.2.1 Function: `replayChat(transcript) -> { tokens, headroom, gauge, warnings }`
  - [ ] 12.2.2 Re-estimate tokens for each turn
  - [ ] 12.2.3 Re-score gauge at each turn or end-of-chat
- [ ] 12.3 Add comparison tool
  - [ ] 12.3.1 Command: `replay-compare <transcript1> <transcript2>`
  - [ ] 12.3.2 Output: side-by-side metrics (tokens, gauge, loops)
  - [ ] 12.3.3 Highlight: which chat was more efficient
- [ ] 12.4 Validate utility
  - [ ] 12.4.1 Test on ≥5 saved transcripts
  - [ ] 12.4.2 Assess: does comparison reveal actionable insights?
  - [ ] 12.4.3 Decide: promote to Tier 3, refine, or archive

### 13.0 Synthetic Stress Tests

- [ ] 13.1 Generate test transcripts
  - [ ] 13.1.1 Small (1K tokens), medium (50K tokens), large (100K tokens)
  - [ ] 13.1.2 Noisy: many clarification loops, vague scope, high rules count
  - [ ] 13.1.3 Varied models: GPT-4, Claude 3.5 Sonnet
- [ ] 13.2 Validate token estimator
  - [ ] 13.2.1 Compare estimated tokens to known counts (from tokenizer docs)
  - [ ] 13.2.2 Target: ±10% accuracy or better
  - [ ] 13.2.3 Document discrepancies and known limitations
- [ ] 13.3 Validate gauge scoring
  - [ ] 13.3.1 Score noisy transcripts → expect low scores (1-2/5)
  - [ ] 13.3.2 Score clean transcripts → expect high scores (4-5/5)
  - [ ] 13.3.3 Check consistency: same transcript → same score
- [ ] 13.4 Document results
  - [ ] 13.4.1 Summary: accuracy, edge cases, failure modes
  - [ ] 13.4.2 Recommendations: calibration adjustments if needed
  - [ ] 13.4.3 Add to test suite for regression testing

---

## Removed / Blocked (Requires Provider API Access)

The following features from discovery.md are not feasible without provider API response fields:

- Entropy monitor (needs logprobs)
- Adaptive buffer policy (needs finish_reason, live usage)
- Headroom HUD (needs real-time usage fields)
- Model fallback policy (can document manually, not a tool)
- Safety triage (needs moderation flags)
- Provider-agnostic schema (needs raw API responses)
- Knowledge distillation (too complex without full context)
- Cost/latency budgeter (latency input unreliable)
- Tool-call validator (insufficient value without API)

These are documented in discovery.md for future reference if provider API access becomes available.
