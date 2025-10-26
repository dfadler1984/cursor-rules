#!/usr/bin/env ts-node
/**
 * Entry point for coordination server
 * Starts WebSocket server with file watching
 */

import { CoordinationServer } from "./server";

const PORT = parseInt(process.env.COORDINATION_PORT || "3100", 10);

const server = new CoordinationServer(PORT);

console.log("[Server] Multi-Chat Coordination Server starting...");

server.start()
  .then(() => {
    console.log(`[Server] Server running on ws://localhost:${PORT}`);
    console.log("[Server] Workers can connect and will receive tasks automatically");
    console.log("[Server] Press Ctrl+C to stop");
  })
  .catch((error) => {
    console.error("[Server] Failed to start:", error);
    process.exit(1);
  });

// Graceful shutdown
process.on("SIGINT", async () => {
  console.log("\n[Server] Shutting down...");
  await server.stop();
  process.exit(0);
});

process.on("SIGTERM", async () => {
  console.log("\n[Server] Shutting down...");
  await server.stop();
  process.exit(0);
});

