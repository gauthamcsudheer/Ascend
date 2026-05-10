#!/usr/bin/env bash
set -e

echo "Starting Postgres and Redis..."
docker compose up -d

echo "Waiting for Postgres to be ready..."
until docker compose exec postgres pg_isready -U ascend; do
  sleep 1
done

echo "Running migrations..."
pnpm db:migrate

echo "Seeding database..."
pnpm db:seed

echo "Starting all dev servers..."
pnpm dev
