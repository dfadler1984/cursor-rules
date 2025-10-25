---
status: planning
owner: repo-maintainers
created: 2025-10-23
lastUpdated: 2025-10-23
---

# Engineering Requirements Document — Rule Introspection (Lite)

Mode: Lite


## 1. Introduction/Overview

Investigate how the assistant can programmatically access and count attached rules to provide accurate Context Efficiency Gauge readings. Currently, the assistant has no API to query Cursor's rule attachment system and must manually track rules from function results, leading to inaccurate or missing gauge data.

**Context**: The Context Efficiency Gauge requires accurate rule counts to assess context health (score ≤3 or ≥2 signals triggers automatic inclusion in status). Without programmatic access, the gauge shows defaults (rules: 0) instead of actual values (rules: 18+), making it unreliable for automated enforcement.

## 2. Goals/Objectives

- Identify programmatic methods to count attached rules (Always Apply + Agent Requested + Project Rules)
- Determine if Cursor provides APIs, metadata, or introspection mechanisms
- Propose solutions ranging from manual tracking to potential API requests
- Enable accurate, automated Context Efficiency Gauge readings

## 3. Functional Requirements

1. **Rule Counting**: Assistant must be able to count total rules attached to current chat
2. **Rule Categorization**: Distinguish between Always Apply, Agent Requested, and Project Rules
3. **Real-time Access**: Rule count available on-demand when user invokes `/gauge` or gauge appears in status
4. **Accuracy**: Count should match what user sees in Cursor UI (18 rules shown in screenshot)

## 4. Acceptance Criteria

- Assistant can accurately report rule count when manually invoked (within ±2 of actual count)
- Context Efficiency Gauge shows actual values instead of defaults
- Solution documented in context-efficiency.mdc with usage examples
- If programmatic API unavailable, manual tracking method specified with accuracy expectations

## 5. Risks/Edge Cases

- **No API available**: Cursor may not expose rule attachment data to assistants
- **Dynamic attachment**: Rules may attach/detach mid-conversation based on file context
- **Hidden rules**: Some rules may be attached but not visible in function results
- **Performance cost**: Introspection may add latency if implemented via additional queries

## 6. Rollout

**Owner**: repo-maintainers  
**Investigation type**: Technical feasibility + solution design  
**Timeline**: 2-4 hours exploration + implementation if feasible  
**Outcome**: Either programmatic solution OR documented manual tracking protocol

---

Owner: repo-maintainers  
Created: 2025-10-23
