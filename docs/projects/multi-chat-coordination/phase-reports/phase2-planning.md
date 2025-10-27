# Phase 2 Planning: WebSocket Server

**Date**: 2025-10-26  
**Status**: Planning (Phase 1 complete)

## Goals

**Primary**: Eliminate manual prompts during execution (achieve true autonomy)

**Key improvements over Phase 1**:

- Server watches `reports/` directory continuously
- Server pushes task assignments to Coordinator/Worker
- Coordinator/Worker become reactive (server notifies them)
- Result: **0 manual prompts per task** after setup

---

## Architecture

### Components

1. **WebSocket Server** (`coordination-server.js`)

   - Node.js with `ws` library
   - Manages: task queue, worker registry, status tracking
   - Watches: `tmp/coordination/reports/` for new files
   - Pushes: task assignments, completion notifications

2. **Coordinator Chat** (updated rule)

   - Connects to server as client
   - Splits project into tasks
   - Pushes tasks to server queue
   - Receives: worker reports, completion notifications
   - Displays: real-time status dashboard

3. **Worker Chat** (updated rule)
   - Connects to server as client
   - Registers with worker ID
   - Receives: task assignments (pushed from server)
   - Executes: task, generates report
   - Notifies: server of completion

---

## Server API

### Messages (JSON over WebSocket)

#### Coordinator → Server

```json
{
  "type": "register",
  "role": "coordinator",
  "projectId": "summary-generation"
}

{
  "type": "create_tasks",
  "tasks": [
    { "id": "task-001", "type": "file-summary", ... }
  ]
}
```

#### Worker → Server

```json
{
  "type": "register",
  "role": "worker",
  "workerId": "worker-A"
}

{
  "type": "task_complete",
  "taskId": "task-001",
  "report": { "deliverables": [...], "score": 5 }
}
```

#### Server → Coordinator

```json
{
  "type": "worker_registered",
  "workerId": "worker-A"
}

{
  "type": "task_complete",
  "taskId": "task-001",
  "workerId": "worker-A",
  "report": { ... }
}

{
  "type": "status_update",
  "completed": 2,
  "pending": 1,
  "workers": [
    { "id": "worker-A", "status": "working", "taskId": "task-003" }
  ]
}
```

#### Server → Worker

```json
{
  "type": "task_assigned",
  "task": {
    "id": "task-001",
    "type": "file-summary",
    "context": { ... },
    "acceptance": { ... }
  }
}

{
  "type": "project_complete",
  "message": "All tasks done. You may disconnect."
}
```

---

## Implementation Steps

### Step 1: Server Core

- [ ] Create `coordination-server.js`
- [ ] Implement WebSocket connection handling
- [ ] Implement client registry (coordinator + workers)
- [ ] Implement task queue (push, pop, status)
- [ ] Add basic logging

**Test**: Manual client connection with `wscat`

---

### Step 2: Server File Watching

- [ ] Add `chokidar` for watching `reports/` directory
- [ ] Emit `task_complete` event on new report file
- [ ] Push completion to coordinator
- [ ] Auto-assign next task to idle worker

**Test**: Manually create report file, verify coordinator notified

---

### Step 3: Coordinator Client

- [ ] Create `.cursor/scripts/coordination-client.js` (WebSocket client wrapper)
- [ ] Update coordinator rule: connect to server on startup
- [ ] Coordinator sends `create_tasks` to server
- [ ] Coordinator receives `task_complete` and updates dashboard
- [ ] Coordinator displays real-time status

**Test**: Coordinator creates tasks, server confirms receipt

---

### Step 4: Worker Client

- [ ] Update worker rule: connect to server on startup
- [ ] Worker registers with ID
- [ ] Worker receives `task_assigned` (pushed from server)
- [ ] Worker executes, reports via server
- [ ] Worker waits for next pushed assignment

**Test**: Worker receives task, executes, reports, receives next task (no manual prompt)

---

### Step 5: Integration

- [ ] Run full cycle: 1 coordinator + 1 worker + 3 tasks
- [ ] Measure: 0 prompts per task after setup
- [ ] Validate: all deliverables correct, context efficiency maintained

**Test**: Full validation protocol (similar to Phase 1)

---

## Success Criteria

Phase 2 is successful if:

- [ ] Server starts from coordinator chat
- [ ] Worker connects and receives tasks automatically
- [ ] Coordinator sees real-time status without prompts
- [ ] **0 manual prompts per task** during execution
- [ ] Context efficiency maintained (≥4)
- [ ] Deliverables validated correctly

---

## Technology Choices

**WebSocket library**: `ws` (lightweight, Node.js standard)  
**File watching**: `chokidar` (cross-platform, robust)  
**JSON schema**: Reuse Phase 1 task schema

**Rationale**: Minimal dependencies, localhost-only, no auth needed

---

## Timeline Estimate

- Server core: 2-3 hours
- File watching: 1-2 hours
- Coordinator client: 2-3 hours
- Worker client: 2-3 hours
- Integration & testing: 2-3 hours

**Total**: 9-14 hours (Phase 2 complete)

---

## Carryover from Phase 1

**Keep**:

- ✅ Task JSON schema (works great)
- ✅ Validation scripts (still useful for CI/testing)
- ✅ Directory structure (server will use same paths)
- ✅ Worker autonomous execution pattern

**Replace**:

- ❌ File-based polling (server watches instead)
- ❌ Manual task assignment (server pushes instead)
- ❌ Report checking script (server auto-detects)

---

## Next Session Tasks

1. Create server skeleton (`coordination-server.js`)
2. Write connection tests
3. Update coordinator/worker rules with connection logic
4. Run integration test with 1 coordinator + 1 worker

---

## References

- Phase 1 findings: `protocols/phase1-validation-protocol.md`
- Task schema: `decisions/task-schema-decision.md`
- Phase 1 scripts: `.cursor/scripts/coordination-*.sh` (keep for offline testing)
