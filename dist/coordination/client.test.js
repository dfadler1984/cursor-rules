"use strict";
/**
 * Tests for WebSocket Client Utilities
 * TDD: Red → Green → Refactor
 */
Object.defineProperty(exports, "__esModule", { value: true });
const server_1 = require("./server");
const client_1 = require("./client");
describe("CoordinationClient", () => {
    let server;
    let port;
    beforeEach(async () => {
        port = 3100 + Math.floor(Math.random() * 1000);
        server = new server_1.CoordinationServer(port);
        await server.start();
    });
    afterEach(async () => {
        await server.stop();
    });
    describe("Connection", () => {
        test("should connect to server", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await client.connect();
            expect(client.isConnected()).toBe(true);
            await client.disconnect();
        });
        test("should receive connected message", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            const connectedPromise = new Promise((resolve) => {
                client.on("connected", resolve);
            });
            await client.connect();
            const message = await connectedPromise;
            expect(message).toMatchObject({
                type: "connected",
                clientId: expect.any(String),
            });
            await client.disconnect();
        });
        test("should handle disconnect", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await client.connect();
            await client.disconnect();
            expect(client.isConnected()).toBe(false);
        });
    });
    describe("Registration", () => {
        test("should register as coordinator", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await client.connect();
            const response = await client.register("coordinator", {
                projectId: "test-project",
            });
            expect(response).toMatchObject({
                type: "registered",
                role: "coordinator",
                projectId: "test-project",
            });
            await client.disconnect();
        });
        test("should register as worker", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await client.connect();
            const response = await client.register("worker", {
                workerId: "worker-A",
            });
            expect(response).toMatchObject({
                type: "registered",
                role: "worker",
                workerId: "worker-A",
            });
            await client.disconnect();
        });
    });
    describe("Task Management", () => {
        test("should send tasks from coordinator", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await client.connect();
            await client.register("coordinator", { projectId: "test" });
            const response = await client.createTasks([
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
            ]);
            expect(response).toMatchObject({
                type: "tasks_created",
                count: 1,
                queued: 1,
            });
            await client.disconnect();
        });
        test("should receive task assignment as worker", async () => {
            const coordinator = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await coordinator.connect();
            await coordinator.register("coordinator", { projectId: "test" });
            const worker = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await worker.connect();
            await worker.register("worker", { workerId: "worker-A" });
            const taskAssignedPromise = new Promise((resolve) => {
                worker.on("task_assigned", resolve);
            });
            await coordinator.createTasks([
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
            ]);
            const assignment = await taskAssignedPromise;
            expect(assignment).toMatchObject({
                type: "task_assigned",
                task: expect.objectContaining({
                    id: "task-001",
                }),
            });
            await coordinator.disconnect();
            await worker.disconnect();
        });
        test("should complete task as worker", async () => {
            const coordinator = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await coordinator.connect();
            await coordinator.register("coordinator", { projectId: "test" });
            const worker = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await worker.connect();
            await worker.register("worker", { workerId: "worker-A" });
            // Wait for task assignment
            const taskAssignedPromise = new Promise((resolve) => {
                worker.on("task_assigned", resolve);
            });
            await coordinator.createTasks([
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
            ]);
            await taskAssignedPromise;
            // Complete task
            const response = await worker.completeTask("task-001", {
                taskId: "task-001",
                workerId: "worker-A",
                status: "completed",
                deliverables: ["output.md"],
                contextEfficiencyScore: 5,
                completedAt: new Date().toISOString(),
            });
            expect(response).toMatchObject({
                type: "task_complete_ack",
                taskId: "task-001",
            });
            await coordinator.disconnect();
            await worker.disconnect();
        });
    });
    describe("Event Listeners", () => {
        test("should emit events for incoming messages", async () => {
            const client = new client_1.CoordinationClient(`ws://localhost:${port}`);
            await client.connect();
            const events = [];
            client.on("registered", () => events.push("registered"));
            client.on("tasks_created", () => events.push("tasks_created"));
            await client.register("coordinator", { projectId: "test" });
            await client.createTasks([
                {
                    id: "task-001",
                    type: "test",
                    description: "Test",
                    context: {
                        targetFiles: [],
                        outputFiles: [],
                        requirements: [],
                    },
                    acceptance: { criteria: [] },
                    status: "pending",
                    createdAt: new Date().toISOString(),
                },
            ]);
            expect(events).toContain("registered");
            expect(events).toContain("tasks_created");
            await client.disconnect();
        });
    });
});
//# sourceMappingURL=client.test.js.map