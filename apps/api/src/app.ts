import cors from 'cors';
import express, { type Express } from 'express';
import rateLimit from 'express-rate-limit';
import pinoHttp from 'pino-http';

import { config } from './config.js';
import { logger } from './lib/logger.js';
import { errorHandler } from './middleware/error.js';

export function createApp(): Express {
  const app = express();

  app.use(
    cors({
      origin: config.NEXT_PUBLIC_APP_URL,
      credentials: true,
    }),
  );

  app.use(
    pinoHttp({
      logger,
      genReqId: (req, res) => {
        const incoming = req.headers['x-request-id'];
        const id = (Array.isArray(incoming) ? incoming[0] : incoming) ?? crypto.randomUUID();
        res.setHeader('x-request-id', id);
        return id;
      },
    }),
  );

  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true, limit: '1mb' }));

  const generalLimiter = rateLimit({
    windowMs: 60 * 1000,
    limit: 100,
    standardHeaders: 'draft-7',
    legacyHeaders: false,
  });
  app.use(generalLimiter);

  app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
  });

  app.get('/ready', (_req, res) => {
    res.json({ status: 'ready' });
  });

  // Routes mount here as they are built
  // app.use('/api/v1/auth', authRouter);

  app.use(errorHandler);

  return app;
}
