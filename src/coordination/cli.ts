#!/usr/bin/env ts-node
/**
 * CLI for Multi-Chat Coordination Client
 * Simple wrapper around CoordinationClient for shell usage
 */

import { CoordinationClient } from "./client";
import * as fs from "fs";

const PORT = process.env.COORDINATION_PORT || "3100";
const URL = `ws://localhost:${PORT}`;

async function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.error("Usage: coordination-cli.ts <role> <command> [args...]");
    console.error("Roles: coordinator | worker");
    console.error("Commands: register, create-tasks, complete-task, status");
    process.exit(1);
  }

  const role = args[0] as "coordinator" | "worker";
  const command = args[1];
  const commandArgs = args.slice(2);

  const client = new CoordinationClient(URL);

  try {
    await client.connect();

    switch (command) {
      case "register": {
        const projectId = commandArgs.find((a) => a.startsWith("--project-id="))?.split("=")[1];
        const workerId = commandArgs.find((a) => a.startsWith("--worker-id="))?.split("=")[1];

        const response = await client.register(role, {
          ...(projectId && { projectId }),
          ...(workerId && { workerId }),
        });

        console.log(JSON.stringify(response, null, 2));
        break;
      }

      case "create-tasks": {
        const tasksFile = commandArgs[0];
        if (!tasksFile) {
          throw new Error("Tasks file required");
        }

        const tasksData = fs.readFileSync(tasksFile, "utf8");
        const tasks = JSON.parse(tasksData);

        const response = await client.createTasks(Array.isArray(tasks) ? tasks : [tasks]);
        console.log(JSON.stringify(response, null, 2));
        break;
      }

      case "complete-task": {
        const taskId = commandArgs[0];
        const reportFile = commandArgs[1];

        if (!taskId || !reportFile) {
          throw new Error("Task ID and report file required");
        }

        const reportData = fs.readFileSync(reportFile, "utf8");
        const report = JSON.parse(reportData);

        const response = await client.completeTask(taskId, report);
        console.log(JSON.stringify(response, null, 2));
        break;
      }

      case "status": {
        const response = await client.getStatus();
        console.log(JSON.stringify(response, null, 2));
        break;
      }

      default:
        console.error(`Unknown command: ${command}`);
        process.exit(1);
    }

    await client.disconnect();
    process.exit(0);
  } catch (error) {
    console.error("Error:", (error as Error).message);
    await client.disconnect();
    process.exit(1);
  }
}

main();

