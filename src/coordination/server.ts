/**
 * Multi-Chat Coordination Server
 * WebSocket server for coordinator-worker communication
 */

import * as WebSocket from "ws";
import * as chokidar from "chokidar";
import * as path from "path";
import * as fs from "fs";
import type {
  ClientInfo,
  ServerMessage,
  RegisterMessage,
  CreateTasksMessage,
  TaskCompleteMessage,
  Task,
  ActiveTask,
  WorkerStatus,
  ClientRole,
  TaskReport,
} from "./types";

export class CoordinationServer {
  private wss: WebSocket.WebSocketServer | null = null;
  private port: number;
  private clients: Map<string, ClientInfo> = new Map();
  private taskQueue: string[] = [];
  private activeTasks: Map<string, ActiveTask> = new Map();
  private coordinator: { clientId: string; ws: WebSocket } | null = null;
  private running = false;
  private watcher: chokidar.FSWatcher | null = null;
  private reportsDir: string;

  constructor(port: number = 3100, reportsDir?: string) {
    this.port = port;
    this.reportsDir =
      reportsDir || path.join(process.cwd(), "tmp/coordination/reports");
  }

  async start(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.wss = new WebSocket.WebSocketServer({ port: this.port });

      this.wss.on("listening", () => {
        this.running = true;
        console.log(`[Server] Listening on port ${this.port}`);
        resolve();
      });

      this.wss.on("error", (error) => {
        console.error("[Server] WebSocket server error:", error);
        reject(error);
      });

      this.wss.on("connection", (ws: WebSocket) => {
        this.handleConnection(ws);
      });

      // Start file watcher for reports
      this.startFileWatcher();
    });
  }

  private startFileWatcher(): void {
    // Ensure reports directory exists
    if (!fs.existsSync(this.reportsDir)) {
      fs.mkdirSync(this.reportsDir, { recursive: true });
    }

    console.log(`[Server] Watching for reports in: ${this.reportsDir}`);

    this.watcher = chokidar.watch(
      path.join(this.reportsDir, "task-*-report.json"),
      {
        persistent: true,
        ignoreInitial: true,
      }
    );

    this.watcher.on("add", (filePath: string) => {
      console.log(`[Server] New report detected: ${path.basename(filePath)}`);

      try {
        const reportData = fs.readFileSync(filePath, "utf8");
        const report: TaskReport = JSON.parse(reportData);

        // Notify coordinator
        if (this.coordinator) {
          this.send(this.coordinator.ws, {
            type: "report_detected",
            taskId: report.taskId,
            workerId: report.workerId,
            reportPath: filePath,
            report,
          });
        }
      } catch (error) {
        console.error(
          `[Server] Error reading report ${filePath}:`,
          (error as Error).message
        );
      }
    });
  }

  async stop(): Promise<void> {
    return new Promise((resolve) => {
      if (!this.wss) {
        resolve();
        return;
      }

      // Close all client connections
      this.clients.forEach((client) => {
        if (client.ws.readyState === WebSocket.OPEN) {
          this.send(client.ws, {
            type: "server_shutdown",
            message: "Server is shutting down",
          });
          client.ws.close();
        }
      });

      // Stop file watcher
      if (this.watcher) {
        this.watcher.close();
        this.watcher = null;
      }

      this.wss.close(() => {
        this.running = false;
        this.clients.clear();
        this.taskQueue = [];
        this.activeTasks.clear();
        this.coordinator = null;
        console.log("[Server] Stopped");
        resolve();
      });
    });
  }

  isRunning(): boolean {
    return this.running;
  }

  private handleConnection(ws: WebSocket): void {
    const clientId = this.generateClientId();
    this.clients.set(clientId, { ws, role: null });

    console.log(`[Server] Client connected: ${clientId}`);

    // Send welcome message
    this.send(ws, {
      type: "connected",
      clientId,
      message: "Connected to coordination server",
    });

    ws.on("message", (data: WebSocket.Data) => {
      try {
        const message: ServerMessage = JSON.parse(data.toString());
        this.handleMessage(clientId, message);
      } catch (error) {
        console.error(
          `[Server] Error parsing message from ${clientId}:`,
          (error as Error).message
        );
        this.sendError(ws, "Invalid JSON message");
      }
    });

    ws.on("close", () => {
      this.handleDisconnect(clientId);
    });

    ws.on("error", (error: Error) => {
      console.error(`[Server] WebSocket error for ${clientId}:`, error.message);
    });
  }

  private handleDisconnect(clientId: string): void {
    const client = this.clients.get(clientId);
    console.log(
      `[Server] Client disconnected: ${clientId} (${client?.role || "unknown"})`
    );

    // Clean up active tasks if worker disconnected
    if (client?.role === "worker" && client.workerId) {
      for (const [taskId, task] of this.activeTasks.entries()) {
        if (task.workerId === client.workerId) {
          console.log(
            `[Server] Reassigning task ${taskId} (worker ${client.workerId} disconnected)`
          );
          this.taskQueue.unshift(taskId);
          this.activeTasks.delete(taskId);
        }
      }
    }

    if (client?.role === "coordinator") {
      this.coordinator = null;
    }

    this.clients.delete(clientId);
  }

  private handleMessage(clientId: string, message: ServerMessage): void {
    const client = this.clients.get(clientId);
    if (!client) return;

    switch (message.type) {
      case "register":
        this.handleRegister(clientId, client, message as RegisterMessage);
        break;
      case "create_tasks":
        this.handleCreateTasks(clientId, client, message as CreateTasksMessage);
        break;
      case "request_task":
        this.handleRequestTask(clientId, client);
        break;
      case "task_complete":
        this.handleTaskComplete(
          clientId,
          client,
          message as TaskCompleteMessage
        );
        break;
      case "status":
        this.handleStatus(client);
        break;
      default:
        this.sendError(
          client.ws,
          `Unknown message type: ${(message as any).type}`
        );
    }
  }

  private handleRegister(
    clientId: string,
    client: ClientInfo,
    message: RegisterMessage
  ): void {
    const { role, workerId, projectId } = message;

    if (!role || !["coordinator", "worker"].includes(role)) {
      return this.sendError(
        client.ws,
        'Invalid role. Must be "coordinator" or "worker"'
      );
    }

    client.role = role;

    if (role === "coordinator") {
      client.projectId = projectId || "default";
      this.coordinator = { clientId, ws: client.ws };
      console.log(`[Server] Coordinator registered: ${client.projectId}`);

      this.send(client.ws, {
        type: "registered",
        role: "coordinator",
        projectId: client.projectId,
      });
    } else if (role === "worker") {
      if (!workerId) {
        return this.sendError(client.ws, "Worker must provide workerId");
      }

      client.workerId = workerId;
      console.log(`[Server] Worker registered: ${workerId}`);

      this.send(client.ws, {
        type: "registered",
        role: "worker",
        workerId,
      });

      // Notify coordinator
      if (this.coordinator) {
        this.send(this.coordinator.ws, {
          type: "worker_registered",
          workerId,
        });
      }

      // Auto-assign task if available
      this.assignNextTask(workerId);
    }
  }

  private handleCreateTasks(
    clientId: string,
    client: ClientInfo,
    message: CreateTasksMessage
  ): void {
    if (client.role !== "coordinator") {
      return this.sendError(client.ws, "Only coordinator can create tasks");
    }

    const { tasks } = message;

    if (!Array.isArray(tasks) || tasks.length === 0) {
      return this.sendError(client.ws, "tasks must be a non-empty array");
    }

    // Add tasks to queue
    tasks.forEach((task) => {
      if (!task.id) {
        console.error("[Server] Task missing id:", task);
        return;
      }
      this.taskQueue.push(task.id);
      console.log(`[Server] Task queued: ${task.id}`);
    });

    this.send(client.ws, {
      type: "tasks_created",
      count: tasks.length,
      queued: this.taskQueue.length,
    });

    console.log(
      `[Server] ${tasks.length} tasks created. Queue size: ${this.taskQueue.length}`
    );

    // Try to assign to available workers
    const workers = Array.from(this.clients.values()).filter(
      (c) => c.role === "worker" && !this.isWorkerBusy(c.workerId!)
    );

    workers.forEach((worker) => {
      this.assignNextTask(worker.workerId!);
    });
  }

  private handleRequestTask(clientId: string, client: ClientInfo): void {
    if (client.role !== "worker") {
      return this.sendError(client.ws, "Only workers can request tasks");
    }

    this.assignNextTask(client.workerId!);
  }

  private handleTaskComplete(
    clientId: string,
    client: ClientInfo,
    message: TaskCompleteMessage
  ): void {
    if (client.role !== "worker") {
      return this.sendError(client.ws, "Only workers can complete tasks");
    }

    const { taskId, report } = message;

    if (!taskId) {
      return this.sendError(client.ws, "taskId required");
    }

    console.log(`[Server] Task completed: ${taskId} by ${client.workerId}`);

    // Remove from active tasks
    this.activeTasks.delete(taskId);

    // Notify coordinator
    if (this.coordinator) {
      this.send(this.coordinator.ws, {
        type: "task_complete",
        taskId,
        workerId: client.workerId,
        report,
      });
    }

    // Send ack to worker
    this.send(client.ws, {
      type: "task_complete_ack",
      taskId,
    });

    // Try to assign next task
    this.assignNextTask(client.workerId!);
  }

  private handleStatus(client: ClientInfo): void {
    const workers: WorkerStatus[] = Array.from(this.clients.values())
      .filter((c) => c.role === "worker")
      .map((c) => ({
        workerId: c.workerId!,
        busy: this.isWorkerBusy(c.workerId!),
        currentTask:
          Array.from(this.activeTasks.entries()).find(
            ([_, task]) => task.workerId === c.workerId
          )?.[0] || null,
      }));

    this.send(client.ws, {
      type: "status_response",
      coordinator: this.coordinator ? "connected" : "disconnected",
      workers,
      queueSize: this.taskQueue.length,
      activeTasks: this.activeTasks.size,
    });
  }

  private assignNextTask(workerId: string): void {
    if (this.taskQueue.length === 0) {
      console.log(`[Server] No tasks available for ${workerId}`);

      const client = Array.from(this.clients.values()).find(
        (c) => c.workerId === workerId
      );

      if (client) {
        this.send(client.ws, {
          type: "no_tasks",
          message: "No tasks available in queue",
        });
      }
      return;
    }

    if (this.isWorkerBusy(workerId)) {
      console.log(`[Server] Worker ${workerId} is busy`);
      return;
    }

    const taskId = this.taskQueue.shift()!;

    // Mark as active
    this.activeTasks.set(taskId, {
      workerId,
      startTime: new Date().toISOString(),
    });

    // Find worker client
    const client = Array.from(this.clients.values()).find(
      (c) => c.workerId === workerId
    );

    if (!client) {
      console.error(`[Server] Worker client not found: ${workerId}`);
      this.activeTasks.delete(taskId);
      this.taskQueue.unshift(taskId);
      return;
    }

    console.log(`[Server] Assigning task ${taskId} to ${workerId}`);

    // For tests, send minimal task
    // In production, this would read from files
    const task: Task = {
      id: taskId,
      type: "test",
      description: "Test task",
      context: {
        targetFiles: [],
        outputFiles: [],
        requirements: [],
      },
      acceptance: {
        criteria: [],
      },
      status: "assigned",
      createdAt: new Date().toISOString(),
    };

    this.send(client.ws, {
      type: "task_assigned",
      task,
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

  private isWorkerBusy(workerId: string): boolean {
    return Array.from(this.activeTasks.values()).some(
      (task) => task.workerId === workerId
    );
  }

  private send(ws: WebSocket, message: any): void {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  private sendError(ws: WebSocket, error: string): void {
    this.send(ws, {
      type: "error",
      error,
    });
  }

  private generateClientId(): string {
    return `client-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }
}
