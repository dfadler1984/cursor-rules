"use strict";
/**
 * Multi-Chat Coordination Server
 * WebSocket server for coordinator-worker communication
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.CoordinationServer = void 0;
const WebSocket = __importStar(require("ws"));
const chokidar = __importStar(require("chokidar"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
class CoordinationServer {
    constructor(port = 3100, reportsDir) {
        this.wss = null;
        this.clients = new Map();
        this.taskQueue = [];
        this.activeTasks = new Map();
        this.coordinator = null;
        this.running = false;
        this.watcher = null;
        this.port = port;
        this.reportsDir =
            reportsDir || path.join(process.cwd(), "tmp/coordination/reports");
    }
    async start() {
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
            this.wss.on("connection", (ws) => {
                this.handleConnection(ws);
            });
            // Start file watcher for reports
            this.startFileWatcher();
        });
    }
    startFileWatcher() {
        // Ensure reports directory exists
        if (!fs.existsSync(this.reportsDir)) {
            fs.mkdirSync(this.reportsDir, { recursive: true });
        }
        console.log(`[Server] Watching for reports in: ${this.reportsDir}`);
        this.watcher = chokidar.watch(path.join(this.reportsDir, "task-*-report.json"), {
            persistent: true,
            ignoreInitial: true,
        });
        this.watcher.on("add", (filePath) => {
            console.log(`[Server] New report detected: ${path.basename(filePath)}`);
            try {
                const reportData = fs.readFileSync(filePath, "utf8");
                const report = JSON.parse(reportData);
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
            }
            catch (error) {
                console.error(`[Server] Error reading report ${filePath}:`, error.message);
            }
        });
    }
    async stop() {
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
    isRunning() {
        return this.running;
    }
    handleConnection(ws) {
        const clientId = this.generateClientId();
        this.clients.set(clientId, { ws, role: null });
        console.log(`[Server] Client connected: ${clientId}`);
        // Send welcome message
        this.send(ws, {
            type: "connected",
            clientId,
            message: "Connected to coordination server",
        });
        ws.on("message", (data) => {
            try {
                const message = JSON.parse(data.toString());
                this.handleMessage(clientId, message);
            }
            catch (error) {
                console.error(`[Server] Error parsing message from ${clientId}:`, error.message);
                this.sendError(ws, "Invalid JSON message");
            }
        });
        ws.on("close", () => {
            this.handleDisconnect(clientId);
        });
        ws.on("error", (error) => {
            console.error(`[Server] WebSocket error for ${clientId}:`, error.message);
        });
    }
    handleDisconnect(clientId) {
        const client = this.clients.get(clientId);
        console.log(`[Server] Client disconnected: ${clientId} (${client?.role || "unknown"})`);
        // Clean up active tasks if worker disconnected
        if (client?.role === "worker" && client.workerId) {
            for (const [taskId, task] of this.activeTasks.entries()) {
                if (task.workerId === client.workerId) {
                    console.log(`[Server] Reassigning task ${taskId} (worker ${client.workerId} disconnected)`);
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
    handleMessage(clientId, message) {
        const client = this.clients.get(clientId);
        if (!client)
            return;
        switch (message.type) {
            case "register":
                this.handleRegister(clientId, client, message);
                break;
            case "create_tasks":
                this.handleCreateTasks(clientId, client, message);
                break;
            case "request_task":
                this.handleRequestTask(clientId, client);
                break;
            case "task_complete":
                this.handleTaskComplete(clientId, client, message);
                break;
            case "status":
                this.handleStatus(client);
                break;
            default:
                this.sendError(client.ws, `Unknown message type: ${message.type}`);
        }
    }
    handleRegister(clientId, client, message) {
        const { role, workerId, projectId } = message;
        if (!role || !["coordinator", "worker"].includes(role)) {
            return this.sendError(client.ws, 'Invalid role. Must be "coordinator" or "worker"');
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
        }
        else if (role === "worker") {
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
    handleCreateTasks(clientId, client, message) {
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
        console.log(`[Server] ${tasks.length} tasks created. Queue size: ${this.taskQueue.length}`);
        // Try to assign to available workers
        const workers = Array.from(this.clients.values()).filter((c) => c.role === "worker" && !this.isWorkerBusy(c.workerId));
        workers.forEach((worker) => {
            this.assignNextTask(worker.workerId);
        });
    }
    handleRequestTask(clientId, client) {
        if (client.role !== "worker") {
            return this.sendError(client.ws, "Only workers can request tasks");
        }
        this.assignNextTask(client.workerId);
    }
    handleTaskComplete(clientId, client, message) {
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
        this.assignNextTask(client.workerId);
    }
    handleStatus(client) {
        const workers = Array.from(this.clients.values())
            .filter((c) => c.role === "worker")
            .map((c) => ({
            workerId: c.workerId,
            busy: this.isWorkerBusy(c.workerId),
            currentTask: Array.from(this.activeTasks.entries()).find(([_, task]) => task.workerId === c.workerId)?.[0] || null,
        }));
        this.send(client.ws, {
            type: "status_response",
            coordinator: this.coordinator ? "connected" : "disconnected",
            workers,
            queueSize: this.taskQueue.length,
            activeTasks: this.activeTasks.size,
        });
    }
    assignNextTask(workerId) {
        if (this.taskQueue.length === 0) {
            console.log(`[Server] No tasks available for ${workerId}`);
            const client = Array.from(this.clients.values()).find((c) => c.workerId === workerId);
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
        const taskId = this.taskQueue.shift();
        // Mark as active
        this.activeTasks.set(taskId, {
            workerId,
            startTime: new Date().toISOString(),
        });
        // Find worker client
        const client = Array.from(this.clients.values()).find((c) => c.workerId === workerId);
        if (!client) {
            console.error(`[Server] Worker client not found: ${workerId}`);
            this.activeTasks.delete(taskId);
            this.taskQueue.unshift(taskId);
            return;
        }
        console.log(`[Server] Assigning task ${taskId} to ${workerId}`);
        // For tests, send minimal task
        // In production, this would read from files
        const task = {
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
    isWorkerBusy(workerId) {
        return Array.from(this.activeTasks.values()).some((task) => task.workerId === workerId);
    }
    send(ws, message) {
        if (ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify(message));
        }
    }
    sendError(ws, error) {
        this.send(ws, {
            type: "error",
            error,
        });
    }
    generateClientId() {
        return `client-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    }
}
exports.CoordinationServer = CoordinationServer;
//# sourceMappingURL=server.js.map