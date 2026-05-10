import http from 'node:http';

import { Server as SocketIOServer } from 'socket.io';

import { createApp } from './app.js';
import { config } from './config.js';
import { logger } from './lib/logger.js';

export function createServer() {
  const app = createApp();
  const httpServer = http.createServer(app);

  const io = new SocketIOServer(httpServer, {
    cors: {
      origin: config.NEXT_PUBLIC_APP_URL,
      credentials: true,
    },
  });

  io.on('connection', (socket) => {
    logger.debug({ socketId: socket.id }, 'Socket connected');

    socket.on('disconnect', () => {
      logger.debug({ socketId: socket.id }, 'Socket disconnected');
    });
  });

  return { httpServer, io };
}
