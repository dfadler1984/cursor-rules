"use strict";
/**
 * WebSocket Client for Multi-Chat Coordination
 * Used by both coordinator and worker chats
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
exports.CoordinationClient = void 0;
const WebSocket = __importStar(require("ws"));
const events_1 = require("events");
class CoordinationClient extends events_1.EventEmitter {
    constructor(url) {
        super();
        this.ws = null; // WebSocket instance
        this.connected = false;
        this.url = url;
    }
    async connect() {
        return new Promise((resolve, reject) => {
            this.ws = new WebSocket.WebSocket(this.url);
            this.ws.on("open", () => {
                this.connected = true;
            });
            this.ws.on("message", (data) => {
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
                }
                catch (error) {
                    console.error("[Client] Error parsing message:", error.message);
                }
            });
            this.ws.on("close", () => {
                this.connected = false;
                this.emit("disconnected");
            });
            this.ws.on("error", (error) => {
                console.error("[Client] WebSocket error:", error.message);
                this.emit("error", error);
                reject(error);
            });
        });
    }
    async disconnect() {
        if (this.ws && this.ws.readyState === WebSocket.WebSocket.OPEN) {
            this.ws.close();
            this.connected = false;
        }
    }
    isConnected() {
        return this.connected && this.ws?.readyState === WebSocket.WebSocket.OPEN;
    }
    async register(role, options) {
        const message = {
            type: "register",
            role,
            ...options,
        };
        return this.sendAndWait(message, "registered");
    }
    async createTasks(tasks) {
        const message = {
            type: "create_tasks",
            tasks,
        };
        return this.sendAndWait(message, "tasks_created");
    }
    async completeTask(taskId, report) {
        const message = {
            type: "task_complete",
            taskId,
            report,
        };
        return this.sendAndWait(message, "task_complete_ack");
    }
    async requestTask() {
        const message = {
            type: "request_task",
        };
        this.send(message);
        return new Promise((resolve) => {
            const handler = (msg) => {
                if (msg.type === "task_assigned" || msg.type === "no_tasks") {
                    this.off("message", handler);
                    resolve(msg);
                }
            };
            this.on("message", handler);
        });
    }
    async getStatus() {
        const message = {
            type: "status",
        };
        return this.sendAndWait(message, "status_response");
    }
    send(message) {
        if (!this.ws || this.ws.readyState !== WebSocket.WebSocket.OPEN) {
            throw new Error("Not connected to server");
        }
        this.ws.send(JSON.stringify(message));
    }
    sendAndWait(message, responseType) {
        return new Promise((resolve, reject) => {
            if (!this.ws || this.ws.readyState !== WebSocket.WebSocket.OPEN) {
                reject(new Error("Not connected to server"));
                return;
            }
            const handler = (msg) => {
                if (msg.type === responseType) {
                    this.off("message", handler);
                    resolve(msg);
                }
                else if (msg.type === "error") {
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
exports.CoordinationClient = CoordinationClient;
//# sourceMappingURL=client.js.map