/**
 * Multi-Chat Coordination Types
 */

export type ClientRole = 'coordinator' | 'worker';

export type MessageType =
  | 'connected'
  | 'register'
  | 'registered'
  | 'create_tasks'
  | 'tasks_created'
  | 'request_task'
  | 'task_assigned'
  | 'no_tasks'
  | 'task_complete'
  | 'task_complete_ack'
  | 'report_detected'
  | 'worker_registered'
  | 'status'
  | 'status_response'
  | 'server_shutdown'
  | 'error';

export interface BaseMessage {
  type: MessageType;
}

export interface RegisterMessage extends BaseMessage {
  type: 'register';
  role: ClientRole;
  workerId?: string;
  projectId?: string;
}

export interface RegisteredMessage extends BaseMessage {
  type: 'registered';
  role: ClientRole;
  workerId?: string;
  projectId?: string;
}

export interface Task {
  id: string;
  type: string;
  description: string;
  context: {
    targetFiles: string[];
    outputFiles: string[];
    requirements: string[];
    relevantRules?: string[];
  };
  acceptance: {
    criteria: string[];
    validation?: string;
  };
  assignedTo?: string | null;
  status: 'pending' | 'assigned' | 'in-progress' | 'completed' | 'failed';
  createdAt: string;
  completedAt?: string | null;
  dependencies?: string[];
}

export interface CreateTasksMessage extends BaseMessage {
  type: 'create_tasks';
  tasks: Task[];
}

export interface TasksCreatedMessage extends BaseMessage {
  type: 'tasks_created';
  count: number;
  queued: number;
}

export interface TaskAssignedMessage extends BaseMessage {
  type: 'task_assigned';
  task: Task;
  taskId?: string;
  workerId?: string;
}

export interface TaskCompleteMessage extends BaseMessage {
  type: 'task_complete';
  taskId: string;
  workerId?: string;
  report?: TaskReport;
}

export interface TaskReport {
  taskId: string;
  workerId: string;
  status: 'completed' | 'failed' | 'blocked';
  deliverables: string[];
  contextEfficiencyScore: number;
  notes?: string;
  completedAt: string;
}

export interface ErrorMessage extends BaseMessage {
  type: 'error';
  error: string;
}

export interface StatusMessage extends BaseMessage {
  type: 'status';
}

export interface WorkerStatus {
  workerId: string;
  busy: boolean;
  currentTask: string | null;
}

export interface StatusResponseMessage extends BaseMessage {
  type: 'status_response';
  coordinator: 'connected' | 'disconnected';
  workers: WorkerStatus[];
  queueSize: number;
  activeTasks: number;
}

export interface RequestTaskMessage extends BaseMessage {
  type: 'request_task';
}

export type ServerMessage =
  | RegisterMessage
  | CreateTasksMessage
  | RequestTaskMessage
  | TaskCompleteMessage
  | StatusMessage;

export type ClientMessage =
  | RegisteredMessage
  | TasksCreatedMessage
  | TaskAssignedMessage
  | TaskCompleteMessage
  | StatusResponseMessage
  | ErrorMessage;

export interface ClientInfo {
  ws: any; // WebSocket type
  role: ClientRole | null;
  workerId?: string;
  projectId?: string;
}

export interface ActiveTask {
  workerId: string;
  startTime: string;
}

