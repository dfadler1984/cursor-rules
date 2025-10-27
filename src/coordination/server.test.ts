/**
 * Tests for Multi-Chat Coordination Server
 * TDD: Red → Green → Refactor
 */

import * as WebSocket from "ws";
import { CoordinationServer } from "./server";
import { RegisterMessage, CreateTasksMessage, TaskCompleteMessage } from "./types";

describe("CoordinationServer", () => {
  let server: CoordinationServer;
  let port: number;

  beforeEach(() => {
    port = 3100 + Math.floor(Math.random() * 1000);
    server = new CoordinationServer(port);
  });

  afterEach(async () => {
    await server.stop();
  });

  describe("Connection", () => {
    test("should start server on specified port", async () => {
      await server.start();
      expect(server.isRunning()).toBe(true);
    });

    test("should accept client connections", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);

      await new Promise((resolve) => {
        client.on("open", resolve);
      });

      expect(client.readyState).toBe(WebSocket.OPEN);
      client.close();
    });

    test("should send connected message on connection", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);

      const message = await new Promise((resolve) => {
        client.on("message", (data) => {
          resolve(JSON.parse(data.toString()));
        });
      });

      expect(message).toMatchObject({
        type: "connected",
        clientId: expect.any(String),
      });

      client.close();
    });
  });

  describe("Registration", () => {
    test("should register coordinator", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(client);

      const registerMsg: RegisterMessage = {
        type: "register",
        role: "coordinator",
        projectId: "test-project",
      };

      client.send(JSON.stringify(registerMsg));

      const response = await waitForMessage(client, "registered");

      expect(response).toMatchObject({
        type: "registered",
        role: "coordinator",
        projectId: "test-project",
      });

      client.close();
    });

    test("should register worker", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(client);

      const registerMsg: RegisterMessage = {
        type: "register",
        role: "worker",
        workerId: "worker-A",
      };

      client.send(JSON.stringify(registerMsg));

      const response = await waitForMessage(client, "registered");

      expect(response).toMatchObject({
        type: "registered",
        role: "worker",
        workerId: "worker-A",
      });

      client.close();
    });

    test("should reject invalid role", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(client);

      const registerMsg = {
        type: "register",
        role: "invalid",
      };

      client.send(JSON.stringify(registerMsg));

      const response = await waitForMessage(client, "error");

      expect(response).toMatchObject({
        type: "error",
        error: expect.stringContaining("Invalid role"),
      });

      client.close();
    });

    test("should require workerId for worker registration", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(client);

      const registerMsg: RegisterMessage = {
        type: "register",
        role: "worker",
      };

      client.send(JSON.stringify(registerMsg));

      const response = await waitForMessage(client, "error");

      expect(response).toMatchObject({
        type: "error",
        error: expect.stringContaining("workerId"),
      });

      client.close();
    });
  });

  describe("Task Queue", () => {
    test("should accept tasks from coordinator", async () => {
      await server.start();

      const coordinator = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(coordinator);
      await registerAs(coordinator, "coordinator", "test-project");

      const createTasksMsg: CreateTasksMessage = {
        type: "create_tasks",
        tasks: [
          {
            id: "task-001",
            type: "test",
            description: "Test task",
            context: {
              targetFiles: ["test.md"],
              outputFiles: ["output.md"],
              requirements: [],
            },
            acceptance: {
              criteria: [],
            },
            status: "pending",
            createdAt: new Date().toISOString(),
          },
        ],
      };

      coordinator.send(JSON.stringify(createTasksMsg));

      const response = await waitForMessage(coordinator, "tasks_created");

      expect(response).toMatchObject({
        type: "tasks_created",
        count: 1,
        queued: 1,
      });

      coordinator.close();
    });

    test("should reject tasks from non-coordinator", async () => {
      await server.start();

      const worker = new WebSocket(`ws://localhost:${port}`);
      await waitForConnection(worker);
      await registerAs(worker, "worker", undefined, "worker-A");

      const createTasksMsg: CreateTasksMessage = {
        type: "create_tasks",
        tasks: [],
      };

      worker.send(JSON.stringify(createTasksMsg));

      const response = await waitForMessage(worker, "error");

      expect(response).toMatchObject({
        type: "error",
        error: expect.stringContaining("Only coordinator"),
      });

      worker.close();
    });
  });

  describe("Task Assignment", () => {
    test("should send full task context when assigning", async () => {
      await server.start();

      const coordinator = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(coordinator);
      await registerAs(coordinator, "coordinator", "test-project");

      const worker = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(worker);
      await registerAs(worker, "worker", undefined, "worker-A");

      // Create task with real context
      const realTask = {
        id: "task-001",
        type: "file-summary",
        description: "Generate summary of README",
        context: {
          targetFiles: ["docs/README.md"],
          outputFiles: ["tmp/summary.md"],
          requirements: ["100-200 words", "Include purpose"],
        },
        acceptance: {
          criteria: ["File exists", "Word count valid"],
        },
        status: "pending" as const,
        createdAt: new Date().toISOString(),
      };

      const createTasksMsg: CreateTasksMessage = {
        type: "create_tasks",
        tasks: [realTask],
      };

      coordinator.send(JSON.stringify(createTasksMsg));
      await waitForMessage(coordinator, "tasks_created");

      // Worker should receive FULL task context
      const assignment = await waitForMessage(worker, "task_assigned");

      expect(assignment.task).toMatchObject({
        id: "task-001",
        type: "file-summary",
        description: "Generate summary of README",
        context: {
          targetFiles: ["docs/README.md"],
          outputFiles: ["tmp/summary.md"],
          requirements: ["100-200 words", "Include purpose"],
        },
      });

      coordinator.close();
      worker.close();
    });

    test("should auto-assign task to registered worker", async () => {
      await server.start();

      const coordinator = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(coordinator);
      await registerAs(coordinator, "coordinator", "test-project");

      const worker = new WebSocket(`ws://localhost:${port}`);
      await waitForConnection(worker);
      await registerAs(worker, "worker", undefined, "worker-A");

      // Create task
      const createTasksMsg: CreateTasksMessage = {
        type: "create_tasks",
        tasks: [
          {
            id: "task-001",
            type: "test",
            description: "Test task",
            context: {
              targetFiles: ["test.md"],
              outputFiles: ["output.md"],
              requirements: [],
            },
            acceptance: {
              criteria: [],
            },
            status: "pending",
            createdAt: new Date().toISOString(),
          },
        ],
      };

      coordinator.send(JSON.stringify(createTasksMsg));
      await waitForMessage(coordinator, "tasks_created");

      // Worker should receive task assignment
      const assignment = await waitForMessage(worker, "task_assigned");

      expect(assignment).toMatchObject({
        type: "task_assigned",
        task: expect.objectContaining({
          id: "task-001",
        }),
      });

      coordinator.close();
      worker.close();
    });

    test("should send no_tasks message when queue empty", async () => {
      await server.start();

      const worker = new WebSocket(`ws://localhost:${port}`);
      await waitForConnection(worker);

      // Listen for no_tasks before registering
      const noTasksPromise = waitForMessage(worker, "no_tasks");
      await registerAs(worker, "worker", undefined, "worker-A");

      // Worker should receive no_tasks immediately after registration
      const response = await noTasksPromise;

      expect(response).toMatchObject({
        type: "no_tasks",
      });

      worker.close();
    });
  });

  describe("Task Completion", () => {
    test("should handle task completion from worker", async () => {
      await server.start();

      const coordinator = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(coordinator);
      await registerAs(coordinator, "coordinator", "test-project");

      const worker = new WebSocket(`ws://localhost:${port}`);
      await waitForConnection(worker);
      await registerAs(worker, "worker", undefined, "worker-A");

      // Create and assign task
      const createTasksMsg: CreateTasksMessage = {
        type: "create_tasks",
        tasks: [
          {
            id: "task-001",
            type: "test",
            description: "Test task",
            context: {
              targetFiles: ["test.md"],
              outputFiles: ["output.md"],
              requirements: [],
            },
            acceptance: {
              criteria: [],
            },
            status: "pending",
            createdAt: new Date().toISOString(),
          },
        ],
      };

      coordinator.send(JSON.stringify(createTasksMsg));
      await waitForMessage(worker, "task_assigned");

      // Complete task
      const completeMsg: TaskCompleteMessage = {
        type: "task_complete",
        taskId: "task-001",
        report: {
          taskId: "task-001",
          workerId: "worker-A",
          status: "completed",
          deliverables: ["output.md"],
          contextEfficiencyScore: 5,
          completedAt: new Date().toISOString(),
        },
      };

      // Listen for responses before sending completion
      const ackPromise = waitForMessage(worker, "task_complete_ack");
      const notificationPromise = waitForMessage(coordinator, "task_complete");

      worker.send(JSON.stringify(completeMsg));

      // Worker should receive ack
      const ack = await ackPromise;
      expect(ack).toMatchObject({
        type: "task_complete_ack",
        taskId: "task-001",
      });

      // Coordinator should receive notification
      const notification = await notificationPromise;
      expect(notification).toMatchObject({
        type: "task_complete",
        taskId: "task-001",
        workerId: "worker-A",
      });

      coordinator.close();
      worker.close();
    });
  });

  describe("Status", () => {
    test("should return server status", async () => {
      await server.start();

      const client = new WebSocket.WebSocket(`ws://localhost:${port}`);
      await waitForConnection(client);

      client.send(JSON.stringify({ type: "status" }));

      const response = await waitForMessage(client, "status_response");

      expect(response).toMatchObject({
        type: "status_response",
        coordinator: "disconnected",
        workers: [],
        queueSize: 0,
        activeTasks: 0,
      });

      client.close();
    });
  });
});

// Test helpers
function waitForConnection(client: any): Promise<void> {
  return new Promise((resolve, reject) => {
    if (client.readyState === WebSocket.OPEN) {
      // Skip connected message
      client.once("message", () => resolve());
    } else {
      client.once("open", () => {
        client.once("message", () => resolve());
      });
      client.once("error", reject);
    }
  });
}

function waitForMessage(client: any, messageType: string): Promise<any> {
  return new Promise((resolve, reject) => {
    const handler = (data: WebSocket.Data) => {
      try {
        const message = JSON.parse(data.toString());
        if (message.type === messageType) {
          client.off("message", handler);
          resolve(message);
        }
      } catch (error) {
        client.off("message", handler);
        reject(error);
      }
    };

    client.on("message", handler);

    setTimeout(() => {
      client.off("message", handler);
      reject(new Error(`Timeout waiting for message type: ${messageType}`));
    }, 5000);
  });
}

async function registerAs(
  client: any,
  role: "coordinator" | "worker",
  projectId?: string,
  workerId?: string
): Promise<void> {
  const registerMsg: RegisterMessage = {
    type: "register",
    role,
    ...(projectId && { projectId }),
    ...(workerId && { workerId }),
  };

  client.send(JSON.stringify(registerMsg));
  await waitForMessage(client, "registered");
}
