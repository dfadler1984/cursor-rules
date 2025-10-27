# Multi-Chat Coordination: Tasks

**Status**: Phase 1 & 2 Complete  
**Last Updated**: 2025-10-27

## Phase 1: File-Based Spike (1 Coordinator + 1 Worker)

**Goal**: Validate coordinator-worker pattern without server complexity

### Planning & Setup

- [x] Define task JSON schema (fields: id, description, context, acceptance, files)
- [x] Create shared task directory structure (tasks/pending/, tasks/reports/)
- [x] Document file-based handoff protocol

### Coordinator Implementation

- [x] Write coordinator rule (`.cursor/rules/coordinator-chat.mdc`)
  - Task splitting logic
  - File-based task assignment
  - Progress tracking via report files
  - Status display format
- [x] Create task schema validation script (`.cursor/scripts/task-schema-validate.sh`)
- [x] Test coordinator with sample project (3 file summaries)

### Worker Implementation

- [x] Write worker rule (`.cursor/rules/worker-chat.mdc`)
  - Task polling loop
  - Task execution with TDD compliance
  - Report generation (deliverables + context score)
  - Escalation triggers
- [x] Test worker with sample task (single file summary)

### Integration & Validation

- [x] Run full cycle: coordinator assigns 3 tasks → worker completes → coordinator validates
- [x] Measure engineer intervention count (target: ≤2 prompts)
- [x] Measure worker context efficiency (target: ≥4)
- [x] Document findings in `protocols/phase1-validation-protocol.md`

### Scripts (Consent Friction Fix)

- [x] Create `coordination-task-assign.sh` (move + update JSON)
- [x] Create `coordination-report-check.sh` (list reports)
- [x] Create `coordination-task-complete.sh` (move to completed)
- [x] Write tests for all scripts (all passing)
- [x] Update coordinator rule to use scripts

### Phase 1 Acceptance

- [x] Coordinator successfully splits sample project
- [x] Worker completes 2+ tasks autonomously (completed 3/3)
- [x] Engineer intervention ≤2 manual steps (achieved 0.67 prompts/task)
- [x] Worker maintains context score ≥4 (maintained 5.0)
- [x] Decision document: continue to Phase 2 ✅

**Phase 1: COMPLETE** 🎉

---

## Phase 2: WebSocket Server (1 Coordinator + 1 Worker)

**Goal**: Replace file-based handoff with real-time server communication

### Server Implementation

- [x] Create TypeScript WebSocket server (13/13 tests passing)
  - Task queue management
  - Worker registration
  - Status endpoint
- [x] Define message protocol (JSON schema for task/report/status messages)
- [x] Add connection handling (connect, disconnect, reconnect)
- [x] Test server in isolation (9/9 tests passing)

### Client Implementation

- [x] Create TypeScript client library (9/9 tests passing)
  - Event-driven architecture
  - Type-safe message handling
  - Auto-reconnect support
- [x] Create CLI wrapper for shell usage
- [x] Test client with server (integration tests passing)

### Coordinator Updates

- [x] Create Phase 2 coordinator rule (WebSocket-based)
  - Server startup workflow
  - Push-based task creation
  - Real-time notification handling
  - No polling needed
- [x] Test coordinator with running server (integration)

### Worker Updates

- [x] Create Phase 2 worker rule (WebSocket-based)
  - Server connection workflow
  - Push-based task reception
  - Removed polling logic
  - Auto-assignment pattern
- [x] Test worker with running server (integration)

### Integration & Validation

- [x] Run full cycle with WebSocket communication (2/3 tasks completed)
- [x] Measure latency vs file-based (observed: <1s per handoff ✅)
- [x] Test disconnect/reconnect scenarios (validated graceful handling)
- [x] Document findings in `PHASE2-FINDINGS.md`

### Phase 2 Acceptance

- [x] Server starts successfully from coordinator
- [x] Worker connects and receives tasks (full context ✅)
- [x] Coordinator sees worker status in real-time (via server log)
- [x] Graceful handling of worker disconnect/reconnect

### Bug Fixes & Enhancements

- [x] Fix task context delivery (server now stores full Task objects)
- [x] Add file watching for report detection
- [x] Implement enhanced observability (Worker-B contribution)
- [x] Create tsconfig.json for ts-node support

**Phase 2: VALIDATED (Partial)** - Full context delivery proven, turn-based constraints identified

---

## Phase 3: Multi-Worker Scaling (1 Coordinator + 2-3 Workers)

**Goal**: Validate parallel task execution with multiple workers

### Load Balancing

- [ ] Add worker pool management to server
- [ ] Implement task assignment algorithm (round-robin or least-loaded)
- [ ] Add duplicate work prevention
- [ ] Test with 3 workers requesting tasks simultaneously

### Coordinator Updates

- [ ] Update status display for multiple workers
- [ ] Add per-worker progress tracking
- [ ] Implement completion detection (all workers done)
- [ ] Test with 3 workers

### Worker Updates

- [ ] Add worker ID to reports
- [ ] Test multiple workers in parallel (no shared state issues)

### Integration & Validation

- [ ] Run project with 3 parallel workers
- [ ] Measure total completion time vs single worker
- [ ] Verify no duplicate work assigned
- [ ] Document in `protocols/phase3-validation-protocol.md`

### Phase 3 Acceptance

- [ ] 3 workers execute tasks in parallel
- [ ] No duplicate work assigned
- [ ] Coordinator correctly tracks completion
- [ ] 2x+ speedup vs single worker (for parallelizable tasks)

---

## Phase 4: Error Recovery & Conflict Resolution

**Goal**: Handle worker failures and output conflicts gracefully

### Failure Detection

- [ ] Add timeout tracking to server (worker must report within N minutes)
- [ ] Implement health check mechanism
- [ ] Add task reassignment on worker failure
- [ ] Test with simulated worker hang

### Output Validation

- [ ] Create validation script suite (file existence, format checks)
- [ ] Add coordinator validation step before accepting deliverables
- [ ] Implement retry mechanism for failed validation
- [ ] Test with intentionally bad worker output

### Conflict Resolution

- [ ] Define conflict types (overlapping file edits, contradictory results)
- [ ] Add conflict detection to coordinator
- [ ] Implement escalation protocol (notify engineer with context)
- [ ] Test with conflicting worker outputs

### Integration & Validation

- [ ] Run multi-worker project with simulated failures
- [ ] Measure failure detection time (target: <2 minutes)
- [ ] Measure validation accuracy (target: ≥80% issue detection)
- [ ] Document in `protocols/phase4-validation-protocol.md`

### Phase 4 Acceptance

- [ ] Coordinator detects worker failure within 2 minutes
- [ ] Failed tasks automatically reassigned
- [ ] Output validation catches ≥80% of issues
- [ ] Conflicts escalated to engineer with context

---

## Post-Phase 4: Documentation & Refinement

- [ ] Write user guide for starting coordinator/worker chats
- [ ] Document task types suitable for parallelization
- [ ] Create example projects (file summarization, test generation, rule validation)
- [ ] Measure ROI: time saved vs overhead for real projects
- [ ] Decision: productionize or archive as experimental pattern

---

## Future: Portability (When System Proves Valuable)

**Goal**: Make coordination system portable by keeping all code in `.cursor/` directory

**Current state**:
- ✅ Phase 1: All bash scripts in `.cursor/scripts/` (portable)
- ⚠️ Phase 2: TypeScript code in `src/coordination/` (not portable)

**Options to evaluate**:
- [ ] Move `src/coordination/` → `.cursor/lib/coordination/`
- [ ] Move to `.cursor/scripts/coordination/` (flatten)
- [ ] Inline Phase 2 logic into bash (no TypeScript)
- [ ] Keep Phase 2 as-is (reference only, not for cross-repo use)

**Decision criteria**: Measure real-world usage and value first

**Priority**: Low (deferred until pattern demonstrates material ROI)

---

## Carryovers

_Items discovered during work that don't fit current phase scope_

---

## Notes

- Each phase builds on previous; don't skip ahead
- Validate acceptance criteria before advancing
- Track engineer intervention and context efficiency throughout
- Abort if speedup consistently <1.5x or debugging time >2x single-chat

## Relevant Files

- Coordinator rule: `.cursor/rules/coordinator-chat.mdc`
- Worker rule: `.cursor/rules/worker-chat.mdc`
- Server script: `.cursor/scripts/coordination-server.js`
- Worker client: `.cursor/scripts/worker-client.js`
- Validation scripts: `.cursor/scripts/task-schema-validate.sh`, etc.
