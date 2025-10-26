/**
 * WebSocket Client for Multi-Chat Coordination
 * Used by both coordinator and worker chats
 */

import * as WebSocket from "ws";
import { EventEmitter } from "events";
import type {
  RegisterMessage,
  RegisteredMessage,
  CreateTasksMessage,
  TasksCreatedMessage,
  TaskCompleteMessage,
  Task,
  TaskReport,
  ClientRole,
} from "./types";

export class CoordinationClient extends EventEmitter {
  private ws: any = null; // WebSocket instance
  private url: string;
  private connected = false;

  constructor(url: string) {
    super();
    this.url = url;
  }

  async connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.ws = new WebSocket.WebSocket(this.url);

      this.ws.on("open", () => {
        this.connected = true;
      });

      this.ws.on("message", (data: WebSocket.Data) => {
        try {
          const message = JSON.parse(data.toString());
          
          // Emit specific event for message type
          this.emit(message.type, message);
          
          // Also emit generic message event
          this.emit("message", message);

          // Resolve on first message (connected)
          if (message.type === "connected") {
            resolve();
          }
        } catch (error) {
          console.error("[Client] Error parsing message:", (error as Error).message);
        }
      });

      this.ws.on("close", () => {
        this.connected = false;
        this.emit("disconnected");
      });

      this.ws.on("error", (error: Error) => {
        console.error("[Client] WebSocket error:", error.message);
        this.emit("error", error);
        reject(error);
      });
    });
  }

  async disconnect(): Promise<void> {
    if (this.ws && this.ws.readyState === WebSocket.WebSocket.OPEN) {
      this.ws.close();
      this.connected = false;
    }
  }

  isConnected(): boolean {
    return this.connected && this.ws?.readyState === WebSocket.WebSocket.OPEN;
  }

  async register(
    role: ClientRole,
    options: { workerId?: string; projectId?: string }
  ): Promise<RegisteredMessage> {
    const message: RegisterMessage = {
      type: "register",
      role,
      ...options,
    };

    return this.sendAndWait<RegisteredMessage>(message, "registered");
  }

  async createTasks(tasks: Task[]): Promise<TasksCreatedMessage> {
    const message: CreateTasksMessage = {
      type: "create_tasks",
      tasks,
    };

    return this.sendAndWait<TasksCreatedMessage>(message, "tasks_created");
  }

  async completeTask(
    taskId: string,
    report: TaskReport
  ): Promise<{ type: "task_complete_ack"; taskId: string }> {
    const message: TaskCompleteMessage = {
      type: "task_complete",
      taskId,
      report,
    };

    return this.sendAndWait(message, "task_complete_ack");
  }

  async requestTask(): Promise<any> {
    const message = {
      type: "request_task",
    };

    this.send(message);
    
    return new Promise((resolve) => {
      const handler = (msg: any) => {
        if (msg.type === "task_assigned" || msg.type === "no_tasks") {
          this.off("message", handler);
          resolve(msg);
        }
      };
      this.on("message", handler);
    });
  }

  async getStatus(): Promise<any> {
    const message = {
      type: "status",
    };

    return this.sendAndWait(message, "status_response");
  }

  private send(message: any): void {
    if (!this.ws || this.ws.readyState !== WebSocket.WebSocket.OPEN) {
      throw new Error("Not connected to server");
    }

    this.ws.send(JSON.stringify(message));
  }

  private sendAndWait<T>(message: any, responseType: string): Promise<T> {
    return new Promise((resolve, reject) => {
      if (!this.ws || this.ws.readyState !== WebSocket.WebSocket.OPEN) {
        reject(new Error("Not connected to server"));
        return;
      }

      const handler = (msg: any) => {
        if (msg.type === responseType) {
          this.off("message", handler);
          resolve(msg as T);
        } else if (msg.type === "error") {
          this.off("message", handler);
          reject(new Error(msg.error));
        }
      };

      this.on("message", handler);

      setTimeout(() => {
        this.off("message", handler);
        reject(new Error(`Timeout waiting for ${responseType}`));
      }, 5000);

      this.send(message);
    });
  }
}

