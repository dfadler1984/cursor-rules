/**
 * Multi-Chat Coordination Server
 * WebSocket server for coordinator-worker communication
 */
export declare class CoordinationServer {
    private wss;
    private port;
    private clients;
    private taskQueue;
    private activeTasks;
    private coordinator;
    private running;
    private watcher;
    private reportsDir;
    constructor(port?: number, reportsDir?: string);
    start(): Promise<void>;
    private startFileWatcher;
    stop(): Promise<void>;
    isRunning(): boolean;
    private handleConnection;
    private handleDisconnect;
    private handleMessage;
    private handleRegister;
    private handleCreateTasks;
    private handleRequestTask;
    private handleTaskComplete;
    private handleStatus;
    private assignNextTask;
    private isWorkerBusy;
    private send;
    private sendError;
    private generateClientId;
}
//# sourceMappingURL=server.d.ts.map