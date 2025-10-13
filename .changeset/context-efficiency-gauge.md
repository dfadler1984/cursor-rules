---
"cursor-rules": minor
---

Add Context Efficiency Gauge for chat context health monitoring

Implements task 1.0 from chat-performance-and-quality-tools project:

- New rule: `context-efficiency.mdc` with 1-5 scoring rubric
- New script: `context-efficiency-gauge.sh` (zero-dependency bash)
- Test suite: 22 tests, all passing
- Intent routing: "show gauge" and other natural phrases
- Integration: Automatic display in status updates when score ≤3

Provides qualitative heuristics to assess context health using observable signals (scope clarity, rules count, clarification loops, user issues) without requiring token counts.

