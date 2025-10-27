---
status: planning
owner: dfadler1984
created: 2025-01-26
mode: full
---

# Engineering Requirements: Multi-Chat Coordination System

## Goals

### Primary Goals

1. **Context efficiency**: Distribute work to keep worker chat context scores ≥4
2. **Automation**: Minimize engineer intervention during task execution (target: ≤20% of handoffs)
3. **Parallelization**: Enable 2-3x speedup for projects with parallelizable tasks

### Secondary Goals

4. **Observability**: Real-time status of coordinator + all workers
5. **Error recovery**: Graceful handling of worker failures/blocks
6. **Reusability**: Pattern applicable to various project types

## Non-Goals

- External deployment (localhost only)
- Complex authentication (single engineer, trusted environment)
- Chat-to-chat direct communication (coordinator is hub)
- Production-grade scaling (3-5 workers max)

## Future Requirements

### Portability (Post-Validation)

**Goal**: Enable copying `.cursor/` directory to other repos for reuse.

**Current state**: Phase 2 TypeScript code in `src/coordination/` (outside `.cursor/`)

**Options to explore** (when system proves valuable):
1. Move to `.cursor/lib/coordination/` (new lib directory for shared code)
2. Move to `.cursor/scripts/coordination/` (alongside other scripts)
3. Inline into bash scripts (no TypeScript dependency)

**Decision**: Deferred until pattern demonstrates material value in production use.

## User Stories

### As an Engineer

1. I can start a coordinator chat that splits a project into tasks
2. I can start worker chats that connect to coordinator and request work
3. I can monitor progress across all chats from coordinator's status view
4. I receive escalations when workers are blocked or produce low-quality output
5. I can review final deliverables after all workers complete

### As a Coordinator Chat

1. I can start a local Node.js server for task distribution
2. I can split user's project into parallelizable tasks
3. I can assign tasks to workers via server API
4. I can track completion status and update task lists
5. I can detect worker failures and reassign work
6. I can validate worker outputs against acceptance criteria

### As a Worker Chat

1. I can connect to coordinator's server on startup
2. I can receive task assignments with scoped context
3. I can execute tasks following TDD/testing rules
4. I can report completion with deliverables and context efficiency score
5. I can poll for next task after completing current work
6. I can escalate to engineer when blocked

## Phases

### Phase 1: File-Based Spike (1 Coordinator + 1 Worker)

**Goal**: Validate coordinator-worker pattern without server complexity

**Scope**:

- Coordinator splits simple project into 2-3 tasks
- Tasks written to JSON files in shared directory
- Worker reads task file, executes, writes report file
- Coordinator reads report, assigns next task

**Acceptance**:

- [ ] Coordinator successfully splits sample project
- [ ] Worker completes 2+ tasks autonomously
- [ ] Engineer intervention ≤2 manual steps
- [ ] Worker maintains context score ≥4

**Deliverables**:

- Coordinator rule for task splitting
- Worker rule for task execution loop
- Sample task JSON schema
- Validation protocol document

### Phase 2: WebSocket Server (1 Coordinator + 1 Worker)

**Goal**: Replace file-based handoff with real-time server communication

**Scope**:

- Coordinator starts Node.js WebSocket server
- Worker connects via ws client
- Tasks pushed/pulled via WebSocket messages
- Real-time status updates

**Acceptance**:

- [ ] Server starts successfully from coordinator
- [ ] Worker connects and receives tasks
- [ ] Coordinator sees worker status in real-time
- [ ] Graceful handling of worker disconnect/reconnect

**Deliverables**:

- Node.js WebSocket server script
- Task assignment API schema
- Worker client script
- Connection protocol document

### Phase 3: Multi-Worker Scaling (1 Coordinator + 2-3 Workers)

**Goal**: Validate parallel task execution with multiple workers

**Scope**:

- Coordinator load-balances tasks across workers
- Workers operate independently (no shared state)
- Progress tracking shows per-worker status
- Completion requires all workers finished

**Acceptance**:

- [ ] 3 workers execute tasks in parallel
- [ ] No duplicate work assigned
- [ ] Coordinator correctly tracks completion
- [ ] 2x+ speedup vs single worker (for parallelizable tasks)

**Deliverables**:

- Load balancing logic
- Multi-worker status dashboard
- Conflict detection mechanism

### Phase 4: Error Recovery & Conflict Resolution

**Goal**: Handle worker failures and output conflicts gracefully

**Scope**:

- Worker failure detection (timeout, error report)
- Task reassignment to healthy workers
- Output validation before acceptance
- Conflict resolution for overlapping changes

**Acceptance**:

- [ ] Coordinator detects worker failure within 2 minutes
- [ ] Failed tasks automatically reassigned
- [ ] Output validation catches ≥80% of issues
- [ ] Conflicts escalated to engineer with context

**Deliverables**:

- Failure detection mechanism
- Validation script suite
- Conflict resolution protocol

## Technical Constraints

### Cursor Platform Constraints

1. **Turn-based model**: Workers can't receive messages mid-turn
   - Solution: Semi-autonomous polling after task completion
2. **Stateless sessions**: Workers lose state on restart
   - Solution: Coordinator maintains authoritative state
3. **No native IPC**: No built-in chat-to-chat communication
   - Solution: External Node.js server as message relay

### Infrastructure Constraints

1. **Localhost only**: No network deployment
2. **Single engineer**: No multi-user coordination needed
3. **Trusted environment**: Minimal auth/security required

## Acceptance Bundle

### Phase 1 Target (Minimal Viable Pattern)

**Files**:

- `.cursor/rules/coordinator-chat.mdc` - Coordinator behavior
- `.cursor/rules/worker-chat.mdc` - Worker behavior
- `.cursor/scripts/task-schema-validate.sh` - Task format validation
- `docs/projects/multi-chat-coordination/protocols/phase1-validation-protocol.md`
- `docs/projects/multi-chat-coordination/examples/simple-summarization-task.json`

**Success Criteria**:

1. Coordinator splits "generate 3 file summaries" into 3 tasks
2. Worker completes all 3 tasks with ≤1 engineer prompt per task
3. Final deliverables pass validation (files exist, >100 words each)
4. Worker's context efficiency score ≥4 throughout

**Run Instructions**:

```bash
# Coordinator chat
"Create tasks for: generate summaries of files A, B, C"

# Worker chat (in separate window)
"Connect as worker and start task loop"

# Validation
bash .cursor/scripts/task-schema-validate.sh tasks/*.json
```

## Risks & Mitigations

### High-Risk Items

1. **Debugging complexity** (N+1 chats + server logs)
   - Mitigation: Phase 1 uses files (easier to inspect), extensive logging
2. **Protocol design churn** (task schema, handoff format)
   - Mitigation: Start with minimal schema, iterate based on real usage
3. **Diminishing returns** (overhead > benefit for simple tasks)
   - Mitigation: Track metrics per phase; abort if speedup <1.5x

### Medium-Risk Items

4. **Context leakage** (workers receive too much/too little context)
   - Mitigation: Workers report efficiency score; coordinator adjusts
5. **Worker drift** (stuck in loops, off-task)
   - Mitigation: Timeout detection, escalation to engineer

## Open Questions

1. **Task granularity**: What's the optimal task size for parallelization?
   - Answer by: Phase 1 validation with various task types
2. **Handoff format**: JSON vs structured markdown vs custom DSL?
   - Answer by: Phase 1 prototype with JSON, iterate if painful
3. **Acceptance criteria**: Can coordinator auto-validate outputs reliably?
   - Answer by: Phase 4 validation script experiments

## Success Criteria (Overall)

**Project is successful if**:

1. Phase 1 spike validates pattern feasibility
2. Engineer time investment ≤40 hours (setup + 4 phases)
3. Multi-worker speedup ≥2x for real projects (measured in Phase 3+)
4. Pattern documented and reusable for future projects

**Project should be abandoned if**:

1. Phase 1 requires >10 engineer prompts per task (too manual)
2. Context efficiency consistently <3 (negates benefits)
3. Debugging time >2x single-chat equivalent (too complex)

## Dependencies

- Node.js (v18+) with `ws` library for WebSocket server
- Cursor editor (current version)
- Repository scripts: task validation, context efficiency scoring
- Rules: TDD-first, testing, context-efficiency

## Timeline Estimate

- Phase 1: 4-6 hours (spike + validation)
- Phase 2: 6-8 hours (server + protocol)
- Phase 3: 4-6 hours (scaling + load balancing)
- Phase 4: 8-10 hours (error recovery + validation)

**Total**: 22-30 hours over 2-3 weeks

## Related Work

- Previous: `MULTI-CHAT-SESSION-SUMMARY.md` (manual coordination baseline)
- Context efficiency metrics: `docs/projects/context-efficiency/`
- Chat performance patterns: `docs/guides/chat-performance/`

