import pino from 'pino';

const logger = pino({ level: process.env.LOG_LEVEL ?? 'info' });

logger.info('Worker process starting...');

// Queue workers registered here as jobs are implemented
// import './queues/rep-decay.js';
// import './queues/notifications.js';

process.on('SIGTERM', () => {
  logger.info('SIGTERM received; closing workers');
  process.exit(0);
});
