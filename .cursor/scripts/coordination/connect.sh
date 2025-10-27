#!/usr/bin/env bash
# Connect to coordination server and execute client commands
# Usage: coordination-connect.sh <role> <command> [args...]
#
# Roles: coordinator | worker
# Commands:
#   - register [--project-id ID] [--worker-id ID]
#   - create-tasks <tasks.json>
#   - complete-task <task-id> <report.json>
#   - status

set -euo pipefail

ROLE="${1:-}"
COMMAND="${2:-}"
shift 2 || true

if [[ -z "$ROLE" ]] || [[ -z "$COMMAND" ]]; then
  echo "Error: Role and command required" >&2
  echo "Usage: coordination-connect.sh <role> <command> [args...]" >&2
  exit 1
fi

PORT="${COORDINATION_PORT:-3100}"
URL="ws://localhost:$PORT"

# Execute via ts-node
exec ts-node - <<EOF
import { CoordinationClient } from './src/coordination/client';

const client = new CoordinationClient('$URL');

(async () => {
  await client.connect();
  
  const role = '$ROLE';
  const command = '$COMMAND';
  const args = process.argv.slice(1);
  
  try {
    if (command === 'register') {
      const projectId = args.find(a => a.startsWith('--project-id='))?.split('=')[1];
      const workerId = args.find(a => a.startsWith('--worker-id='))?.split('=')[1];
      
      const response = await client.register(role as any, {
        ...(projectId && { projectId }),
        ...(workerId && { workerId })
      });
      
      console.log(JSON.stringify(response, null, 2));
    } else if (command === 'create-tasks') {
      const fs = require('fs');
      const tasksFile = args[0];
      const tasks = JSON.parse(fs.readFileSync(tasksFile, 'utf8'));
      
      const response = await client.createTasks(Array.isArray(tasks) ? tasks : [tasks]);
      console.log(JSON.stringify(response, null, 2));
    } else if (command === 'complete-task') {
      const taskId = args[0];
      const reportFile = args[1];
      const fs = require('fs');
      const report = JSON.parse(fs.readFileSync(reportFile, 'utf8'));
      
      const response = await client.completeTask(taskId, report);
      console.log(JSON.stringify(response, null, 2));
    } else if (command === 'status') {
      const response = await client.getStatus();
      console.log(JSON.stringify(response, null, 2));
    } else {
      console.error('Unknown command: ' + command);
      process.exit(1);
    }
    
    await client.disconnect();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error.message);
    await client.disconnect();
    process.exit(1);
  }
})();
EOF

