import { z } from 'zod';

const Env = z.object({
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  API_PORT: z.coerce.number().int().positive().default(4000),
  SESSION_COOKIE_DOMAIN: z.string().default('localhost'),
  SESSION_COOKIE_SECURE: z.coerce.boolean().default(false),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
  ENCRYPTION_KEY: z.string().min(64),
  VAPID_PUBLIC_KEY: z.string().optional(),
  VAPID_PRIVATE_KEY: z.string().optional(),
  VAPID_SUBJECT: z.string().optional(),
  GOOGLE_CLIENT_ID: z.string().optional(),
  GOOGLE_CLIENT_SECRET: z.string().optional(),
  GOOGLE_OAUTH_CALLBACK_URL: z.preprocess(
    (v) => (v === '' ? undefined : v),
    z.string().url().optional(),
  ),
  AWS_REGION: z.string().default('ap-south-1'),
  NEXT_PUBLIC_APP_URL: z.string().url().default('http://localhost:3000'),
  SENTRY_DSN: z.preprocess(
    (v) => (v === '' ? undefined : v),
    z.string().url().optional(),
  ),
});

export const config = Env.parse(process.env);
