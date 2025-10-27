# Decision: Include Full Task Context in WebSocket Messages

**Date**: 2025-10-27  
**Status**: To Implement  
**Discovered by**: Worker-B (via enhanced logging)  
**Priority**: High (blocks autonomous execution)

---

## Context

During Phase 2 WebSocket coordination testing with enhanced observability logging, Worker-B discovered that `task_assigned` WebSocket messages contain placeholder/test task objects instead of the actual task details from the coordinator's queue.

### Evidence

**Server logs** show task correctly queued:

```
[Server] Task queued: task-001
```

**Worker logs** (captured by enhanced logging) show empty task data:

```
[Worker worker-B] TASK ASSIGNED: task-001
[Worker worker-B] Description: Test task
[Worker worker-B] Target files: []
[Worker worker-B] Output files: []
[Worker worker-B] Requirements: []
```

**Worker had to compensate** by manually reading task file:

```
Manually read tmp/coordination/phase2-tasks.json
Found the real task-001 definition
Executed the correct task
```

---

## Root Cause

### Data Flow Problem

**When coordinator creates tasks**:

1. ✅ Coordinator pushes full task objects via WebSocket
2. ✅ Server receives full task objects with all context
3. ❌ **Server only stores task IDs** (`this.taskQueue.push(task.id)`)
4. ❌ **Server discards task context** (targetFiles, requirements, etc.)

**When server assigns tasks**:

1. Server pops task ID from queue
2. ❌ **Server creates placeholder test task** (no real data)
3. ❌ **Worker receives empty task object**
4. Worker cannot execute autonomously (missing work details)

### Code Evidence

**File**: `src/coordination/server.ts`

**Problem 1** (line 27): Only stores IDs

```typescript
private taskQueue: string[] = [];  // ❌ Only IDs!
```

**Problem 2** (line 331): Discards task data

```typescript
this.taskQueue.push(task.id); // ❌ Throws away task object!
```

**Problem 3** (lines 468-484): Creates placeholder

```typescript
// For tests, send minimal task
// In production, this would read from files  ⬅️ Comment acknowledges issue!
const task: Task = {
  id: taskId,
  type: "test",
  description: "Test task",
  context: {
    targetFiles: [], // ❌ Empty!
    outputFiles: [],
    requirements: [],
  },
  // ...
};
```

---

## Decision

### Solution: Store and Send Full Task Objects

**Principle**: Server must preserve all task data from creation through assignment.

### Implementation

#### 1. Add Task Storage

```typescript
export class CoordinationServer {
  private tasks: Map<string, Task> = new Map(); // ✅ NEW: Full task storage
  private taskQueue: string[] = []; // Keep for ordering
  // ...
}
```

#### 2. Save Tasks When Created

```typescript
private handleCreateTasks(
  clientId: string,
  client: ClientInfo,
  message: CreateTasksMessage
): void {
  // ...validation...

  tasks.forEach((task) => {
    if (!task.id) {
      console.error("[Server] Task missing id:", task);
      return;
    }

    this.tasks.set(task.id, task);  // ✅ Store full task
    this.taskQueue.push(task.id);   // Queue for ordering
    console.log(`[Server] Task queued: ${task.id}`);
  });

  // ...
}
```

#### 3. Send Full Task When Assigning

```typescript
private assignNextTask(workerId: string): void {
  const taskId = this.taskQueue.shift();
  if (!taskId) return;

  // Look up full task
  const task = this.tasks.get(taskId);
  if (!task) {
    console.error(`[Server] Task ${taskId} not found in storage`);
    this.activeTasks.delete(taskId);
    return;
  }

  const client = Array.from(this.clients.values()).find(
    (c) => c.workerId === workerId
  );

  if (!client) {
    console.error(`[Server] Worker client not found: ${workerId}`);
    this.activeTasks.delete(taskId);
    this.taskQueue.unshift(taskId);  // Return to queue
    return;
  }

  console.log(`[Server] Assigning task ${taskId} to ${workerId}`);

  // Update task status
  task.status = "assigned";

  // Record active task
  this.activeTasks.set(taskId, {
    taskId,
    workerId,
    assignedAt: new Date().toISOString(),
  });

  // Send FULL task to worker
  this.send(client.ws, {
    type: "task_assigned",
    task,  // ✅ Full task with all context!
  });

  // Notify coordinator
  if (this.coordinator) {
    this.send(this.coordinator.ws, {
      type: "task_assigned",
      taskId,
      workerId,
    });
  }
}
```

#### 4. Clean Up Completed Tasks

```typescript
private handleTaskComplete(
  clientId: string,
  client: ClientInfo,
  message: TaskCompleteMessage
): void {
  const { taskId, report } = message;

  // ...existing validation...

  // Remove from active tasks
  this.activeTasks.delete(taskId);

  // Clean up from storage (task complete)
  this.tasks.delete(taskId);  // ✅ Clean up after completion

  // ...rest of completion handling...
}
```

---

## Benefits

### For Workers

✅ Receive all work details needed for autonomous execution  
✅ No manual task file reading required  
✅ Can execute immediately upon receiving task_assigned event  
✅ Enables true autonomous multi-task execution

### For Coordinator

✅ Workers execute without manual intervention  
✅ Achieves Phase 2 goal of zero prompts per task  
✅ Real-time task distribution works as designed

### For System

✅ Proper data flow (coordinator → server → worker)  
✅ Server acts as true message broker (not just ID router)  
✅ Enables future enhancements (task modification, cancellation)

---

## Impact Analysis

### Breaking Changes

**None** - This is an enhancement to existing placeholder implementation

### Migration

**Not needed** - Current code comment explicitly says "For tests, send minimal task"

### Performance

**Negligible** - Task objects are small (<5KB each), storage is in-memory Map

### Memory

**Bounded** - Tasks deleted after completion, max tasks = queue size

---

## Testing Strategy

### Unit Tests

```typescript
describe("Task storage and retrieval", () => {
  it("should store full task when created", () => {
    const task = {
      id: "task-001",
      description: "Real task",
      context: { targetFiles: ["file.md"] }
    };

    server.handleCreateTasks(coordinatorId, coordinator, {
      type: "create_tasks",
      tasks: [task]
    });

    const stored = server.tasks.get("task-001");
    expect(stored).toEqual(task);
  });

  it("should send full task when assigning", () => {
    // Create task
    server.handleCreateTasks(...);

    // Assign to worker
    server.assignNextTask("worker-A");

    // Verify worker received full task
    const message = lastMessageSentTo(workerWs);
    expect(message.task.context.targetFiles).toHaveLength(1);
    expect(message.task.description).toBe("Real task");
  });
});
```

### Integration Test

1. Coordinator pushes 3 tasks with full context
2. Worker connects and receives first task
3. Verify worker log shows real task details (not "Test task")
4. Worker executes autonomously (no file reading needed)
5. Repeat for remaining tasks

---

## Rollout Plan

### Phase 1: Implementation

1. Add `private tasks: Map<string, Task>` to server
2. Update `handleCreateTasks` to store full tasks
3. Update `assignNextTask` to lookup and send full tasks
4. Update `handleTaskComplete` to clean up storage

### Phase 2: Testing

1. Run existing unit tests (should still pass)
2. Add new tests for task storage/retrieval
3. Run integration test with real coordinator + worker
4. Verify enhanced logging shows full task context

### Phase 3: Validation

1. Check worker logs for real task details
2. Verify autonomous execution (no manual file reading)
3. Confirm tasks-002 and task-003 auto-assign and execute
4. Validate completion reports

---

## Success Criteria

✅ Worker logs show full task context (not "Test task")  
✅ Workers execute without reading task files manually  
✅ All 3 tasks complete autonomously  
✅ Zero manual prompts per task (Phase 2 goal achieved)

---

## Related

- **Discovery**: Worker-B Phase 2 execution (2025-10-27)
- **Observability**: `decisions/observability-file-logging.md`
- **Implementation**: `src/coordination/server.ts`
- **Validation**: Enhanced logging captured the data gap

---

## Timeline

**Discovered**: 2025-10-27  
**Priority**: High  
**Effort**: 2-3 hours (implementation + tests)  
**Target**: Next Phase 2 milestone

---

## Notes

**Credit**: This issue was discovered through Worker-B's enhanced observability logging (Tier 2 solution). Without file logging, this data flow problem would have been invisible.

**Lesson**: Observability investments pay immediate dividends - we found a critical gap on first test run.
