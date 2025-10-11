## Relevant Files

- `docs/projects/chat-performance-and-quality-tools/erd.md`

## Tasks

- [ ] 1.0 Implement headroom calculator (priority: high)
  - [ ] 1.1 Define inputs and outputs; add unit tests
  - [ ] 1.2 Support percent-based safety buffer and absolute override
- [ ] 2.0 Token estimation utility (priority: high)
  - [ ] 2.1 Add tokenizer adapter (e.g., tiktoken-compatible)
  - [ ] 2.2 CLI/script example for local estimates
- [ ] 3.0 Provider usage fields ingestion (priority: medium)
  - [ ] 3.1 Parse prompt/completion/total tokens when provided
  - [ ] 3.2 Prefer exact counts over estimates when available
- [ ] 4.0 Documentation (priority: medium)
  - [ ] 4.1 Examples for common models and recommended buffers
  - [ ] 4.2 Troubleshooting differences vs provider counts

## Gauge (Presentation Layer)

- [ ] 5.0 Add Context Efficiency Gauge guide and examples (priority: medium)
  - [ ] 5.1 Document gauge line format and ASCII banners
  - [ ] 5.2 Add decision-flow rule (≥2 signals → new chat)
- [ ] 6.0 Optional: ASCII formatter output from CLI (priority: low)
  - [ ] 6.1 Map quantitative headroom + qualitative signals to 1–5 score
  - [ ] 6.2 Emit gauge line/banner in CLI demo
