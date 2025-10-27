---
status: archived
---
# Engineering Requirements Document — MCP Synergy (Lite)


## 1. Introduction/Overview

Specify safe, consent-first usage of Model Context Protocol (MCP) servers. Default to read-only discovery; isolate effects at boundaries; provide dry-run previews; handle auth/rate limits gracefully.

## 2. Goals/Objectives

- Read-only by default; explicit consent for mutations
- Effects boundaries: perform MCP calls at adapters/controllers, keep domain logic pure
- Safety: redact secrets; never echo authorization headers
- Resilience: detect 401/403/429 and provide actionable guidance and backoff

## 3. Functional Requirements

- Discovery of available tools/resources is allowed without execution when unauthenticated
- Execution requires explicit, in-session consent for the specific action
- Provide optional dry-run previews of requests before sending
- On failures: classify and surface next steps (auth missing, SSO approval, rate limit)
- Minimal audit note written to log directory without sensitive data

## 4. Acceptance Criteria

- ERD documents consent model, boundaries, and failure handling
- Includes examples of discovery vs execution flows
- Discovery outputs MUST use the canonical schema described in `.cursor/rules/capabilities.mdc` (Discovery section) §Schema (do not redefine fields)
- Logs: record timestamp, server, tool, status (no headers/tokens)
- Guidance for degraded modes when MCP servers are unavailable

## 4.1 Examples

Discovery (read-only):

"List available tools from configured MCP servers. If unauthenticated, show names with a warning: 'MCP execution disabled; discovery only.'"

Dry-run preview (before execution):

```json
{
  "server": "github",
  "tool": "createPullRequest",
  "input": { "title": "feat: add X", "base": "main", "head": "user/feat-x" },
  "dryRun": true
}
```

Canonical capability item example (must match Capabilities rule §Discovery):

```json
{
  "name": "pr-create",
  "source": "mcp",
  "summary": "Create a GitHub PR via API (requires token)",
  "authRequired": true,
  "enabled": true,
  "notes": "Dry-run preview recommended before execution"
}
```

Failure guidance strings:

- 401 Unauthorized: "Token missing/invalid. Export GH_TOKEN and approve SSO if prompted."
- 403 Forbidden: "Token lacks scope or SSO approval. Adjust permissions or approve SSO."
- 429 Rate Limited: "Hit rate limit. Back off and retry after the indicated window."

## 5. Risks/Edge Cases

- Server capability drift; prefer discovery-first and degrade gracefully
- Organization SSO approval required; provide next-step guidance
- Intermittent rate limits; implement backoff and communicate retry windows

## 6. Rollout Note

- Owner: rules-maintainers
- Target: next docs iteration
- Comms: Link from README and `docs/projects/split-progress/erd.md`

## 7. Testing

- Manual dry-runs to confirm previews and consent prompts
- Negative-path checks for 401/403/429 guidance
