/**
 * WebSocket Client for Multi-Chat Coordination
 * Used by both coordinator and worker chats
 */
import { EventEmitter } from "events";
import type { RegisteredMessage, TasksCreatedMessage, Task, TaskReport, ClientRole } from "./types";
export declare class CoordinationClient extends EventEmitter {
    private ws;
    private url;
    private connected;
    constructor(url: string);
    connect(): Promise<void>;
    disconnect(): Promise<void>;
    isConnected(): boolean;
    register(role: ClientRole, options: {
        workerId?: string;
        projectId?: string;
    }): Promise<RegisteredMessage>;
    createTasks(tasks: Task[]): Promise<TasksCreatedMessage>;
    completeTask(taskId: string, report: TaskReport): Promise<{
        type: "task_complete_ack";
        taskId: string;
    }>;
    requestTask(): Promise<any>;
    getStatus(): Promise<any>;
    private send;
    private sendAndWait;
}
//# sourceMappingURL=client.d.ts.map