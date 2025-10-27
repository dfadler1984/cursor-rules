# Monitoring Workers in Real-Time

**Purpose**: Guide for coordinators to monitor worker activity during Phase 2 execution

---

## Quick Start

### Monitor Single Worker

```bash
tail -f tmp/coordination/worker-B.log
```

### Monitor All Workers

```bash
tail -f tmp/coordination/worker-*.log
```

### Watch for Errors

```bash
tail -f tmp/coordination/worker-*.log | grep ERROR
```

---

## What You'll See

### Worker Connection

```
[2025-10-26T18:04:00.000Z] [Worker worker-B] Connecting to ws://localhost:3100...
[2025-10-26T18:04:01.000Z] [Worker worker-B] Connected
[2025-10-26T18:04:01.000Z] [Worker worker-B] Registered: {"type":"registered","role":"worker","workerId":"worker-B"}
[2025-10-26T18:04:01.000Z] [Worker worker-B] Listening for tasks... (Press Ctrl+C to exit)
[2025-10-26T18:04:01.000Z] [Worker worker-B] Log file: /Users/.../tmp/coordination/worker-b.log
```

### Task Assignment

```
[2025-10-26T18:04:15.000Z] [Worker worker-B] ========================================
[2025-10-26T18:04:15.000Z] [Worker worker-B] TASK ASSIGNED: task-001
[2025-10-26T18:04:15.000Z] [Worker worker-B] Description: Generate concise summary...
[2025-10-26T18:04:15.000Z] [Worker worker-B] Target files: ["docs/projects/multi-chat-coordination/README.md"]
[2025-10-26T18:04:15.000Z] [Worker worker-B] Output files: ["tmp/coordination/summaries/..."]
[2025-10-26T18:04:15.000Z] [Worker worker-B] Requirements: ["Summary should be 100-200 words",...]
[2025-10-26T18:04:15.000Z] [Worker worker-B] Status: Waiting for execution and report...
[2025-10-26T18:04:15.000Z] [Worker worker-B] ========================================
```

### Error Example

```
[2025-10-26T18:05:00.000Z] [Worker worker-B] ERROR: Connection lost
[2025-10-26T18:05:01.000Z] [Worker worker-B] FATAL ERROR: Unable to reconnect
```

---

## Monitoring Commands

### Check Last 20 Lines

```bash
tail -20 tmp/coordination/worker-B.log
```

### Search for Specific Task

```bash
grep "task-002" tmp/coordination/worker-B.log
```

### Count Tasks Completed

```bash
grep "TASK ASSIGNED" tmp/coordination/worker-B.log | wc -l
```

### Check Worker Status (Is it running?)

```bash
ps aux | grep worker-b-listener
```

---

## Troubleshooting

### Worker Not Receiving Tasks

**Check log file**:

```bash
tail -f tmp/coordination/worker-B.log
```

**Look for**:

- Did worker register successfully?
- Is worker connected?
- Any connection errors?

### Worker Appears Stuck

**Check last activity**:

```bash
tail -1 tmp/coordination/worker-B.log
```

**If silent for >5 minutes**:

1. Check if process is running
2. Check server logs for errors
3. Consider restarting worker

### Log File Not Updating

**Possible causes**:

1. Worker not running in background
2. Worker crashed (check terminal output)
3. File permissions issue

**Resolution**:

```bash
# Check if worker is running
ps aux | grep worker-b-listener

# If not running, restart
cd /Users/dustinfadler/Development/cursor-rules
npx ts-node -P tsconfig.coordination.json tmp/worker-b-listener.ts &
```

---

## Best Practices

### Multiple Terminal Windows

**Recommended setup**:

- Window 1: Coordinator chat
- Window 2: Worker monitoring (`tail -f tmp/coordination/worker-*.log`)
- Window 3: Server logs (if needed)

### Log Rotation

**For long-running sessions**, clear old logs periodically:

```bash
# Archive old logs
mv tmp/coordination/worker-B.log tmp/coordination/worker-B-$(date +%Y%m%d).log

# Worker will create new log file automatically
```

### Status Checks

**Quick health check**:

```bash
# Last 5 lines from each worker
tail -5 tmp/coordination/worker-*.log

# Count active tasks
grep "TASK ASSIGNED" tmp/coordination/worker-*.log | tail -5
```

---

## Integration with Coordinator

### Coordinator Script Example

```bash
#!/bin/bash
# Quick coordinator status script

echo "=== Worker Status ==="
for log in tmp/coordination/worker-*.log; do
  worker=$(basename "$log" .log)
  last_line=$(tail -1 "$log")
  echo "$worker: $last_line"
done

echo ""
echo "=== Tasks in Queue ==="
yarn coordination:client coordinator status
```

---

## Related

- **Implementation**: `tmp/worker-b-listener.ts` (file logging pattern)
- **Rule**: `.cursor/rules/worker-chat-phase2.mdc` (section 5.5)
- **Decision**: `docs/projects/multi-chat-coordination/decisions/observability-file-logging.md`
