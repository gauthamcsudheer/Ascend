#!/usr/bin/env bash
set -e

echo "Resetting database (drop, re-create, migrate, seed)..."
pnpm db:reset
echo "Done."
