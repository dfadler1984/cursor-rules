## Relevant Files

- `docs/projects/chat-performance-and-quality-tools/erd.md`

## Status

- **Tier 1: COMPLETE** — Context Efficiency Gauge + comprehensive guides library (7 guides) shipped
- **Tier 2: COMPLETE** — Token estimator, headroom calculator, unified CLI tool (`chat-analyze`) shipped
- **Tier 3: COMPLETE** — Quality rubric, chunking strategy, prompt versioning documented
- **Tier 4: DOCUMENTED** — Auto-summarize, KPI dashboard, replay harness, stress tests documented; complex automation deferred
- **Integration:** Guides integrated into existing rules; CLI tools portable in `.cursor/scripts/chat-performance/`
- **Enhancement:** Model configs refactored to JSON with sync/validation script (`model-configs-sync.sh`)
- **Deliverables Promoted:** 7 guides moved to permanent location `.cursor/docs/guides/chat-performance/` with symlink at `docs/guides/chat-performance/` for discoverability
- **Portability:** All Cursor content under `.cursor/` namespace; guides and CLI tools will survive archival
- **Outcome:** All core functionality delivered; 13 models supported; manual workflows documented; maintenance automated; reusable guides preserved in portable structure

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

- [x] 2.1 Create "Tighten your prompt" patterns
  - [x] 2.1.1 Pattern: specify target files/components
  - [x] 2.1.2 Pattern: narrow scope to single concrete change
  - [x] 2.1.3 Pattern: add success criteria and constraints
  - [x] 2.1.4 Add before/after examples
- [x] 2.2 Create "Split task" templates
  - [x] 2.2.1 Template: minimal first slice + follow-up list
  - [x] 2.2.2 Template: end-to-end thin slice (vs layer-by-layer)
  - [x] 2.2.3 Add decision criteria (when to split)
- [x] 2.3 Create "Summarize-to-continue" workflow
  - [x] 2.3.1 Document when to summarize (headroom/gauge thresholds)
  - [x] 2.3.2 Template: one-paragraph recap format
  - [x] 2.3.3 Workflow: consent → summarize → start new chat with recap
- [x] 2.4 Create incident playbook
  - [x] 2.4.1 Failure mode: vague scope → corrective: specify files/change
  - [x] 2.4.2 Failure mode: clarification loops → corrective: narrow scope or new chat
  - [x] 2.4.3 Failure mode: latency spikes → corrective: reduce rules, focus fewer files
  - [x] 2.4.4 Failure mode: response seems cut off → corrective: check token estimate, summarize
- [x] 2.5 Organize documentation structure
  - [x] 2.5.1 Create `guides/` subdirectory in project (4 guides + index)
  - [x] 2.5.2 Index: recipes, playbook, gauge guide (guides/README.md)
  - [x] 2.5.3 Cross-reference from guide files to ERD, discovery, and each other

---

## Tier 2: Ship Soon (Priority: Medium)

### 3.0 Local Token Estimator

- [x] 3.1 Research and select tokenizer library
  - [x] 3.1.1 Selected js-tiktoken (Node.js) for portability
  - [x] 3.1.2 Tested accuracy with getEncoding('cl100k_base')
  - [x] 3.1.3 Documented fallback for unavailable tokenizer
- [x] 3.2 Implement token estimator module
  - [x] 3.2.1 Function: `estimateTokens(text, { model }) -> { tokens, method, encoding }`
  - [x] 3.2.2 Support 12 models: GPT-3.5-Turbo, GPT-4 (base/32K/turbo/o), o1 (preview/mini), Claude 3 (haiku/sonnet/opus), Claude 3.5 (sonnet/haiku)
  - [x] 3.2.3 Fallback: char-based estimate (tokens ≈ chars / 4) when tokenizer unavailable
- [x] 3.3 Create CLI wrapper
  - [x] 3.3.1 Script: `token-estimate.sh` with file/stdin support
  - [x] 3.3.2 Output: text and JSON formats with --format flag
  - [x] 3.3.3 Help text, usage examples, model selection
- [x] 3.4 Unit tests
  - [x] 3.4.1 10 tests covering basic functionality, edge cases, consistency
  - [x] 3.4.2 Test fallback handling and error cases
  - [x] 3.4.3 Test model ID validation and config retrieval

### 4.0 Headroom Calculator

- [x] 4.1 Document known model context limits
  - [x] 4.1.1 Integrated with token estimator MODEL_CONFIGS
  - [x] 4.1.2 Models: GPT-4 (8K/32K/128K), Claude 3 Opus/3.5 Sonnet (200K)
  - [x] 4.1.3 Documented in token-estimator.js with maxContext/maxOutput
- [x] 4.2 Implement headroom calculation module
  - [x] 4.2.1 Function: `computeHeadroom({ estimatedTokens, model, plannedCompletion, bufferPct })`
  - [x] 4.2.2 Return: `{ headroom, headroomPct, status, recommendation, breakdown, model }`
  - [x] 4.2.3 Status logic: ok (>20%), warning (10-20%), critical (<10%)
- [x] 4.3 Add recommendation text
  - [x] 4.3.1 OK: "Headroom sufficient; continue"
  - [x] 4.3.2 Warning: "Approaching limit; consider summarizing or narrowing scope"
  - [x] 4.3.3 Critical: "Low headroom; recommend starting new chat"
- [x] 4.4 Unit tests
  - [x] 4.4.1 13 tests covering all status levels, edge cases, formatting
  - [x] 4.4.2 Test status thresholds with precise boundary calculations
  - [x] 4.4.3 Test buffer variations (5%, 10%, 15%) and breakdown accuracy

### 5.0 Unified CLI Tool

- [x] 5.1 Design CLI architecture
  - [x] 5.1.1 Command: `chat-analyze [FILE] [--model <id>] [--buffer <pct>] [--completion <N>]`
  - [x] 5.1.2 Integrated: token estimator + headroom calculator (gauge scorer deferred to Tier 3)
  - [x] 5.1.3 Output format: JSON and human-readable text with breakdown
- [x] 5.2 Implement CLI entry point
  - [x] 5.2.1 Parse arguments: file path, model, buffer, completion, format
  - [x] 5.2.2 Read from file or stdin (plain text)
  - [x] 5.2.3 Orchestrate: estimate tokens → compute headroom → format output
- [x] 5.3 Implement output formatters
  - [x] 5.3.1 JSON output: `{ tokens: {...}, headroom: {...} }`
  - [x] 5.3.2 Text output: formatted summary with ASCII header + breakdown
  - [x] 5.3.3 Clean text format without color (portable)
- [x] 5.4 Add help and documentation
  - [x] 5.4.1 Help text with usage, options, examples
  - [x] 5.4.2 Support stdin, file input, and multiple models
  - [x] 5.4.3 Error handling for missing dependencies and invalid files
- [x] 5.5 Smoke tests
  - [x] 5.5.1 Tested with short/medium text samples
  - [x] 5.5.2 Tested both JSON and text output formats
  - [x] 5.5.3 Tested different models and options

---

## Tier 3: Ship Later (Priority: Low)

### 6.0 Prompts Linter

- [x] 6.1 Documented approach (implementation deferred)
  - [x] 6.1.1 Rules defined in prompt-tightening-patterns.md (5-point checklist covers linting)
  - [x] 6.1.2 Multi-intent detection: covered in scope-check.mdc (split/clarify workflow)
  - [x] 6.1.3 Vague scope detection: covered in scope-check.mdc quick checklist
  - [x] 6.1.4 Missing success criteria: covered in prompt-tightening checklist
- [x] 6.2 Manual linting workflow (in place of automated tool)
  - [x] 6.2.1 Use prompt-tightening 5-point checklist before sending
  - [x] 6.2.2 Use scope-check quick checklist for vague goal detection
  - [x] 6.2.3 Warnings implicit in checklist items (target, change, success, scope, commands)
- [-] 6.3 CLI integration (deferred to future)
  - [-] Would require NLP/pattern matching for automated linting
  - [-] Current manual checklists provide equivalent value
- [-] 6.4 Automated tests (deferred with implementation)

### 7.0 Quality Rubric

- [x] 7.1 Define scoring dimensions
  - [x] 7.1.1 Dimension: factuality (claims verified, sources cited, uncertainties qualified)
  - [x] 7.1.2 Dimension: specificity (exact paths/names vs vague generalities)
  - [x] 7.1.3 Dimension: actionability (executable steps vs deferral)
  - [x] 7.1.4 1-5 scale definitions per dimension with clear criteria
- [x] 7.2 Create rubric checklist
  - [x] 7.2.1 Complete checklist: dimension scores + notes + overall assessment
  - [x] 7.2.2 3 calibration examples (high/medium/low quality) with scores
  - [x] 7.2.3 Self-review, peer-review, and trend analysis workflows documented
- [x] 7.3 Manual scoring (CLI integration deferred)
  - [x] 7.3.1 CSV logging format provided for trend analysis
  - [x] 7.3.2 Integration guidance with gauge and incident playbook
  - [x] 7.3.3 Calibration guidelines for inter-rater reliability

### 8.0 Chunking Strategy

- [x] 8.1 Document semantic splitting guidance
  - [x] 8.1.1 When to chunk: >1000 tokens or >10 sections with decision flow
  - [x] 8.1.2 How to split: logical boundaries, functional boundaries, dependencies together
  - [x] 8.1.3 Per-chunk template: title + TL;DR + Previous/Next links
- [x] 8.2 Create chunking examples
  - [x] 8.2.1 Documentation by sections (ERD/spec) with context links
  - [x] 8.2.2 Code by module/class with import boundaries
  - [x] 8.2.3 Multiple patterns: ERD, code files, implementation guides
- [x] 8.3 Integration guidance (in place of CLI tool)
  - [x] 8.3.1 Use token-estimate.sh to check chunk sizes
  - [x] 8.3.2 Use chat-analyze.sh to verify combined chunks
  - [x] 8.3.3 Token budgets per chunk type documented

### 9.0 Prompt Versioning

- [x] 9.1 Define versioning format
  - [x] 9.1.1 ID format: `{slug}-{YYYYMMDD}-{counter}` (e.g., auth-impl-20251022-01)
  - [x] 9.1.2 Metadata: timestamp, model, settings, context (files, rules, tokens), outcome
  - [x] 9.1.3 Storage: Markdown (human-readable) and JSON (structured) templates
- [x] 9.2 Document logging workflow
  - [x] 9.2.1 Manual logging templates (Markdown + JSON)
  - [x] 9.2.2 Comparison workflows (model, temperature, iteration tracking)
  - [x] 9.2.3 Retrieval examples (grep, jq) and replay procedure
- [x] 9.3 Integration and best practices
  - [x] 9.3.1 Integration with token-estimate.sh for context logging
  - [x] 9.3.2 Analysis queries (most successful model, quality by temperature)
  - [x] 9.3.3 Best practices: log immediately, include context, rate consistently

---

## Tier 4: Low Priority / Future Vetting

### 10.0 Auto-Summarize Cadence

- [x] 10.1 Documented triggers (implementation deferred)
  - [x] 10.1.1 Triggers defined in summarize-workflow.md (gauge ≤2/5, headroom <20%, ≥4 loops)
  - [x] 10.1.2 Integrated with Context Efficiency Gauge in assistant-behavior.mdc
  - [x] 10.1.3 User-reported issues covered in incident-playbook.md (Incident 4)
- [x] 10.2 Manual workflow (in place of automated prompts)
  - [x] 10.2.1 summarize-workflow.md provides 4-step manual workflow
  - [x] 10.2.2 Gauge/headroom integration shows when to summarize
  - [x] 10.2.3 Consent-first by design (manual initiation)
- [-] 10.3 Automated implementation (deferred)
  - [-] Would require chat platform integration for auto-prompts
  - [-] Current manual workflow provides equivalent value with user control

### 11.0 KPI Dashboard

- [x] 11.1 Documented KPIs (implementation deferred)
  - [x] 11.1.1 Metrics defined: tokens, clarification loops, rules attached, issues
  - [x] 11.1.2 CSV logging format provided in quality-rubric.md and prompt-versioning.md
  - [x] 11.1.3 Analysis queries documented (avg by temperature, success by model)
- [-] 11.2 Manual logging (templates provided, automation deferred)
  - [x] CSV template format documented
  - [x] Basic analysis queries (awk, jq) provided
  - [-] CLI automation deferred (manual logging sufficient for now)
- [-] 11.3 Dashboard visualization (deferred)
  - [-] Would require visualization library or web UI
  - [-] CSV export + spreadsheet tools provide equivalent value
- [-] 11.4 Validation (deferred pending adoption signals)

### 12.0 Replay Harness

- [x] 12.1 Documented transcript format (implementation deferred)
  - [x] 12.1.1 Transcript format: plain text (pipe to chat-analyze.sh)
  - [x] 12.1.2 Metadata logging: covered in prompt-versioning.md
  - [x] 12.1.3 Manual save/export process documented
- [-] 12.2 Replay implementation (deferred)
  - [x] Token estimation available via chat-analyze.sh for saved transcripts
  - [x] Manual replay: feed transcript to chat-analyze.sh
  - [-] Automated turn-by-turn replay deferred
- [-] 12.3 Comparison tool (deferred)
  - [-] Manual comparison: run chat-analyze.sh on multiple transcripts
  - [-] Automated side-by-side comparison deferred
- [-] 12.4 Validation (deferred pending adoption signals)

### 13.0 Synthetic Stress Tests

- [x] 13.1 Unit tests cover core validation (implementation deferred)
  - [x] 13.1.1 token-estimator.test.js: 10 tests (empty, long, consistency)
  - [x] 13.1.2 headroom-calculator.test.js: 13 tests (boundaries, edge cases)
  - [x] 13.1.3 Manual testing with small/medium text samples completed
- [-] 13.2 Large-scale stress testing (deferred)
  - [x] Token estimator accuracy validated with tiktoken (cl100k_base encoding)
  - [x] Fallback mechanism tested (char-based estimation)
  - [-] Synthetic 50K/100K token transcripts deferred
- [-] 13.3 Gauge scoring validation (deferred)
  - [x] Calibration examples provided in quality-rubric.md
  - [-] Automated scoring consistency tests deferred
- [-] 13.4 Comprehensive stress test suite (deferred pending adoption signals)

---

## Removed / Blocked (Requires Provider API Access)


- Entropy monitor (needs logprobs)
- Adaptive buffer policy (needs finish_reason, live usage)
- Headroom HUD (needs real-time usage fields)
- Model fallback policy (can document manually, not a tool)
- Safety triage (needs moderation flags)
- Provider-agnostic schema (needs raw API responses)
- Knowledge distillation (too complex without full context)
- Cost/latency budgeter (latency input unreliable)
- Tool-call validator (insufficient value without API)

