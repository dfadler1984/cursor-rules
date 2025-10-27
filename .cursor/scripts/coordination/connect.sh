#!/usr/bin/env bash
# Connect to coordination server and execute client commands

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../.lib.sh
source "$SCRIPT_DIR/../.lib.sh"

usage() {
  print_help_header "connect.sh" "Connect to coordination server"
  print_usage "connect.sh <role> <command> [args...]"
  echo ""
  echo "Arguments:"
  echo "  role       coordinator or worker"
  echo "  command    register, create-tasks, complete-task, status"
  print_exit_codes
  echo ""
  echo "Examples:"
  echo "  bash connect.sh worker register --worker-id=worker-A"
  echo "  bash connect.sh coordinator create-tasks tasks.json"
}

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) break ;;
  esac
done

ROLE="${1:-}"
COMMAND="${2:-}"
shift 2 || true

if [[ -z "$ROLE" ]] || [[ -z "$COMMAND" ]]; then
  echo "Error: Role and command required" >&2
  usage >&2
  exit 2
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

