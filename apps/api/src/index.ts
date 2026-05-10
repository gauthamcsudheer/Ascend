import { config } from './config.js';
import { logger } from './lib/logger.js';
import { createServer } from './server.js';

const { httpServer } = createServer();

httpServer.listen(config.API_PORT, () => {
  logger.info({ port: config.API_PORT }, 'API server started');
});

process.on('SIGTERM', () => {
  logger.info('SIGTERM received; shutting down gracefully');
  httpServer.close(() => process.exit(0));
});
