# Phase 2 Integration Test Protocol

**Goal**: Validate WebSocket-based coordinator-worker pattern with 0 manual prompts per task

**Date**: 2025-10-26

## Prerequisites

- [x] WebSocket server implemented (22/22 tests passing)
- [x] Client library implemented with event handling
- [x] Phase 2 coordinator rule created
- [x] Phase 2 worker rule created
- [x] Dependencies installed (`yarn install`)

## Test Project

**Same as Phase 1** for comparison:

**Task**: Generate summaries for 3 README files
- `docs/projects/multi-chat-coordination/README.md`
- `docs/projects/root-readme-generator/README.md`
- `docs/projects/archived-projects-audit/README.md`

**Expected outputs**: 3 summaries (100-200 words each)

## Integration Test Steps

### Step 1: Start Server

**Engineer action**:
```bash
yarn coordination:server
```

**Expected output**:
```
[Server] Multi-Chat Coordination Server starting on port 3100
[Server] Ready for connections
[Server] Press Ctrl+C to stop
```

**Validation**:
- [ ] Server starts without errors
- [ ] Port 3100 is listening
- [ ] Server logs "Ready for connections"

---

### Step 2: Start Coordinator Chat

**Engineer**: Open new chat window (Coordinator)

**Prompt** (in Coordinator chat):
```
Act as coordinator (Phase 2). Use @coordinator-chat-phase2

Coordinate via WebSocket: Generate summaries for these 3 files:
- docs/projects/multi-chat-coordination/README.md
- docs/projects/root-readme-generator/README.md  
- docs/projects/archived-projects-audit/README.md

Output to tmp/coordination/summaries/
```

**Expected coordinator behavior**:
1. Connects to WebSocket server
2. Registers as coordinator
3. Creates 3 task JSON files
4. Pushes tasks to server queue
5. Displays: "3 tasks queued. Server will auto-assign to workers."
6. Enters monitoring mode (listens for push notifications)

**Validation**:
- [ ] Coordinator connects successfully
- [ ] 3 tasks pushed to server
- [ ] Server logs show tasks queued
- [ ] No errors in coordinator or server logs

---

### Step 3: Start Worker Chat

**Engineer**: Open new chat window (Worker)

**Prompt** (in Worker chat):
```
Connect as worker (Phase 2). Use @worker-chat-phase2

Worker ID: worker-A
```

**Expected worker behavior**:
1. Connects to WebSocket server
2. Registers as worker-A
3. **Automatically receives task-001** (pushed by server, no prompt)
4. Displays task summary
5. Begins execution

**Expected server behavior**:
- Logs "Worker registered: worker-A"
- Auto-assigns task-001 immediately
- Logs "Assigning task task-001 to worker-A"

**Expected coordinator behavior**:
- Receives `worker_registered` notification
- Receives `task_assigned` notification
- Updates status display

**Validation**:
- [ ] Worker connects and registers
- [ ] Worker receives task-001 automatically (0 prompts)
- [ ] Coordinator notified of worker registration
- [ ] Coordinator notified of task assignment

**Manual prompts so far**: 2 (coordinator start + worker start) - both setup only

---

### Step 4: Worker Executes Task 1

**Expected worker behavior** (fully autonomous):
1. Reads target file
2. Generates summary (100-200 words)
3. Writes to output file
4. Creates report JSON in `tmp/coordination/reports/`
5. **Automatically receives task-002** (pushed by server, no prompt)
6. Begins next task

**Expected server behavior**:
- Watches `reports/` directory
- Detects new report file
- Notifies coordinator of completion
- Auto-assigns task-002 to worker-A

**Expected coordinator behavior**:
- Receives `report_detected` notification
- Receives `task_complete` notification
- Updates status dashboard
- **No manual prompt needed!**

**Validation**:
- [ ] Worker completes task-001
- [ ] Report file created
- [ ] Server detects report automatically
- [ ] Coordinator notified automatically
- [ ] Task-002 assigned automatically
- [ ] Worker receives task-002 with 0 prompts

**Manual prompts for task 1**: 0 ✅

---

### Step 5: Worker Executes Tasks 2 & 3

**Expected flow** (fully autonomous):
1. Worker completes task-002
2. Server detects report, assigns task-003
3. Worker receives task-003, executes
4. Worker completes task-003
5. Server detects completion
6. Server sends "no more tasks" to worker
7. Coordinator receives final completion notification

**Validation**:
- [ ] Worker completes all 3 tasks autonomously
- [ ] All 3 reports created
- [ ] All 3 summaries exist and meet criteria
- [ ] Worker context efficiency ≥4 throughout

**Manual prompts for tasks 2-3**: 0 ✅

---

### Step 6: Coordinator Final Summary

**Expected coordinator behavior** (automatic):
- Receives all completion notifications in real-time
- Displays final status:
  ```
  All tasks complete!
  - task-001: ✓ (worker-A, 2m)
  - task-002: ✓ (worker-A, 2m)
  - task-003: ✓ (worker-A, 2m)
  
  Deliverables:
  - tmp/coordination/summaries/multi-chat-coordination-summary.md
  - tmp/coordination/summaries/root-readme-generator-summary.md
  - tmp/coordination/summaries/archived-projects-audit-summary.md
  
  Total time: 6 minutes
  Worker context efficiency: 5.0 (excellent)
  ```

**Validation**:
- [ ] All 3 summaries created
- [ ] Word counts: 100-200 each
- [ ] Required sections present
- [ ] Coordinator displays completion automatically

---

## Metrics Collection

### Engineer Intervention Count

**Target**: 0 prompts per task

**Track**:
- Setup prompts: [count] (expected: 2)
- Execution prompts: [count] (target: 0)
- Total prompts: [count]
- Prompts per task: [count / 3]

### Context Efficiency

**Target**: Worker maintains score ≥4

**Track**:
- Task 1: [score]
- Task 2: [score]
- Task 3: [score]
- Average: [score]

### Latency

**Measure handoff time**:
- Report created → Coordinator notified: [seconds] (target: <1s)
- Task queued → Worker receives: [seconds] (target: <1s)

### Comparison: Phase 1 vs Phase 2

| Metric | Phase 1 | Phase 2 | Improvement |
|--------|---------|---------|-------------|
| Prompts/task | 0.67 | [TBD] | Target: 0 |
| Context efficiency | 5.0 | [TBD] | Maintain ≥4 |
| Handoff latency | Manual | [TBD] | Target: <1s |
| Autonomy | High | [TBD] | Target: 100% |

---

## Success Criteria

Phase 2 is **successful** if:
- [ ] Server starts and accepts connections
- [ ] Coordinator connects and pushes tasks
- [ ] Worker connects and receives tasks automatically
- [ ] **0 manual prompts per task during execution**
- [ ] All deliverables meet criteria
- [ ] Context efficiency ≥4 maintained
- [ ] Handoff latency <1s

Phase 2 **needs adjustment** if:
- Prompts per task >0
- Context efficiency <4
- Handoff latency >2s
- WebSocket reliability issues

---

## Findings Template

**What worked well**:
- [Improvements over Phase 1]

**What needs improvement**:
- [Friction points]

**Metrics achieved**:
- Prompts/task: [N]
- Context efficiency: [N]
- Latency: [N]s

**Recommendation**:
- [ ] Phase 2 validated, proceed to Phase 3 (multi-worker)
- [ ] Adjustments needed
- [ ] Revert to Phase 1 (simpler)

---

## Next Steps After Validation

**If successful**:
1. Document findings
2. Update README with Phase 2 status
3. Plan Phase 3 (multi-worker scaling)

**If needs work**:
1. Document issues
2. Iterate on server/client
3. Re-test

---

## Troubleshooting

### Server won't start

```bash
# Check port availability
lsof -i :3100

# Try different port
COORDINATION_PORT=3200 yarn coordination:server
```

### Client connection fails

```bash
# Verify server is running
ps aux | grep coordination-server

# Check server logs for errors
# (should see "Ready for connections")
```

### Tasks not auto-assigning

**Check**:
- Worker registered successfully?
- Tasks in server queue?
- Server logs show assignment attempt?

**Debug**:
```bash
ts-node src/coordination/cli.ts coordinator status
```

