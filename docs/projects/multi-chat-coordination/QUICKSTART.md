# Quick Start: Multi-Chat Coordination (Phase 1)

**Prerequisites**:

- Cursor editor with this repository open
- Two chat windows (one for Coordinator, one for Worker)

## Setup (One Time)

```bash
# Create directory structure
mkdir -p tmp/coordination/tasks/{pending,assigned,in-progress,completed,failed}
mkdir -p tmp/coordination/reports
mkdir -p tmp/coordination/summaries
```

## Running Your First Coordinated Project

### Step 1: Start Coordinator

**In Coordinator chat window**, say:

```
Act as coordinator. Coordinate: Generate summaries for these 3 files:
- docs/projects/multi-chat-coordination/README.md
- docs/projects/root-readme-generator/README.md
- docs/projects/archived-projects-audit/README.md

Output summaries to tmp/coordination/summaries/
```

**Expected**:

- Coordinator splits into 3 tasks
- Creates task files in `tmp/coordination/tasks/pending/`
- Tells you to start a worker

### Step 2: Start Worker

**Open a new chat window** (Worker chat)

**In Worker chat**, say:

```
Connect as worker
```

**Expected**:

- Worker assigns itself an ID (e.g., "worker-A")
- Worker polls for tasks
- Worker waits for task assignment

### Step 3: Assign First Task

**Back in Coordinator chat**, say:

```
Assign task-001 to worker
```

**Expected**:

- Coordinator moves task to assigned/
- Coordinator tells you worker can check for tasks

### Step 4: Worker Executes

**In Worker chat**, say:

```
check
```

**Expected**:

- Worker finds task-001
- Worker reads target file, writes summary
- Worker reports completion
- Worker auto-polls for next task

### Step 5: Continue Coordination

**In Coordinator chat**, monitor status:

```
status
```

**Expected**:

- Coordinator shows completed/in-progress/pending tasks
- Coordinator assigns remaining tasks automatically (or with minimal prompting)

### Step 6: Completion

When all tasks are done:

**In Coordinator chat**, say:

```
status
```

**Expected**:

- Coordinator shows all tasks complete
- Lists all deliverables
- Archives task files

## Troubleshooting

### Worker says "No tasks available"

**Solution**: Go to Coordinator and assign a task:

```
Assign task-001 to worker
```

### Task file format error

**Validate manually**:

```bash
bash .cursor/scripts/task-schema-validate.sh tmp/coordination/tasks/pending/task-001.json
```

### Worker context degraded (score <4)

**Solution**: Start a fresh worker chat and connect as "worker-B"

## Files to Check

**Task files**: `tmp/coordination/tasks/pending/*.json`  
**Reports**: `tmp/coordination/reports/*.json`  
**Outputs**: `tmp/coordination/summaries/*.md`

## Validation

After completion, verify:

```bash
# All 3 summaries exist
ls -l tmp/coordination/summaries/

# All reports exist
ls -l tmp/coordination/reports/

# Word count check (should be 100-200 per summary)
wc -w tmp/coordination/summaries/*.md
```

## Next Steps

After successful Phase 1:

- See `protocols/phase1-validation-protocol.md` for metrics
- Document findings and decide whether to proceed to Phase 2 (WebSocket server)

