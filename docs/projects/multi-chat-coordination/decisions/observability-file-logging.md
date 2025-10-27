# Decision: Worker Observability via File Logging

**Date**: 2025-10-26  
**Status**: Implemented  
**Proposed by**: Worker-B

---

## Context

During Phase 2 WebSocket coordination testing, Worker-B identified a critical observability gap:

**Problem**: Background worker processes lack visibility

- Workers run in background to maintain persistent WebSocket connections
- Console output not visible when running in background
- No way to see task assignments, execution progress, or errors
- Difficult to debug issues or verify worker status

**Impact**: Coordinator and engineers operate blind when workers are executing tasks

---

## Decision

Implement **Tier 2: File-Based Logging** for all worker listeners.

### Pattern

**Dual logging**: Write to both console (for foreground use) AND file (for background observability)

```typescript
const LOG_FILE = path.join(
  __dirname,
  "../tmp/coordination/worker-${WORKER_ID}.log"
);

const log = (msg: string) => {
  const timestamp = new Date().toISOString();
  const line = `[${timestamp}] ${msg}`;
  console.log(line); // Console output
  fs.appendFileSync(LOG_FILE, line + "\n"); // File output
};
```

### Implementation

Applied to `tmp/worker-b-listener.ts`:

1. Added `LOG_FILE` constant pointing to `tmp/coordination/worker-b.log`
2. Created `log()` helper function for dual output
3. Replaced all `console.log()` calls with `log()`
4. Enhanced task assignment logging with structured details
5. Added error logging to fatal error handler

---

## Benefits

### For Coordinators

- Monitor worker activity in real-time: `tail -f tmp/coordination/worker-*.log`
- Verify task assignments without interrupting workers
- Debug issues without stopping processes

### For Workers

- Activity persists across restarts
- Error logs available for troubleshooting
- Structured event logging for analysis

### For Engineers

- Zero impact on automation (no manual intervention needed)
- Easy debugging of coordination issues
- Historical log for post-mortem analysis

---

## Alternatives Considered

### Alternative 1: Server-Only Logging

**Approach**: Only log events on server side

**Pros**:

- Single log location
- No worker code changes

**Cons**:

- Server doesn't see worker internal state
- Can't debug worker execution logic
- Missing worker-side errors

**Rejected**: Insufficient visibility into worker behavior

### Alternative 2: Structured State Files (Tier 3)

**Approach**: Workers write JSON state files with current status

**Pros**:

- Programmatically queryable
- Machine-readable status
- Enables monitoring dashboards

**Cons**:

- More complex implementation
- File locking concerns
- State updates require care

**Deferred**: Good future enhancement, but file logging solves immediate need

### Alternative 3: HTTP Status Endpoints

**Approach**: Add HTTP server to workers for status queries

**Pros**:

- RESTful status API
- Standard tooling (curl, etc.)

**Cons**:

- Significantly more complex
- Port management overhead
- Overkill for basic observability

**Rejected**: Too complex for Phase 2

---

## Implementation Notes

### Log Format

```
[2025-10-26T21:50:00.000Z] [Worker worker-B] TASK ASSIGNED: task-001
[2025-10-26T21:50:01.000Z] [Worker worker-B] Description: Generate summary...
[2025-10-26T21:50:01.000Z] [Worker worker-B] Target files: ["docs/projects/..."]
[2025-10-26T21:50:01.000Z] [Worker worker-B] Output files: ["tmp/coordination/summaries/..."]
[2025-10-26T21:50:01.000Z] [Worker worker-B] Status: Waiting for execution...
```

### Log Location

`tmp/coordination/worker-${WORKER_ID}.log`

### Rotation

Not implemented in Phase 2. Future consideration:

- Rotate daily or by size
- Keep last N days of logs
- Compress old logs

---

## Validation

### Test Scenario

1. Start worker-B listener in background
2. Coordinator assigns task-001
3. Check log file shows task details
4. Worker completes task
5. Check log file shows completion

### Results

✅ Log file created successfully  
✅ Task assignment details captured  
✅ Timestamps accurate  
✅ No performance impact observed  
✅ Coordinator can monitor via `tail -f`

---

## Rollout

### Phase 2 (Immediate)

- ✅ Worker-B listener updated with file logging
- ✅ Pattern documented in `worker-chat-phase2.mdc`
- ✅ Decision documented (this file)

### Future Workers

All new worker listeners should:

1. Import the logging pattern from `worker-chat-phase2.mdc`
2. Use dual logging (console + file)
3. Log all key events (connection, assignment, completion, errors)

### Template

Worker listener template should include:

```typescript
const LOG_FILE = path.join(
  __dirname,
  `../tmp/coordination/worker-${WORKER_ID}.log`
);

const log = (msg: string) => {
  const timestamp = new Date().toISOString();
  const line = `[${timestamp}] ${msg}`;
  console.log(line);
  fs.appendFileSync(LOG_FILE, line + "\n");
};
```

---

## Related

- **Proposal**: `tmp/coordination/worker-feedback/worker-B-observability-suggestion.md`
- **Rule**: `.cursor/rules/worker-chat-phase2.mdc` (section 5.5)
- **Implementation**: `tmp/worker-b-listener.ts`

---

## Metrics

**Implementation Time**: ~5 minutes  
**Lines of Code**: ~12 lines added  
**Impact**: High (solves critical observability gap)  
**Complexity**: Low (simple file append)  
**Adoption**: Required for all Phase 2+ workers
